<?php
/**
 * Section common/recent_orders — Tableau des commandes avec filtres + pagination.
 *
 * Filtres URL :
 *   - orders_status (all | preparing | shipped | delivered | cancelled)
 *   - orders_search (texte : référence ou client)
 *   - orders_page   (int)
 *   - country, channels (héritent du filtre global)
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_recent_orders(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $idLang = (int) Context::getContext()->language->id;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to']) . ' 23:59:59';

    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $channels     = isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array();
    $channelsJoin = CoolStatsHelpers::getChannelsJoin($channels, 'o');

    $perPage  = max(10, (int) Configuration::get('COOLSTATS_ORDERS_PER_PAGE'));
    $page     = max(1, (int) Tools::getValue('orders_page', 1));
    $status   = (string) Tools::getValue('orders_status', 'all');
    $search   = trim((string) Tools::getValue('orders_search', ''));
    $sortBy   = (string) Tools::getValue('orders_sort', '');
    $custType = (string) Tools::getValue('orders_customers', '');

    $statusToStates = array(
        'preparing' => '2,3',
        'shipped'   => Configuration::get('COOLSTATS_SHIPPED_STATES') ?: '4',
        'delivered' => Configuration::get('COOLSTATS_DELIVERED_STATES') ?: '5',
        'cancelled' => Configuration::get('COOLSTATS_CANCELLED_STATES') ?: '6,7',
    );

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    $where = "o.date_add BETWEEN '{$from}' AND '{$to}'" . $productWhere;
    if ($status !== 'all' && isset($statusToStates[$status])) {
        $states = implode(',', array_map('intval', explode(',', $statusToStates[$status])));
        if ($states !== '') {
            $where .= " AND o.current_state IN ({$states})";
        }
    }
    if ($search !== '') {
        $s = pSQL($search);
        $where .= " AND (o.reference LIKE '%{$s}%' OR CONCAT(c.firstname, ' ', c.lastname) LIKE '%{$s}%')";
    }
    // Filtre nouveaux clients : seulement les commandes dont c'est la 1re sur la période
    if ($custType === 'new') {
        $where .= " AND o.id_order = (SELECT MIN(o2.id_order) FROM {$p}orders o2 WHERE o2.id_customer = o.id_customer)";
    }

    // Tri (drill-down basket / items / défaut date)
    if ($sortBy === 'basket') {
        $orderBy = 'o.total_paid_tax_incl DESC';
    } elseif ($sortBy === 'items') {
        $orderBy = 'items_qty DESC';
    } else {
        $orderBy = 'o.date_add DESC';
    }
    $itemsSelect = ($sortBy === 'items')
        ? ", (SELECT SUM(od.product_quantity) FROM {$p}order_detail od WHERE od.id_order = o.id_order) AS items_qty"
        : '';

    // Total
    $totalOrders = (int) $db->getValue("SELECT COUNT(o.id_order)
        FROM {$p}orders o
        LEFT JOIN {$p}customer c ON c.id_customer = o.id_customer
        {$countryJoin}
        {$channelsJoin}
        WHERE {$where}");
    $totalPages = max(1, (int) ceil($totalOrders / $perPage));
    $page = min($page, $totalPages);
    $offset = ($page - 1) * $perPage;

    // Liste
    $sql = "SELECT
        o.id_order,
        o.reference,
        o.date_add,
        o.total_paid_tax_incl AS total,
        o.current_state,
        osl.name AS status_name,
        os.color AS status_color,
        os.paid, os.shipped, os.delivery,
        COALESCE(NULLIF(o.payment, ''), NULLIF(o.module, ''), 'Inconnu') AS payment,
        CONCAT(c.firstname, ' ', c.lastname) AS customer,
        cl.name AS country_name,
        co.iso_code AS country_iso
        {$itemsSelect}
    FROM {$p}orders o
    LEFT JOIN {$p}order_state os ON os.id_order_state = o.current_state
    LEFT JOIN {$p}order_state_lang osl ON osl.id_order_state = o.current_state AND osl.id_lang = {$idLang}
    LEFT JOIN {$p}customer c ON c.id_customer = o.id_customer
    LEFT JOIN {$p}address a ON a.id_address = o.id_address_delivery
    LEFT JOIN {$p}country co ON co.id_country = a.id_country
    LEFT JOIN {$p}country_lang cl ON cl.id_country = a.id_country AND cl.id_lang = {$idLang}
    {$countryJoin}
    {$channelsJoin}
    WHERE {$where}
    ORDER BY {$orderBy}
    LIMIT {$perPage} OFFSET {$offset}";
    $rows = $db->executeS($sql);

    $orders = array();
    if (is_array($rows)) {
        $token = Tools::getAdminTokenLite('AdminOrders');
        $cancelledStateId = (int) Configuration::get('PS_OS_CANCELED');
        foreach ($rows as $r) {
            $idOrder = (int) $r['id_order'];

            if ($cancelledStateId > 0 && (int) $r['current_state'] === $cancelledStateId) {
                $kind = 'cancel';
            } elseif ((int) $r['shipped'] === 1 || (int) $r['delivery'] === 1) {
                $kind = 'shipped';
            } elseif ((int) $r['paid'] === 1) {
                $kind = 'paid';
            } else {
                $kind = 'pending';
            }

            $orders[] = array(
                'id_order'     => $idOrder,
                'reference'    => $r['reference'],
                'date'         => date('d/m/Y H:i', strtotime($r['date_add'])),
                'customer'     => trim($r['customer']) ?: '—',
                'payment'      => $r['payment'],
                'total'        => round((float) $r['total'], 2),
                'status'       => $r['status_name'] ?: '—',
                'status_color' => $r['status_color'] ?: '#9ca3af',
                'kind'         => $kind,
                'country'      => $r['country_name'] ?: '—',
                'country_iso'  => $r['country_iso'] ?: '',
                'bo_link'      => 'index.php?controller=AdminOrders&id_order=' . $idOrder . '&vieworder&token=' . $token,
            );
        }
    }

    return array(
        'orders'     => $orders,
        'pagination' => array(
            'page'         => $page,
            'total_pages'  => $totalPages,
            'total_orders' => $totalOrders,
            'per_page'     => $perPage,
        ),
        'filters' => array(
            'status'    => $status,
            'search'    => $search,
            'sort'      => $sortBy,
            'customers' => $custType,
        ),
    );
}
