<?php
/**
 * Section marketplace/breakdown — Répartition CA / commandes / panier moyen
 * par marketplace vs vente directe.
 *
 * Autodétection de la source de données :
 *   1. `ps_marketplace_orders` (module Common Service / Mirakl-like)
 *        - colonnes : channel ('MFN'/'AFN'), sales_channel ('CDISFR',
 *          'decathlon.eu', 'decathlon.eu2'…), cd_channel_name
 *        - CASE WHEN appliqué directement pour donner un label propre
 *   2. `ps_shoppingfeed_order` (module ShoppingFeed)
 *        - colonne : name_marketplace
 *
 * Si aucune des deux n'existe → empty state explicite.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_marketplace_breakdown(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p  = _DB_PREFIX_;

    $from = pSQL($params['date_from']) . ' 00:00:00';
    $to   = pSQL($params['date_to'])   . ' 23:59:59';

    $countryJoin = CoolStatsHelpers::getCountryJoin(isset($params['country']) ? $params['country'] : null, 'o');
    $valid       = CoolStatsHelpers::getOrderStateCondition('valid', 'o');

    $product = isset($params['product']) ? $params['product'] : null;
    $productWhere = '';
    if ($product) {
        $pf = CoolStatsHelpers::getProductFilterWhereSQL($product, 'o');
        if ($pf !== '') $productWhere = ' AND ' . $pf;
    }

    // ── Détection de la source de données ──
    $source = coolstats_breakdown_detect_source($db, $p);

    if ($source === null) {
        return array(
            'rows'        => array(),
            'totals'      => array('orders' => 0, 'revenue' => 0.0, 'aov' => 0.0),
            'source'      => null,
            'period_from' => $params['date_from'],
            'period_to'   => $params['date_to'],
        );
    }

    // ── SQL : labelExpr + joinExpr selon la source ──
    if ($source === 'marketplace_orders') {
        // CASE construit dynamiquement : on ne référence que les colonnes
        // réellement présentes sur cette install (selon la version du module
        // Common Service, certaines colonnes peuvent manquer — ex: cd_channel_name).
        $cols     = coolstats_breakdown_get_mo_columns($db, $p);
        $hasChan  = in_array('channel',         $cols, true);
        $hasSales = in_array('sales_channel',   $cols, true);
        $hasCdCn  = in_array('cd_channel_name', $cols, true);

        $whens = array("WHEN mo.id_order IS NULL THEN '_direct'");
        if ($hasChan) {
            $whens[] = "WHEN mo.channel = 'MFN' THEN 'amazon_fbm'";
            $whens[] = "WHEN mo.channel = 'AFN' THEN 'amazon_fba'";
        }
        if ($hasCdCn && $hasSales) {
            $whens[] = "WHEN mo.cd_channel_name IS NOT NULL OR mo.sales_channel = 'CDISFR' THEN 'cdiscount'";
        } elseif ($hasCdCn) {
            $whens[] = "WHEN mo.cd_channel_name IS NOT NULL THEN 'cdiscount'";
        } elseif ($hasSales) {
            $whens[] = "WHEN mo.sales_channel = 'CDISFR' THEN 'cdiscount'";
        }
        if ($hasSales) {
            $whens[] = "WHEN mo.sales_channel = 'decathlon.eu'  THEN 'decathlon_fbm'";
            $whens[] = "WHEN mo.sales_channel = 'decathlon.eu2' THEN 'decathlon_fbd'";
        }
        $labelExpr = "CASE\n            " . implode("\n            ", $whens) . "\n            ELSE 'other'\n        END";
        $joinExpr  = "LEFT JOIN {$p}marketplace_orders mo ON mo.id_order = o.id_order";
    } else { // shoppingfeed_order
        // name_marketplace direct, NULL/'' → vente directe
        $labelExpr = "COALESCE(NULLIF(sf.name_marketplace, ''), '_direct')";
        $joinExpr  = "LEFT JOIN {$p}shoppingfeed_order sf ON sf.id_order = o.id_order";
    }

    $sql = "SELECT
        {$labelExpr}                AS marketplace_key,
        COUNT(DISTINCT o.id_order)  AS nb_orders,
        SUM(o.total_paid_tax_incl)  AS revenue
    FROM {$p}orders o
    {$joinExpr}
    {$countryJoin}
    WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
    AND {$valid}{$productWhere}
    GROUP BY marketplace_key
    ORDER BY revenue DESC";

    $rows = $db->executeS($sql);
    $rows = is_array($rows) ? $rows : array();

    $totalOrders  = 0;
    $totalRevenue = 0.0;
    foreach ($rows as $r) {
        $totalOrders  += (int) $r['nb_orders'];
        $totalRevenue += (float) $r['revenue'];
    }

    $module = Module::getInstanceByName('coolstats');
    $labelDirect = $module ? $module->l('Vente directe') : 'Vente directe';
    $labelOther  = $module ? $module->l('Autre canal')   : 'Autre canal';

    $out = array();
    foreach ($rows as $r) {
        $key       = (string) $r['marketplace_key'];
        $isDirect  = ($key === '_direct');
        $isOther   = ($key === 'other');
        $orders    = (int) $r['nb_orders'];
        $revenue   = round((float) $r['revenue'], 2);
        $aov       = $orders > 0 ? round($revenue / $orders, 2) : 0.0;

        if ($isDirect)      { $label = $labelDirect; }
        elseif ($isOther)   { $label = $labelOther; }
        else                { $label = coolstats_breakdown_pretty_label($key); }

        $out[] = array(
            'key'         => $key,
            'label'       => $label,
            'is_direct'   => $isDirect,
            'is_other'    => $isOther,
            'orders'      => $orders,
            'revenue'     => $revenue,
            'aov'         => $aov,
            'pct_orders'  => $totalOrders  > 0 ? round(($orders  / $totalOrders)  * 100, 1) : 0,
            'pct_revenue' => $totalRevenue > 0 ? round(($revenue / $totalRevenue) * 100, 1) : 0,
        );
    }

    return array(
        'rows'             => $out,
        'totals'           => array(
            'orders'  => $totalOrders,
            'revenue' => round($totalRevenue, 2),
            'aov'     => $totalOrders > 0 ? round($totalRevenue / $totalOrders, 2) : 0.0,
        ),
        'source'           => $source,
        'active_channels'  => isset($params['channels']) && is_array($params['channels']) ? $params['channels'] : array(),
        'period_from'      => $params['date_from'],
        'period_to'        => $params['date_to'],
    );
}

/**
 * Détecte quelle table marketplace est disponible.
 * Préférence : marketplace_orders (Common Service / Mirakl-like) car granulaire
 * sur les sous-canaux Amazon FBA/FBM et Decathlon FBM/FBD. Fallback ShoppingFeed.
 *
 * @return string|null 'marketplace_orders', 'shoppingfeed_order', ou null
 */
