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

    // Construit la série (labels + orders + revenue) pour une plage donnée, en
    // réutilisant la MÊME granularité que la période courante → les buckets de la
    // comparaison s'alignent positionnellement (index par index) sur la période courante.
    $buildSeries = function ($pFrom, $pTo) use ($db, $p, $granularity, $sqlGroup, $valid, $countryJoin, $channelsJoin, $revenueExpr, $productWhere, $monthsFr) {
        $effTo = min(strtotime($pTo), strtotime(date('Y-m-d')));
        $buckets = array();
        $cursor = strtotime($pFrom);
        if ($granularity === 'day') {
            while ($cursor <= $effTo) {
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
            while ($weekStart <= $effTo) {
                $key = date('o', $weekStart) . '-S' . date('W', $weekStart);
                $buckets[$key] = array('label' => date('d/m', $weekStart), 'orders' => 0, 'revenue' => 0);
                $weekStart = strtotime('+7 days', $weekStart);
            }
        } else {
            $cur = date('Y-m', $cursor);
            $endM = date('Y-m', $effTo);
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
        WHERE o.date_add BETWEEN '" . pSQL($pFrom) . " 00:00:00' AND '" . pSQL($pTo) . " 23:59:59'{$productWhere}
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
        return array('labels' => $labels, 'orders' => $orders, 'revenue' => $revenue);
    };

    $current = $buildSeries($from, $to);
    $labels  = $current['labels'];
    $orders  = $current['orders'];
    $revenue = $current['revenue'];

    // Série de comparaison (période précédente) si une comparaison est active.
    $ordersCompare = $revenueCompare = null;
    $compareMode = isset($params['compare_with']) ? (string) $params['compare_with'] : 'none';
    if ($compareMode !== 'none') {
        $cmp = CoolStatsHelpers::getCompareRangeForMode($from, $to, $compareMode);
        if (is_array($cmp) && !empty($cmp['from']) && !empty($cmp['to'])) {
            $cs = $buildSeries($cmp['from'], $cmp['to']);
            // Aligner sur la longueur de la période courante (padding/troncature par index).
            $n = count($labels);
            $ordersCompare  = array_slice(array_pad($cs['orders'], $n, 0), 0, $n);
            $revenueCompare = array_slice(array_pad($cs['revenue'], $n, 0), 0, $n);
        }
    }

    return array(
        'labels'          => $labels,
        'orders_data'     => $orders,
        'revenue_data'    => $revenue,
        'orders_compare'  => $ordersCompare,
        'revenue_compare' => $revenueCompare,
        'compare_mode'    => $compareMode,
        'granularity'     => $granularity,
    );
}
