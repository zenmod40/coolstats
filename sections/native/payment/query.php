<?php
/**
 * Section native/payment — répartition des commandes par moyen de paiement (ps_orders.module).
 * Affichée uniquement quand aucun module marketplace n'est détecté.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_native_payment(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;

    $dateWhere   = CoolStatsHelpers::getDateRangeFilter('o', $params['date_from'], $params['date_to']);
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $revenueExpr = CoolStatsHelpers::getRevenueExpression('o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // GROUP BY sur l'expression directement (pas l'alias) pour compat MariaDB strict.
    $rows = $db->executeS("SELECT
        COALESCE(NULLIF(o.payment, ''), NULLIF(o.module, ''), 'Inconnu') AS method,
        COUNT(o.id_order) AS orders_count,
        COALESCE(SUM({$revenueExpr}), 0) AS revenue
    FROM {$p}orders o
    {$countryJoin}
    WHERE {$dateWhere}{$productWhere}
    GROUP BY COALESCE(NULLIF(o.payment, ''), NULLIF(o.module, ''), 'Inconnu')
    ORDER BY orders_count DESC");

    if (!is_array($rows)) {
        $rows = array();
    }

    $totalOrders = 0;
    foreach ($rows as $r) {
        $totalOrders += (int) $r['orders_count'];
    }

    $methods = array();
    foreach ($rows as $r) {
        $orders = (int) $r['orders_count'];
        $methods[] = array(
            'method'       => $r['method'],
            'orders_count' => $orders,
            'revenue'      => round((float) $r['revenue'], 2),
            'pct'          => $totalOrders > 0 ? round(($orders / $totalOrders) * 100, 1) : 0,
        );
    }

    return array(
        'methods'       => $methods,
        'total_orders'  => $totalOrders,
    );
}
