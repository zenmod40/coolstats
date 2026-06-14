<?php
/**
 * Section common/margins — Marges brutes.
 *
 * Coût d'achat = SUM(order_detail.product_quantity × product.wholesale_price)
 *   - wholesale_price : champ natif PS (Catalogue → Produit → onglet Prix)
 *   - Si non rempli sur certains produits, on les flagge (coverage_pct)
 *
 * Marge brute = CA HT (produits, hors port) - Coût d'achat HT
 * Marge % = Marge brute / CA HT × 100
 *
 * Note : utilise CA Produits HT (sans frais de port), pas CA Total — la marge est sur les produits.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_margins(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;

    $from = $params['date_from'];
    $to   = $params['date_to'];
    $iso  = isset($params['country']) ? $params['country'] : null;

    $countryJoin = CoolStatsHelpers::getCountryJoin($iso, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');
    $dateWhere   = CoolStatsHelpers::getDateRangeFilter('o', $from, $to);
    $valid       = CoolStatsHelpers::getOrderStateCondition('valid', 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // ── Calcul global sur la période (commandes valides) ──
    // Note : on prend product_price (prix HT au moment de la cmd, hors taxes) pour le CA produit.
    // wholesale_price : prix d'achat unitaire (HT) du produit au moment de la cmd.
    $row = $db->getRow("SELECT
        COALESCE(SUM(od.product_quantity * od.product_price), 0) AS ca_products_ht,
        COALESCE(SUM(od.product_quantity * COALESCE(NULLIF(od.purchase_supplier_price, 0), p.wholesale_price)), 0) AS cost_ht,
        COALESCE(SUM(od.product_quantity), 0) AS qty_total,
        COALESCE(SUM(CASE WHEN COALESCE(NULLIF(od.purchase_supplier_price, 0), p.wholesale_price, 0) > 0
                          THEN od.product_quantity ELSE 0 END), 0) AS qty_with_cost
    FROM {$p}order_detail od
    INNER JOIN {$p}orders o ON o.id_order = od.id_order
    LEFT JOIN {$p}product p ON p.id_product = od.product_id
    {$countryJoin}
    {$channelsJoin}
    WHERE {$dateWhere}
    AND {$valid}{$productWhere}");

    $caProductsHT = round((float) $row['ca_products_ht'], 2);
    $costHT       = round((float) $row['cost_ht'], 2);
    $qtyTotal     = (int) $row['qty_total'];
    $qtyWithCost  = (int) $row['qty_with_cost'];

    $marginHT  = round($caProductsHT - $costHT, 2);
    $marginPct = $caProductsHT > 0 ? round(($marginHT / $caProductsHT) * 100, 1) : 0;
    $coveragePct = $qtyTotal > 0 ? round(($qtyWithCost / $qtyTotal) * 100, 0) : 0;

    // ── Top 5 produits par marge brute absolue (pour comprendre qui contribue) ──
    $topMarginRows = $db->executeS("SELECT
        od.product_id,
        MAX(od.product_name) AS product_name,
        SUM(od.product_quantity) AS qty,
        SUM(od.product_quantity * od.product_price) AS ca_ht,
        SUM(od.product_quantity * COALESCE(NULLIF(od.purchase_supplier_price, 0), p.wholesale_price)) AS cost,
        SUM(od.product_quantity * od.product_price)
            - SUM(od.product_quantity * COALESCE(NULLIF(od.purchase_supplier_price, 0), p.wholesale_price)) AS margin
    FROM {$p}order_detail od
    INNER JOIN {$p}orders o ON o.id_order = od.id_order
    LEFT JOIN {$p}product p ON p.id_product = od.product_id
    {$countryJoin}
    {$channelsJoin}
    WHERE {$dateWhere}
    AND {$valid}{$productWhere}
    AND COALESCE(NULLIF(od.purchase_supplier_price, 0), p.wholesale_price, 0) > 0
    GROUP BY od.product_id
    ORDER BY margin DESC
    LIMIT 5");

    $topMargin = array();
    if (is_array($topMarginRows)) {
        foreach ($topMarginRows as $r) {
            $caHt = (float) $r['ca_ht'];
            $marg = (float) $r['margin'];
            $topMargin[] = array(
                'id_product'   => (int) $r['product_id'],
                'name'         => $r['product_name'],
                'qty'          => (int) $r['qty'],
                'ca_ht'        => round($caHt, 2),
                'margin'       => round($marg, 2),
                'margin_pct'   => $caHt > 0 ? round(($marg / $caHt) * 100, 1) : 0,
            );
        }
    }

    return array(
        'ca_products_ht' => $caProductsHT,
        'cost_ht'        => $costHT,
        'margin_ht'      => $marginHT,
        'margin_pct'     => $marginPct,
        'coverage_pct'   => $coveragePct,
        'qty_total'      => $qtyTotal,
        'qty_with_cost'  => $qtyWithCost,
        'top_margin'     => $topMargin,
    );
}
