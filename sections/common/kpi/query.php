<?php
/**
 * Section common/kpi — 5 KPI universels avec comparaison N-1 et évolution %.
 *
 * KPIs :
 *   1. total_orders       — nombre de commandes (toutes)
 *   2. total_revenue      — CA TTC (états valides uniquement)
 *   3. avg_items          — articles par panier (commandes valides)
 *   4. avg_basket         — panier moyen (commandes valides)
 *   5. return_rate        — taux de retour (remboursées état 7 / total) en %
 *                           (les annulations état 6 ne comptent PAS comme retour)
 *
 * Tendances calculées vs période N-1 (immédiatement précédente, mode 'prev')
 * ou même période N-1 année précédente (mode 'yoy'), selon ?compare_with=.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_kpi(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $from = $params['date_from'];
    $to   = $params['date_to'];
    $iso  = isset($params['country']) ? $params['country'] : null;

    $countryJoin  = CoolStatsHelpers::getCountryJoin($iso, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');
    $dateWhere    = CoolStatsHelpers::getDateRangeFilter('o', $from, $to);
    $refunded     = CoolStatsHelpers::getRefundedStateCondition('o');
    $valid        = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $revenueExpr  = CoolStatsHelpers::getRevenueExpression('o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // ── Bloc principal : total / CA / panier moyen / nb retours ──
    $row = $db->getRow("SELECT
        COUNT(o.id_order) AS total_orders,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS total_revenue,
        COALESCE(AVG(CASE WHEN {$valid} THEN {$revenueExpr} END), 0) AS avg_basket,
        SUM(CASE WHEN {$refunded} THEN 1 ELSE 0 END) AS refunded_count
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE {$dateWhere}{$productWhere}");

    $totalOrders   = (int) $row['total_orders'];
    $totalRevenue  = (float) $row['total_revenue'];
    $avgBasket     = (float) $row['avg_basket'];
    $refundedCnt   = (int) $row['refunded_count'];
    $returnRate    = $totalOrders > 0 ? round(($refundedCnt / $totalOrders) * 100, 1) : 0.0;

    // ── Articles / panier (sub-query par commande, sur valides uniquement) ──
    $avgItems = (float) $db->getValue("SELECT AVG(qty) FROM (
        SELECT SUM(od.product_quantity) AS qty
        FROM {$p}orders o
        INNER JOIN {$p}order_detail od ON od.id_order = o.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE {$dateWhere}
        AND {$valid}{$productWhere}
        GROUP BY o.id_order
    ) t");

    // ── Comparaison ──
    $compareMode = isset($params['compare_with']) ? $params['compare_with'] : 'prev';
    $compareRange = CoolStatsHelpers::getCompareRangeForMode($from, $to, $compareMode);

    $trends = array(
        'orders'   => null,
        'revenue'  => null,
        'basket'   => null,
        'items'    => null,
    );
    $compareData = null;

    if ($compareRange) {
        $cFrom = $compareRange['from'];
        $cTo   = $compareRange['to'];
        $dateWherePrev = CoolStatsHelpers::getDateRangeFilter('o', $cFrom, $cTo);

        $rowPrev = $db->getRow("SELECT
            COUNT(o.id_order) AS total_orders,
            COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS total_revenue,
            COALESCE(AVG(CASE WHEN {$valid} THEN {$revenueExpr} END), 0) AS avg_basket
        FROM {$p}orders o
        {$countryJoin}
        {$channelsJoin}
        WHERE {$dateWherePrev}{$productWhere}");

        $avgItemsPrev = (float) $db->getValue("SELECT AVG(qty) FROM (
            SELECT SUM(od.product_quantity) AS qty
            FROM {$p}orders o
            INNER JOIN {$p}order_detail od ON od.id_order = o.id_order
            {$countryJoin}
            {$channelsJoin}
            WHERE {$dateWherePrev}
            AND {$valid}{$productWhere}
            GROUP BY o.id_order
        ) t");

        $trends['orders']  = CoolStatsHelpers::trend($totalOrders, (int) $rowPrev['total_orders']);
        $trends['revenue'] = CoolStatsHelpers::trend($totalRevenue, (float) $rowPrev['total_revenue']);
        $trends['basket']  = CoolStatsHelpers::trend($avgBasket, (float) $rowPrev['avg_basket']);
        $trends['items']   = CoolStatsHelpers::trend($avgItems, $avgItemsPrev);

        $compareData = array(
            'from' => $cFrom,
            'to'   => $cTo,
            'mode' => $compareMode,
        );
    }

    // ── Sparkline 28j (revenue par jour) — utilisée par le hero KPI Cozy/Editorial ──
    // On doit retourner UN POINT PAR JOUR (28 valeurs), même si la valeur est 0,
    // sinon une sparkline avec 2 points devient une ligne droite.
    $sparkRows = $db->executeS("SELECT
        DATE(o.date_add) AS d,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS rev
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add >= DATE_SUB(CURDATE(), INTERVAL 28 DAY){$productWhere}
    GROUP BY DATE(o.date_add)
    ORDER BY d ASC");
    $byDay = array();
    if (is_array($sparkRows)) {
        foreach ($sparkRows as $r) {
            $byDay[$r['d']] = round((float) $r['rev'], 2);
        }
    }
    $sparkline = array();
    for ($i = 27; $i >= 0; $i--) {
        $day = date('Y-m-d', strtotime('-' . $i . ' days'));
        $sparkline[] = isset($byDay[$day]) ? $byDay[$day] : 0.0;
    }

    // ── Détection du label de période (ce trimestre / ce mois / cette année / cette période) ──
    $periodLabel = 'cette période';
    $fromTs = strtotime($from);
    $toTs   = strtotime($to);
    $now    = time();
    $today  = strtotime(date('Y-m-d', $now));
    // Cette semaine : lundi 00h → dimanche 23h59 (semaine en cours)
    $weekStart = strtotime('monday this week');
    $weekEnd   = strtotime('sunday this week');
    if ($fromTs == $weekStart && $toTs == $weekEnd) $periodLabel = 'cette semaine';
    // Ce mois : 1er du mois → dernier jour du mois
    elseif ($fromTs == strtotime(date('Y-m-01')) && $toTs == strtotime(date('Y-m-t')))  $periodLabel = 'ce mois';
    // Ce trimestre
    else {
        $curQ = (int) floor((date('n')-1)/3);
        $qStart = mktime(0,0,0, $curQ*3+1, 1);
        $qEnd   = mktime(0,0,0, $curQ*3+4, 0);
        if ($fromTs == $qStart && $toTs == $qEnd) $periodLabel = 'ce trimestre';
        elseif ($fromTs == strtotime(date('Y-01-01')) && $toTs == strtotime(date('Y-12-31'))) $periodLabel = 'cette année';
    }

    // ── Catégorie dominante (la catégorie qui a vendu le plus d'unités sur la période) ──
    $dominantCategory = null;
    if ($totalOrders > 0) {
        $catRow = $db->getRow("SELECT cl.name, SUM(od.product_quantity) AS qty
            FROM {$p}orders o
            INNER JOIN {$p}order_detail od ON od.id_order = o.id_order
            INNER JOIN {$p}category_product cp ON cp.id_product = od.product_id
            INNER JOIN {$p}category c ON c.id_category = cp.id_category
            INNER JOIN {$p}category_lang cl ON cl.id_category = c.id_category AND cl.id_lang = {$idLang}
            {$countryJoin}
            WHERE {$dateWhere}
            AND {$valid}{$productWhere}
            AND c.id_parent > 1
            AND c.level_depth >= 2
            GROUP BY c.id_category
            ORDER BY qty DESC");
        if ($catRow && !empty($catRow['name'])) {
            $dominantCategory = mb_strtolower((string) $catRow['name'], 'UTF-8');
        }
    }

    // ── Narratif principal (Cozy + thèmes par défaut) ──
    // HTML autorisé : <strong> sur commandes + panier moyen uniquement (pas sur le %).
    $narrative = '';
    if ($totalOrders > 0) {
        $narrative = sprintf('<strong>%d commandes</strong>', $totalOrders);
        $narrative .= ' ' . $periodLabel;
        if ($avgBasket > 0) {
            $narrative .= sprintf(', un panier moyen à <strong>%s€</strong>', number_format($avgBasket, 0, ',', ' '));
        }
        if ($trends['revenue'] !== null && $trends['revenue'] > 5) {
            $narrative .= sprintf(' (+%s%%).', number_format($trends['revenue'], 0, ',', ' '));
            $narrative .= '<br>Belle dynamique';
            $narrative .= $dominantCategory ? ' sur les ' . $dominantCategory . '.' : ' sur la période.';
        } elseif ($trends['revenue'] !== null && $trends['revenue'] < -5) {
            $narrative .= sprintf(' (%s%%).', number_format($trends['revenue'], 0, ',', ' '));
            $narrative .= '<br>Activité en repli';
            $narrative .= $dominantCategory ? ' notamment sur les ' . $dominantCategory . ' — à surveiller.' : ' — à surveiller.';
        } else {
            $narrative .= '.';
            if ($dominantCategory) {
                $narrative .= '<br>Catégorie dominante : <strong>' . htmlspecialchars($dominantCategory, ENT_QUOTES, 'UTF-8') . '</strong>.';
            }
        }
    }

    // ── Narratif éditorial — style "rapport trimestriel" centré sur la progression % ──
    $narrativeEditorial = '';
    if ($totalOrders > 0) {
        // Transforme "ce trimestre" → "trimestre écoulé", "ce mois" → "mois écoulé", etc.
        $periodElapsedMap = array(
            'cette semaine'  => 'la semaine écoulée',
            'ce mois'        => 'le mois écoulé',
            'ce trimestre'   => 'le trimestre écoulé',
            'cette année'    => "l'année écoulée",
            'cette période'  => 'la période',
        );
        $elapsed = isset($periodElapsedMap[$periodLabel]) ? $periodElapsedMap[$periodLabel] : 'la période';
        $trendRev = $trends['revenue'];
        $trendBasket = $trends['basket'];

        if ($trendRev !== null && $trendRev > 0) {
            $narrativeEditorial = sprintf('Une progression de <strong>+%s %%</strong> sur %s', number_format($trendRev, 1, ',', ' '), $elapsed);
        } elseif ($trendRev !== null && $trendRev < 0) {
            $narrativeEditorial = sprintf('Un recul de <strong>%s %%</strong> sur %s', number_format($trendRev, 1, ',', ' '), $elapsed);
        } else {
            $narrativeEditorial = sprintf('Une stabilité sur %s', $elapsed);
        }
        $narrativeEditorial .= sprintf(', portée par <strong>%s commandes</strong>', number_format($totalOrders, 0, ',', ' '));
        if ($trendBasket !== null && abs($trendBasket) >= 5) {
            $direction = $trendBasket > 0 ? 'en hausse' : 'en repli';
            $narrativeEditorial .= sprintf(' et un panier moyen %s de <strong>%s %%</strong>', $direction, number_format(abs($trendBasket), 0, ',', ' '));
        } elseif ($avgBasket > 0) {
            $narrativeEditorial .= sprintf(' et un panier moyen à <strong>%s €</strong>', number_format($avgBasket, 0, ',', ' '));
        }
        $narrativeEditorial .= '.';
    }

    return array(
        'total_orders'   => $totalOrders,
        'total_revenue'  => round($totalRevenue, 2),
        'avg_items'      => round($avgItems, 2),
        'avg_basket'     => round($avgBasket, 2),
        'return_rate'    => $returnRate,
        'trends'         => $trends,
        'compare'        => $compareData,
        'sparkline'           => $sparkline,
        'narrative'           => $narrative,
        'narrative_editorial' => $narrativeEditorial,
    );
}
