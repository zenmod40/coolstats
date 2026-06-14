<?php
/**
 * Section common/top_products — Top 100 produits avec ligne totaux.
 *
 * Universel : groupe par product_id (un produit = une ligne).
 * Toggle Volume / CA piloté par ?sort=qty|revenue (lu dans le query directement
 * pour rester sans état entre les appels AJAX).
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_top_products(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';

    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');
    $valid       = CoolStatsHelpers::getOrderStateCondition('valid', 'o');

    $sortMode = (string) Tools::getValue('sort', 'qty');
    $sortMode = in_array($sortMode, array('qty', 'revenue'), true) ? $sortMode : 'qty';
    $orderBy  = $sortMode === 'revenue' ? 'total_revenue' : 'total_qty';

    $limit = (int) Tools::getValue('top_limit', 25);
    if (!in_array($limit, array(10, 25, 50, 100), true)) {
        $limit = 25;
    }

    // Filtre recherche produit : ne garde que la (les) ligne(s) du produit
    // recherché (pas les co-achats). Appliqué au Top seulement — le total global
    // reste celui de la période (→ le % devient la part du produit).
    $product = isset($params['product']) ? $params['product'] : null;
    $productLine = '';
    if ($product) {
        $line = CoolStatsHelpers::getProductLineMatchSQL($product, 'od');
        if ($line !== '') $productLine = ' AND ' . $line;
    }

    // ── Top 100 par produit ──
    $sql = "SELECT
        od.product_id,
        MAX(od.product_name) AS product_name,
        MAX(od.product_reference) AS product_reference,
        MAX(p.reference) AS p_reference,
        MAX(p.ean13) AS ean13,
        SUM(od.product_quantity) AS total_qty,
        SUM(od.total_price_tax_incl) AS total_revenue,
        MAX(img.id_image) AS id_image
    FROM {$p}order_detail od
    INNER JOIN {$p}orders o ON o.id_order = od.id_order
    LEFT JOIN {$p}product p ON p.id_product = od.product_id
    LEFT JOIN {$p}image img ON img.id_product = od.product_id AND img.cover = 1
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$valid}
    {$productLine}
    GROUP BY od.product_id
    ORDER BY {$orderBy} DESC
    LIMIT {$limit}";

    $rows = $db->executeS($sql);
    $rows = is_array($rows) ? $rows : array();

    $linkObj = Context::getContext()->link;
    $token = Tools::getAdminTokenLite('AdminProducts');

    $products = array();
    $topQty = 0;
    $topRevenue = 0.0;
    foreach ($rows as $r) {
        $idProduct = (int) $r['product_id'];
        $idImage = (int) $r['id_image'];
        $imgUrl = '';
        if ($idImage && $idProduct) {
            $imgUrl = $linkObj->getImageLink('product', $idProduct . '-' . $idImage, 'small_default');
        }
        $qty = (int) $r['total_qty'];
        $rev = round((float) $r['total_revenue'], 2);
        $topQty += $qty;
        $topRevenue += $rev;

        $products[] = array(
            'id_product'     => $idProduct,
            'name'           => $r['product_name'],
            'reference'      => $r['product_reference'] ?: ($r['p_reference'] ?: ''),
            'ean13'          => $r['ean13'] ?: '',
            'total_qty'      => $qty,
            'total_revenue'  => $rev,
            'image'          => $imgUrl,
            'bo_link'        => 'index.php?controller=AdminProducts&id_product=' . $idProduct . '&updateproduct&token=' . $token,
        );
    }

    // ── Total global de la période (mêmes filtres : valides + pays + dates) ──
    $globalRow = $db->getRow("SELECT
        COALESCE(SUM(od.product_quantity), 0) AS qty,
        COALESCE(SUM(od.total_price_tax_incl), 0) AS revenue
    FROM {$p}order_detail od
    INNER JOIN {$p}orders o ON o.id_order = od.id_order
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$valid}");

    $globalQty = (int) ($globalRow['qty'] ?? 0);
    $globalRevenue = round((float) ($globalRow['revenue'] ?? 0), 2);

    return array(
        'products'  => $products,
        'sort_mode' => $sortMode,
        'limit'     => $limit,
        'totals'    => array(
            'top_qty'        => $topQty,
            'top_revenue'    => round($topRevenue, 2),
            'global_qty'     => $globalQty,
            'global_revenue' => $globalRevenue,
            'pct_qty'        => $globalQty > 0 ? round(($topQty / $globalQty) * 100, 1) : 0,
            'pct_revenue'    => $globalRevenue > 0 ? round(($topRevenue / $globalRevenue) * 100, 1) : 0,
        ),
    );
}
