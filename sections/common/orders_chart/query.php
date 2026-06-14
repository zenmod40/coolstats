<?php
/**
 * Section common/orders_chart — Courbe d'évolution des commandes / CA dans le temps.
 *
 * Granularité auto : ≤ 21j → jour, ≤ 120j → semaine, sinon mois.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_orders_chart(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = $params['date_from'];
    $to   = $params['date_to'];

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

    $effectiveTo = min(strtotime($to), strtotime(date('Y-m-d')));
    $days = max(1, ($effectiveTo - strtotime($from)) / 86400 + 1);

    if ($days <= 31) {
        $granularity = 'day';
        $sqlGroup = "DATE(o.date_add)";
    } elseif ($days <= 365) {
        $granularity = 'week';
        $sqlGroup = "DATE_FORMAT(o.date_add, '%x-S%v')";
    } else {
        $granularity = 'month';
        $sqlGroup = "DATE_FORMAT(o.date_add, '%Y-%m')";
    }

    $monthsFr = array('01' => 'Jan', '02' => 'Fév', '03' => 'Mar', '04' => 'Avr',
        '05' => 'Mai', '06' => 'Juin', '07' => 'Juil', '08' => 'Août',
        '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Déc');

    $buckets = array();
    $cursor = strtotime($from);
    if ($granularity === 'day') {
        while ($cursor <= $effectiveTo) {
            $buckets[date('Y-m-d', $cursor)] = array(
                'label'   => date('d', $cursor) . ' ' . $monthsFr[date('m', $cursor)],
                'orders'  => 0,
                'revenue' => 0,
            );
            $cursor = strtotime('+1 day', $cursor);
        }
    } elseif ($granularity === 'week') {
        $weekStart = $cursor;
        if (date('N', $weekStart) != 1) {
            $weekStart = strtotime('last monday', $weekStart);
        }
        while ($weekStart <= $effectiveTo) {
            $key = date('o', $weekStart) . '-S' . date('W', $weekStart);
            $buckets[$key] = array('label' => date('d/m', $weekStart), 'orders' => 0, 'revenue' => 0);
            $weekStart = strtotime('+7 days', $weekStart);
        }
    } else {
        $cur = date('Y-m', $cursor);
        $endM = date('Y-m', $effectiveTo);
        while ($cur <= $endM) {
            $buckets[$cur] = array(
                'label'   => $monthsFr[substr($cur, 5, 2)] . ' ' . substr($cur, 2, 2),
                'orders'  => 0,
                'revenue' => 0,
            );
            $cur = date('Y-m', strtotime($cur . '-01 +1 month'));
        }
    }

    $rows = $db->executeS("SELECT
        {$sqlGroup} AS k,
        COUNT(o.id_order) AS cnt,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS rev
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '" . pSQL($from) . " 00:00:00' AND '" . pSQL($to) . " 23:59:59'{$productWhere}
    GROUP BY k
    ORDER BY k");
    if (is_array($rows)) {
        foreach ($rows as $r) {
            if (isset($buckets[$r['k']])) {
                $buckets[$r['k']]['orders']  = (int) $r['cnt'];
                $buckets[$r['k']]['revenue'] = round((float) $r['rev'], 2);
            }
        }
    }

    $labels = $orders = $revenue = array();
    foreach ($buckets as $b) {
        $labels[]  = $b['label'];
        $orders[]  = $b['orders'];
        $revenue[] = $b['revenue'];
    }

    return array(
        'labels'       => $labels,
        'orders_data'  => $orders,
        'revenue_data' => $revenue,
        'granularity'  => $granularity,
    );
}
