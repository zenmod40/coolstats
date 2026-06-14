<?php
/**
 * Section common/performance — délai moyen d'expédition + taux de livraison.
 * Cliquable : ouvre la modal "Transporteurs" (détail par transporteur).
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_performance(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');

    $shipped = trim((string) Configuration::get('COOLSTATS_SHIPPED_STATES'));
    $shipped = $shipped !== '' ? $shipped : '4';
    $shipped = implode(',', array_map('intval', explode(',', $shipped))) ?: '4';

    $delivered = trim((string) Configuration::get('COOLSTATS_DELIVERED_STATES'));
    $delivered = $delivered !== '' ? $delivered : '5';
    $delivered = implode(',', array_map('intval', explode(',', $delivered))) ?: '5';

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // Délai moyen d'expédition (jours)
    $avgDelay = $db->getValue("SELECT AVG(DATEDIFF(oh_min.min_date, o.date_add))
        FROM {$p}orders o
        INNER JOIN (
            SELECT oh.id_order, MIN(oh.date_add) AS min_date
            FROM {$p}order_history oh
            WHERE oh.id_order_state IN ({$shipped})
            GROUP BY oh.id_order
        ) oh_min ON oh_min.id_order = o.id_order
        {$countryJoin}
        WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
        AND {$valid}{$productWhere}");

    // Taux de livraison : commandes livrées / total valide
    $row = $db->getRow("SELECT
        COUNT(o.id_order) AS total,
        SUM(CASE WHEN o.current_state IN ({$delivered}) THEN 1 ELSE 0 END) AS delivered_count
    FROM {$p}orders o
    {$countryJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$valid}{$productWhere}");

    $total = (int) ($row['total'] ?? 0);
    $deliveredCount = (int) ($row['delivered_count'] ?? 0);
    $deliveryRate = $total > 0 ? round(($deliveredCount / $total) * 100, 1) : 0;

    return array(
        'avg_delay'      => $avgDelay !== false && $avgDelay !== null ? round((float) $avgDelay, 1) : null,
        'delivery_rate'  => $deliveryRate,
        'delivered_count' => $deliveredCount,
        'total'          => $total,
    );
}
