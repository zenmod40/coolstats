<?php
/**
 * Section common/country_map — Carte d'Europe + classement pays.
 *
 * Calcule par pays (iso_code) : nb commandes, CA, % du total, % CA.
 * NE filtre PAS par pays (sinon le classement n'aurait qu'une ligne).
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_country_map(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';

    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $revenueExpr = CoolStatsHelpers::getRevenueExpression('o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $sql = "SELECT
        co.iso_code,
        cl.name AS country_name,
        COUNT(o.id_order) AS orders,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS revenue
    FROM {$p}orders o
    LEFT JOIN {$p}address a ON a.id_address = o.id_address_delivery
    LEFT JOIN {$p}country co ON co.id_country = a.id_country
    LEFT JOIN {$p}country_lang cl ON cl.id_country = a.id_country AND cl.id_lang = {$idLang}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'{$productWhere}
    AND co.iso_code IS NOT NULL
    GROUP BY co.iso_code, cl.name
    ORDER BY orders DESC";

    $rows = $db->executeS($sql);
    $rows = is_array($rows) ? $rows : array();

    $totalOrders = 0;
    $totalRevenue = 0.0;
    foreach ($rows as $r) {
        $totalOrders += (int) $r['orders'];
        $totalRevenue += (float) $r['revenue'];
    }

    $byIso = array();
    $ranked = array();
    foreach ($rows as $r) {
        $iso = strtoupper((string) $r['iso_code']);
        $orders = (int) $r['orders'];
        $rev = round((float) $r['revenue'], 2);
        $entry = array(
            'iso'         => $iso,
            'name'        => $r['country_name'] ?: $iso,
            'orders'      => $orders,
            'revenue'     => $rev,
            'pct_orders'  => $totalOrders > 0 ? round(($orders / $totalOrders) * 100, 1) : 0,
            'pct_revenue' => $totalRevenue > 0 ? round(($rev / $totalRevenue) * 100, 1) : 0,
        );
        $byIso[$iso] = $entry;
        $ranked[] = $entry;
    }

    // Charge le SVG une seule fois et injecte la classe `cs-map-path` sur tous les <path>.
    $svg = '';
    $svgPath = _PS_MODULE_DIR_ . 'coolstats/views/img/europe.svg';
    if (is_file($svgPath)) {
        $svg = (string) file_get_contents($svgPath);
        $svg = preg_replace('/<path(?![^>]*class=)/', '<path class="cs-map-path"', $svg);
    }

    // JSON safe pour <script type="application/json"> : on échappe juste les </script>.
    $byIsoJson = str_replace('</', '<\/', json_encode($byIso));

    return array(
        'by_iso'        => $byIso,
        'by_iso_attr'   => htmlspecialchars($byIsoJson, ENT_QUOTES, 'UTF-8'),
        'by_iso_json'   => $byIsoJson,
        'ranked'        => $ranked,
        'total_orders'  => $totalOrders,
        'total_revenue' => round($totalRevenue, 2),
        'svg'           => $svg,
        'selected_iso'  => isset($params['country']) ? $params['country'] : null,
    );
}
