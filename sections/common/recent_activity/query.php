<?php
/**
 * Section common/recent_activity — derniers changements de statut sur les commandes.
 *
 * Lit `ps_order_history` joint à `ps_orders` + `ps_order_state_lang` pour les noms.
 * Limité aux 20 dernières activités sur la période courante.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_recent_activity(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';
    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $rows = $db->executeS("SELECT
        oh.id_order_history,
        oh.id_order,
        oh.id_order_state,
        oh.date_add,
        o.reference,
        os.color AS state_color,
        os.paid, os.shipped, os.delivery,
        osl.name AS state_name,
        CONCAT(c.firstname, ' ', c.lastname) AS customer
    FROM {$p}order_history oh
    INNER JOIN {$p}orders o ON o.id_order = oh.id_order
    LEFT JOIN {$p}order_state os ON os.id_order_state = oh.id_order_state
    LEFT JOIN {$p}order_state_lang osl ON osl.id_order_state = oh.id_order_state AND osl.id_lang = {$idLang}
    LEFT JOIN {$p}customer c ON c.id_customer = o.id_customer
    {$countryJoin}
    WHERE oh.date_add BETWEEN '{$from}' AND '{$to}'{$productWhere}
    ORDER BY oh.date_add DESC
    LIMIT 20");
    $rows = is_array($rows) ? $rows : array();

    $cancelledStateId = (int) Configuration::get('PS_OS_CANCELED');
    $token = Tools::getAdminTokenLite('AdminOrders');
    $items = array();
    foreach ($rows as $r) {
        $idOrder = (int) $r['id_order'];

        // Catégorie sémantique pour le rendu (couleur de badge dans le thème).
        if ($cancelledStateId > 0 && (int) $r['id_order_state'] === $cancelledStateId) {
            $kind = 'cancel';
        } elseif ((int) $r['shipped'] === 1 || (int) $r['delivery'] === 1) {
            $kind = 'shipped';
        } elseif ((int) $r['paid'] === 1) {
            $kind = 'paid';
        } else {
            $kind = 'pending';
        }

        $items[] = array(
            'id_order'     => $idOrder,
            'reference'    => $r['reference'],
            'state_name'   => $r['state_name'] ?: '—',
            'state_color'  => $r['state_color'] ?: '#9ca3af',
            'customer'     => trim((string) $r['customer']) ?: '—',
            'kind'         => $kind,
            'type'         => $kind, // alias rétro-compat
            'time'         => coolstats_time_ago($r['date_add']),
            'bo_link'      => 'index.php?controller=AdminOrders&id_order=' . $idOrder . '&vieworder&token=' . $token,
        );
    }

    return array('items' => $items);
}

function coolstats_time_ago($datetime)
{
    $now = time();
    $then = strtotime($datetime);
    $diff = max(0, $now - $then);
    if ($diff < 60)    return 'À l\'instant';
    if ($diff < 3600)  return 'Il y a ' . floor($diff / 60) . ' min';
    if ($diff < 86400) return 'Il y a ' . floor($diff / 3600) . 'h';
    if ($diff < 604800) return 'Il y a ' . floor($diff / 86400) . 'j';
    return date('d/m/Y H:i', $then);
}
