<?php
/**
 * Section common/highlights — 3 cards :
 *   - Produit star : score = qty_N × (1 + max(0, growth%))
 *   - À surveiller : score = retour% + max(0, -growth%), filter qty_ok >= 5
 *   - Vendus ensemble : self-join order_detail, paire la + fréquente
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_highlights(CoolStatsContext $ctx, array $params)
{
    return array(
        'star'  => coolstats_highlights_star($params),
        'watch' => coolstats_highlights_watch($params),
        'pairs' => coolstats_highlights_pairs($params),
    );
}

/**
 * Récupère nom + référence + image + lien BO d'un produit (helper local).
 */
function coolstats_highlights_meta($idProduct)
{
    $idProduct = (int) $idProduct;
    if (!$idProduct) return null;
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $row = $db->getRow("SELECT
        p.id_product, p.reference, pl.name, img.id_image
    FROM {$p}product p
    LEFT JOIN {$p}product_lang pl ON pl.id_product = p.id_product AND pl.id_lang = {$idLang}
    LEFT JOIN {$p}image img ON img.id_product = p.id_product AND img.cover = 1
    WHERE p.id_product = {$idProduct}");
    if (!$row) return null;

    $imgUrl = '';
    if ($row['id_image']) {
        $imgUrl = Context::getContext()->link->getImageLink('product', $idProduct . '-' . (int) $row['id_image'], 'small_default');
    }
    $token = Tools::getAdminTokenLite('AdminProducts');
    return array(
        'id_product' => $idProduct,
        'name'       => $row['name'] ?: '—',
        'reference'  => $row['reference'] ?: '',
        'image'      => $imgUrl,
        'bo_link'    => 'index.php?controller=AdminProducts&id_product=' . $idProduct . '&updateproduct&token=' . $token,
    );
}

function coolstats_highlights_star(array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = pSQL($params['date_from']);
    $to   = pSQL($params['date_to']);
    $compare = CoolStatsHelpers::getCompareRange($params['date_from'], $params['date_to']);
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $qN = $db->executeS("SELECT od.product_id, SUM(od.product_quantity) AS qty
        FROM {$p}order_detail od
        INNER JOIN {$p}orders o ON o.id_order = od.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE o.date_add BETWEEN '{$from} 00:00:00' AND '{$to} 23:59:59'
        AND {$valid}{$productWhere}
        GROUP BY od.product_id
        HAVING qty > 0");
    if (!$qN) return null;

    $byN = array();
    foreach ($qN as $r) $byN[(int) $r['product_id']] = (int) $r['qty'];

    $qP = $db->executeS("SELECT od.product_id, SUM(od.product_quantity) AS qty
        FROM {$p}order_detail od
        INNER JOIN {$p}orders o ON o.id_order = od.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE o.date_add BETWEEN '" . pSQL($compare['from']) . " 00:00:00' AND '" . pSQL($compare['to']) . " 23:59:59'
        AND {$valid}{$productWhere}
        GROUP BY od.product_id");
    $byP = array();
    if (is_array($qP)) {
        foreach ($qP as $r) $byP[(int) $r['product_id']] = (int) $r['qty'];
    }

    $bestId = null; $bestScore = -INF; $bestData = null;
    foreach ($byN as $id => $qty) {
        $prev = isset($byP[$id]) ? $byP[$id] : 0;
        $growth = $prev > 0 ? (($qty - $prev) / $prev) * 100 : ($qty > 0 ? 100.0 : 0.0);
        $score = $qty * (1 + max(0, $growth) / 100);
        if ($score > $bestScore) {
            $bestScore = $score;
            $bestId = $id;
            $bestData = array('qty' => $qty, 'growth' => round($growth, 1));
        }
    }
    if (!$bestId) return null;
    $meta = coolstats_highlights_meta($bestId);
    return $meta ? array_merge($meta, $bestData) : null;
}

function coolstats_highlights_watch(array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = pSQL($params['date_from']);
    $to   = pSQL($params['date_to']);
    $compare = CoolStatsHelpers::getCompareRange($params['date_from'], $params['date_to']);
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $cancelled = CoolStatsHelpers::getOrderStateCondition('cancelled', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $rN = $db->executeS("SELECT od.product_id,
            SUM(CASE WHEN {$valid} THEN od.product_quantity ELSE 0 END) AS qty_ok,
            SUM(CASE WHEN {$cancelled} THEN od.product_quantity ELSE 0 END) AS qty_ret
        FROM {$p}order_detail od
        INNER JOIN {$p}orders o ON o.id_order = od.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE o.date_add BETWEEN '{$from} 00:00:00' AND '{$to} 23:59:59'{$productWhere}
        GROUP BY od.product_id
        HAVING qty_ok >= 5");
    if (!$rN) return null;

    $rP = $db->executeS("SELECT od.product_id, SUM(od.product_quantity) AS qty
        FROM {$p}order_detail od
        INNER JOIN {$p}orders o ON o.id_order = od.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE o.date_add BETWEEN '" . pSQL($compare['from']) . " 00:00:00' AND '" . pSQL($compare['to']) . " 23:59:59'
        AND {$valid}{$productWhere}
        GROUP BY od.product_id");
    $byP = array();
    if (is_array($rP)) {
        foreach ($rP as $r) $byP[(int) $r['product_id']] = (int) $r['qty'];
    }

    $worstId = null; $worstScore = -INF; $worstData = null;
    foreach ($rN as $r) {
        $id = (int) $r['product_id'];
        $ok = (int) $r['qty_ok'];
        $ret = (int) $r['qty_ret'];
        $total = $ok + $ret;
        $returnRate = $total > 0 ? ($ret / $total) * 100 : 0;
        $prev = isset($byP[$id]) ? $byP[$id] : 0;
        $growth = $prev > 0 ? (($ok - $prev) / $prev) * 100 : 0;
        $score = $returnRate + max(0, -$growth);
        if ($score > $worstScore && $score > 0) {
            $worstScore = $score;
            $worstId = $id;
            $worstData = array(
                'qty'         => $ok,
                'return_rate' => round($returnRate, 1),
                'growth'      => round($growth, 1),
            );
        }
    }
    if (!$worstId) return null;
    $meta = coolstats_highlights_meta($worstId);
    return $meta ? array_merge($meta, $worstData) : null;
}

function coolstats_highlights_pairs(array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = pSQL($params['date_from']);
    $to   = pSQL($params['date_to']);
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // Db::getRow ajoute LIMIT 1 automatiquement → ne pas en mettre ici.
    $row = $db->getRow("SELECT od1.product_id AS p1, od2.product_id AS p2, COUNT(DISTINCT o.id_order) AS cnt
        FROM {$p}order_detail od1
        INNER JOIN {$p}order_detail od2 ON od2.id_order = od1.id_order AND od2.product_id > od1.product_id
        INNER JOIN {$p}orders o ON o.id_order = od1.id_order
        {$countryJoin}
        {$channelsJoin}
        WHERE o.date_add BETWEEN '{$from} 00:00:00' AND '{$to} 23:59:59'
        AND {$valid}{$productWhere}
        GROUP BY p1, p2
        ORDER BY cnt DESC");
    if (!$row || !$row['p1'] || !$row['p2']) return null;
    $a = coolstats_highlights_meta((int) $row['p1']);
    $b = coolstats_highlights_meta((int) $row['p2']);
    if (!$a || !$b) return null;
    return array(
        'count'     => (int) $row['cnt'],
        'product_a' => $a,
        'product_b' => $b,
    );
}
