<?php
/**
 * Section common/signups — Tunnel de conversion compte → 1re commande.
 *
 * KPIs :
 *   - Comptes créés sur la période
 *   - Combien ont passé au moins 1 commande valide (à n'importe quelle date)
 *   - Combien restent "fantômes" (compte créé, jamais commandé)
 *   - Taux de conversion (% des comptes qui ont commandé)
 *   - Délai moyen entre création compte et 1re commande (jours)
 *
 * Inspiré du "Creation_Compte_Client_NB_NO_CMD" de SellerSights.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_signups(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to'])   . ' 23:59:59';

    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');

    // Comptes créés + leur 1re commande valide (tous temps, pas limitée à la période)
    $row = $db->getRow("SELECT
        COUNT(*) AS total_created,
        SUM(IF(first_order.first_order_date IS NOT NULL, 1, 0)) AS with_order,
        AVG(IF(first_order.first_order_date IS NOT NULL,
               DATEDIFF(first_order.first_order_date, c.date_add), NULL)) AS avg_delay_days
    FROM {$p}customer c
    LEFT JOIN (
        SELECT o.id_customer, MIN(o.date_add) AS first_order_date
        FROM {$p}orders o
        WHERE {$valid}
        GROUP BY o.id_customer
    ) first_order ON first_order.id_customer = c.id_customer
    WHERE c.date_add BETWEEN '{$from}' AND '{$to}'");

    $totalCreated = (int) ($row['total_created'] ?? 0);
    $withOrder    = (int) ($row['with_order'] ?? 0);
    $avgDelay     = $row['avg_delay_days'] !== null ? round((float) $row['avg_delay_days'], 1) : null;

    $withoutOrder   = max(0, $totalCreated - $withOrder);
    $conversionRate = $totalCreated > 0 ? round(($withOrder / $totalCreated) * 100, 1) : 0;

    return array(
        'total_created'    => $totalCreated,
        'with_order'       => $withOrder,
        'without_order'    => $withoutOrder,
        'conversion_rate'  => $conversionRate,
        'avg_delay_days'   => $avgDelay,
    );
}
