<?php
/**
 * Section common/abandoned_carts — Paniers abandonnés.
 *
 * Un panier est considéré "abandonné" si :
 *   - Il a au moins 1 produit dans ps_cart_product
 *   - Aucune commande n'y est associée (ps_orders.id_cart NULL)
 *   - Il a plus de 2h pour exclure les paniers "en cours de checkout"
 *
 * KPIs :
 *   - Nombre de paniers abandonnés sur la période
 *   - Valeur totale potentielle perdue
 *   - Panier moyen abandonné
 *   - Taux d'abandon : abandons / (abandons + cmds) × 100
 *   - Top 5 paniers abandonnés les plus chers (pour relance manuelle)
 *
 * Inspiré de SellerSights "Cart_Lost_*".
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_abandoned_carts(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to'])   . ' 23:59:59';

    // Sous-requête : valeur du panier (qty × prix produit actuel)
    // On agrège par cart_id pour éviter d'avoir une ligne par produit.
    $cartValueSub = "
        SELECT cp.id_cart,
               SUM(cp.quantity) AS qty,
               SUM(cp.quantity * COALESCE(NULLIF(pa.price, 0), p.price)) AS value_ht
        FROM {$p}cart_product cp
        LEFT JOIN {$p}product p ON p.id_product = cp.id_product
        LEFT JOIN {$p}product_attribute pa ON pa.id_product_attribute = cp.id_product_attribute
        GROUP BY cp.id_cart
    ";

    // ── KPIs agrégés ──
    $kpi = $db->getRow("SELECT
        COUNT(c.id_cart) AS nb_abandoned,
        COALESCE(SUM(cpv.value_ht), 0) AS total_value_lost,
        COALESCE(AVG(cpv.value_ht), 0) AS avg_cart_value,
        COALESCE(SUM(cpv.qty), 0) AS total_items_lost
    FROM {$p}cart c
    INNER JOIN ({$cartValueSub}) cpv ON cpv.id_cart = c.id_cart AND cpv.qty > 0
    LEFT JOIN {$p}orders o ON o.id_cart = c.id_cart
    WHERE c.date_add BETWEEN '{$from}' AND '{$to}'
    AND c.date_add < DATE_SUB(NOW(), INTERVAL 2 HOUR)
    AND o.id_order IS NULL");

    $nbAbandoned   = (int) ($kpi['nb_abandoned'] ?? 0);
    $totalValue    = round((float) ($kpi['total_value_lost'] ?? 0), 2);
    $avgCart       = round((float) ($kpi['avg_cart_value'] ?? 0), 2);
    $totalItems    = (int) ($kpi['total_items_lost'] ?? 0);

    // Taux d'abandon = abandons / (abandons + cmds créées sur la période)
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $nbOrders = (int) $db->getValue("SELECT COUNT(o.id_order)
        FROM {$p}orders o
        WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
        AND {$valid}");
    $abandonRate = ($nbAbandoned + $nbOrders) > 0
        ? round(($nbAbandoned / ($nbAbandoned + $nbOrders)) * 100, 1)
        : 0;

    // ── Top 5 paniers les plus chers (pour relance manuelle) ──
    $topRows = $db->executeS("SELECT
        c.id_cart,
        c.date_add,
        c.id_customer,
        TRIM(CONCAT(COALESCE(cu.firstname, ''), ' ', COALESCE(cu.lastname, ''))) AS customer_name,
        cu.email,
        cpv.qty,
        cpv.value_ht
    FROM {$p}cart c
    INNER JOIN ({$cartValueSub}) cpv ON cpv.id_cart = c.id_cart AND cpv.qty > 0
    LEFT JOIN {$p}orders o ON o.id_cart = c.id_cart
    LEFT JOIN {$p}customer cu ON cu.id_customer = c.id_customer
    WHERE c.date_add BETWEEN '{$from}' AND '{$to}'
    AND c.date_add < DATE_SUB(NOW(), INTERVAL 2 HOUR)
    AND o.id_order IS NULL
    ORDER BY cpv.value_ht DESC
    LIMIT 5");

    $topAbandoned = array();
    if (is_array($topRows)) {
        $token = Tools::getAdminTokenLite('AdminCarts');
        foreach ($topRows as $r) {
            $idCart = (int) $r['id_cart'];
            $name = trim((string) $r['customer_name']);
            $topAbandoned[] = array(
                'id_cart'    => $idCart,
                'date_add'   => date('d/m/Y H:i', strtotime($r['date_add'])),
                'customer'   => $name !== '' ? $name : ($r['email'] ?: '—'),
                'email'      => (string) $r['email'],
                'qty'        => (int) $r['qty'],
                'value_ht'   => round((float) $r['value_ht'], 2),
                'bo_link'    => 'index.php?controller=AdminCarts&id_cart=' . $idCart . '&viewcart&token=' . $token,
            );
        }
    }

    return array(
        'nb_abandoned'     => $nbAbandoned,
        'total_value_lost' => $totalValue,
        'avg_cart_value'   => $avgCart,
        'total_items_lost' => $totalItems,
        'abandon_rate'     => $abandonRate,
        'nb_orders'        => $nbOrders,
        'top_abandoned'    => $topAbandoned,
    );
}
