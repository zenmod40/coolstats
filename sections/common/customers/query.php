<?php
/**
 * Section common/customers — KPI clients :
 *   - Nouveaux clients sur la période (1ère commande dans la fenêtre)
 *   - Clients récurrents (≥ 2 commandes au total, dont 1 dans la période)
 *   - Moyenne commandes par client (sur la période)
 *   - LTV moyenne (CA total cumulé / nb clients sur toute leur historique)
 *   - Remboursements (nb + valeur)
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_customers(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';

    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $cancelled = CoolStatsHelpers::getOrderStateCondition('cancelled', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');
    $revenueExprO2 = CoolStatsHelpers::getRevenueExpression('o2');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // ── Période N : clients distincts + leurs commandes valides ──
    $row = $db->getRow("SELECT
        COUNT(DISTINCT o.id_customer) AS total_customers,
        COUNT(o.id_order) AS total_orders
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$valid}
    AND o.id_customer > 0{$productWhere}");
    $totalCustomers = (int) ($row['total_customers'] ?? 0);
    $totalOrders = (int) ($row['total_orders'] ?? 0);
    $avgOrdersPerCustomer = $totalCustomers > 0 ? round($totalOrders / $totalCustomers, 2) : 0;

    // ── Nouveaux clients : 1ère commande tombe dans la période ──
    $newCustomers = (int) $db->getValue("SELECT COUNT(*) FROM (
        SELECT o.id_customer, MIN(o.date_add) AS first_date
        FROM {$p}orders o
        {$countryJoin}
        {$channelsJoin}
        WHERE o.id_customer > 0
        AND {$valid}{$productWhere}
        GROUP BY o.id_customer
        HAVING first_date BETWEEN '{$from}' AND '{$to}'
    ) sub");

    $recurringCustomers = max(0, $totalCustomers - $newCustomers);
    $newCustomersPct = $totalCustomers > 0 ? round(($newCustomers / $totalCustomers) * 100, 1) : 0;

    // ── LTV moyenne : CA cumulé / nb clients (parmi ceux ayant commandé sur la période) ──
    // Calculée sur tout l'historique de ces clients, pas juste la période.
    $ltvRow = $db->getRow("SELECT AVG(total_per_customer) AS avg_ltv FROM (
        SELECT o2.id_customer, SUM({$revenueExprO2}) AS total_per_customer
        FROM {$p}orders o2
        WHERE o2.id_customer IN (
            SELECT DISTINCT o.id_customer
            FROM {$p}orders o
            {$countryJoin}
            {$channelsJoin}
            WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
            AND o.id_customer > 0{$productWhere}
        )
        AND o2.current_state IN (
            SELECT id_order_state FROM {$p}order_state WHERE deleted = 0
        )
        AND o2.id_customer > 0
        GROUP BY o2.id_customer
    ) ltv_sub");
    // Note : on filtre les annulés directement via le sous-query plus simple.
    // En réalité on prend tous les états non supprimés pour LTV brute. Affinable plus tard.
    $avgLtv = $ltvRow && isset($ltvRow['avg_ltv']) ? round((float) $ltvRow['avg_ltv'], 2) : 0;

    // ── Remboursements : commandes annulées sur la période ──
    $refundRow = $db->getRow("SELECT
        COUNT(o.id_order) AS refund_count,
        COALESCE(SUM(o.total_paid_tax_incl), 0) AS refund_value
    FROM {$p}orders o
    {$countryJoin}
    {$channelsJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$cancelled}{$productWhere}");
    $refundCount = (int) ($refundRow['refund_count'] ?? 0);
    $refundValue = round((float) ($refundRow['refund_value'] ?? 0), 2);

    return array(
        'total_customers'     => $totalCustomers,
        'new_customers'       => $newCustomers,
        'new_customers_pct'   => $newCustomersPct,
        'recurring_customers' => $recurringCustomers,
        'avg_orders'          => $avgOrdersPerCustomer,
        'avg_ltv'             => $avgLtv,
        'refund_count'        => $refundCount,
        'refund_value'        => $refundValue,
    );
}
