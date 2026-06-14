<?php
/**
 * Section common/payment_breakdown — Bar chart top 5 moyens de paiement (+ Autres).
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_payment_breakdown(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';

    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');
    $revenueExpr = CoolStatsHelpers::getRevenueExpression('o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $rows = $db->executeS("SELECT
        COALESCE(NULLIF(o.payment, ''), NULLIF(o.module, ''), 'Inconnu') AS method,
        COUNT(o.id_order) AS cnt,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS rev
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'{$productWhere}
    GROUP BY COALESCE(NULLIF(o.payment, ''), NULLIF(o.module, ''), 'Inconnu')
    ORDER BY cnt DESC");
    $rows = is_array($rows) ? $rows : array();

    $top5 = array();
    $othersOrders = 0;
    $othersRev = 0.0;
    foreach ($rows as $i => $r) {
        if ($i < 5) {
            $top5[] = array(
                'label'   => $r['method'],
                'orders'  => (int) $r['cnt'],
                'revenue' => round((float) $r['rev'], 2),
            );
        } else {
            $othersOrders += (int) $r['cnt'];
            $othersRev    += (float) $r['rev'];
        }
    }
    if ($othersOrders > 0) {
        $top5[] = array(
            'label'   => 'Autres',
            'orders'  => $othersOrders,
            'revenue' => round($othersRev, 2),
        );
    }

    return array('breakdown' => $top5);
}
