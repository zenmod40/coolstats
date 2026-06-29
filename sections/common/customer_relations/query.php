<?php
/**
 * Section common/customer_relations — KPI relation client.
 *
 * Commandes (référence) · Rétractations (si module installé) · Demandes SAV
 * (service client natif PrestaShop : ps_customer_thread). Ratios vs commandes
 * + tendances N-1 si une comparaison est active. Tout est conditionnel : la
 * rétractation n'apparaît que si la table du module existe.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_customer_relations(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p  = _DB_PREFIX_;
    $from = $params['date_from'];
    $to   = $params['date_to'];
    $idShop = (int) Context::getContext()->shop->id;

    $valid        = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $countryJoin  = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');

    // Détection du module Rétractations (table présente ?). information_schema car
    // Db::getValue ajoute LIMIT 1, incompatible avec SHOW TABLES.
    $hasRetract = (bool) (int) $db->getValue(
        "SELECT COUNT(*) FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '" . $p . "retractation_request'"
    );

    // Compteurs sur une plage donnée
    $counts = function ($f, $t) use ($db, $p, $valid, $countryJoin, $channelsJoin, $idShop, $hasRetract) {
        $fEsc = pSQL($f) . ' 00:00:00';
        $tEsc = pSQL($t) . ' 23:59:59';
        $orders = (int) $db->getValue("SELECT COUNT(o.id_order)
            FROM {$p}orders o {$countryJoin} {$channelsJoin}
            WHERE {$valid} AND o.date_add BETWEEN '{$fEsc}' AND '{$tEsc}'");
        $sav = (int) $db->getValue("SELECT COUNT(*)
            FROM {$p}customer_thread ct
            WHERE ct.date_add BETWEEN '{$fEsc}' AND '{$tEsc}'" . ($idShop ? " AND ct.id_shop = {$idShop}" : ''));
        $retract = null;
        if ($hasRetract) {
            $retract = (int) $db->getValue("SELECT COUNT(*)
                FROM {$p}retractation_request rr
                WHERE rr.date_add BETWEEN '{$fEsc}' AND '{$tEsc}'");
        }
        return array('orders' => $orders, 'sav' => $sav, 'retract' => $retract);
    };

    $cur = $counts($from, $to);

    // Tendances N-1 (si comparaison active)
    $trends = array('orders' => null, 'sav' => null, 'retract' => null);
    $compareMode = isset($params['compare_with']) ? (string) $params['compare_with'] : 'none';
    if ($compareMode !== 'none') {
        $cmp = CoolStatsHelpers::getCompareRangeForMode($from, $to, $compareMode);
        if (is_array($cmp) && !empty($cmp['from']) && !empty($cmp['to'])) {
            $prev = $counts($cmp['from'], $cmp['to']);
            $trends['orders'] = CoolStatsHelpers::trend($cur['orders'], $prev['orders']);
            $trends['sav']    = CoolStatsHelpers::trend($cur['sav'], $prev['sav']);
            if ($hasRetract) {
                $trends['retract'] = CoolStatsHelpers::trend($cur['retract'], $prev['retract']);
            }
        }
    }

    $orders = $cur['orders'];
    return array(
        'orders'       => $orders,
        'sav'          => $cur['sav'],
        'sav_rate'     => $orders > 0 ? round($cur['sav'] / $orders * 100, 1) : 0,
        'has_retract'  => $hasRetract,
        'retract'      => $cur['retract'],
        'retract_rate' => ($hasRetract && $orders > 0) ? round($cur['retract'] / $orders * 100, 1) : 0,
        'trends'       => $trends,
    );
}