function coolstats_breakdown_detect_source($db, $prefix)
{
    static $cached = null;
    if ($cached !== null) return $cached === '' ? null : $cached;

    $candidates = array('marketplace_orders', 'shoppingfeed_order');
    foreach ($candidates as $name) {
        $tableName = $prefix . $name;
        $exists = (bool) $db->getValue(
            "SELECT COUNT(*) FROM information_schema.tables
             WHERE table_schema = DATABASE() AND table_name = '" . pSQL($tableName) . "'"
        );
        if ($exists) {
            $cached = $name;
            return $name;
        }
    }
    $cached = '';
    return null;
}

/**
 * Liste les colonnes présentes dans nc_marketplace_orders sur cette install.
 * Cache la lookup en mémoire pour ne pas refrapper information_schema sur
 * chaque appel.
 *
 * @return string[]
 */
function coolstats_breakdown_get_mo_columns($db, $prefix)
{
    static $cached = null;
    if ($cached !== null) return $cached;

    $tableName = $prefix . 'marketplace_orders';
    $rows = $db->executeS(
        "SELECT column_name FROM information_schema.columns
         WHERE table_schema = DATABASE() AND table_name = '" . pSQL($tableName) . "'"
    );
    $cols = array();
    if (is_array($rows)) {
        foreach ($rows as $r) {
            // MySQL renvoie column_name en lower mais selon les versions ça peut
            // être COLUMN_NAME en upper — on couvre les 2.
            $name = isset($r['column_name']) ? $r['column_name']
                  : (isset($r['COLUMN_NAME']) ? $r['COLUMN_NAME'] : '');
            if ($name !== '') $cols[] = strtolower($name);
        }
    }
    $cached = $cols;
    return $cols;
}

/**
 * Conversion du slug brut vers un label lisible.
 * Couvre les codes CASE de marketplace_orders + les slugs ShoppingFeed.
 *
 * Inconnu → on capitalise simplement.
 */
function coolstats_breakdown_pretty_label($raw)
{
    static $map = array(
        // Codes canaux (module Common Service)
        'amazon_fbm'      => 'Amazon FBM',
        'amazon_fba'      => 'Amazon FBA',
        'cdiscount'       => 'Cdiscount',
        'decathlon_fbm'   => 'Decathlon FBM',
        'decathlon_fbd'   => 'Decathlon FBD',
        // ShoppingFeed slugs courants
        'amazon'          => 'Amazon',
        'rakuten'         => 'Rakuten',
        'rakuten_fr'      => 'Rakuten FR',
        'fnac'            => 'Fnac',
        'fnacmp'          => 'Fnac',
        'fnac_dartymp'    => 'Fnac/Darty',
        'darty'           => 'Darty',
        'leroymerlin'     => 'Leroy Merlin',
        'manomano'        => 'ManoMano',
        'mirakl'          => 'Mirakl',
        'ebay'            => 'eBay',
        'aliexpress'      => 'AliExpress',
        'wish'            => 'Wish',
        'priceminister'   => 'PriceMinister',
        'la_redoute'      => 'La Redoute',
        'shopify'         => 'Shopify',
        'galerieslafayette' => 'Galeries Lafayette',
    );
    $key = strtolower(trim($raw));
    if (isset($map[$key])) {
        return $map[$key];
    }
    return ucwords(str_replace('_', ' ', $key));
}
