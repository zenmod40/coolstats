<?php
/**
 * Section common/goals — Objectifs mensuels (CA + commandes).
 *
 * Toujours sur le mois courant (ignore le filtre de période global).
 * Désactivée si les deux objectifs sont à 0.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_goals(CoolStatsContext $ctx, array $params)
{
    $goalRevenue = (float) Configuration::get('COOLSTATS_GOAL_REVENUE');
    $goalOrders  = (int) Configuration::get('COOLSTATS_GOAL_ORDERS');

    if ($goalRevenue <= 0 && $goalOrders <= 0) {
        return array('enabled' => false);
    }

    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p  = _DB_PREFIX_;

    $now           = time();
    $monthStart    = date('Y-m-01 00:00:00', $now);
    $monthEnd      = date('Y-m-t 23:59:59', $now);
    $today         = (int) date('j', $now);
    $daysInMonth   = (int) date('t', $now);
    $daysRemaining = max(0, $daysInMonth - $today);
    $progressDays  = $daysInMonth > 0 ? ($today / $daysInMonth) : 0;

    $iso         = isset($params['country']) ? $params['country'] : null;
    $countryJoin = CoolStatsHelpers::getCountryJoin($iso, 'o');
    $dateWhere   = CoolStatsHelpers::getDateRangeFilter('o', $monthStart, $monthEnd);
    $valid       = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $revenueExpr = CoolStatsHelpers::getRevenueExpression('o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $row = $db->getRow("SELECT
        COUNT(o.id_order) AS total_orders,
        COALESCE(SUM(CASE WHEN {$valid} THEN {$revenueExpr} ELSE 0 END), 0) AS total_revenue
    FROM {$p}orders o
    {$countryJoin}
    WHERE {$dateWhere}{$productWhere}");

    $currentRevenue = (float) $row['total_revenue'];
    $currentOrders  = (int) $row['total_orders'];

    $build = function ($current, $goal) use ($progressDays, $today, $daysInMonth) {
        if ($goal <= 0) {
            return null;
        }
        $progressPct  = ($current / $goal) * 100;
        $expectedPct  = $progressDays * 100;
        $projection   = $today > 0 ? ($current / $today) * $daysInMonth : 0;
        $deltaVsExpected = $progressPct - $expectedPct;

        // Statut tricolore : avance / sur trajectoire / retard
        if ($deltaVsExpected >= 0) {
            $status = 'ahead';
        } elseif ($deltaVsExpected >= -10) {
            $status = 'on_track';
        } else {
            $status = 'behind';
        }

        return array(
            'current'        => $current,
            'goal'           => $goal,
            'progress_pct'   => round($progressPct, 1),
            'expected_pct'   => round($expectedPct, 1),
            'projection'     => round($projection, 2),
            'delta_expected' => round($deltaVsExpected, 1),
            'status'         => $status,
        );
    };

    $months = array(1=>'Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre');
    $monthLabel = $months[(int) date('n', $now)] . ' ' . date('Y', $now);

    return array(
        'enabled'         => true,
        'month_label'     => $monthLabel,
        'days_in_month'   => $daysInMonth,
        'today'           => $today,
        'days_remaining'  => $daysRemaining,
        'revenue'         => $build($currentRevenue, $goalRevenue),
        'orders'          => $build($currentOrders, $goalOrders),
    );
}
