<?php
/**
 * CoolStats Dashboard
 * Dashboard de statistiques moderne et adaptatif pour PrestaShop 1.7 / 8 / 9+.
 *
 * @author    ZM40 — Nicolas Michaud (Magic Garden)
 * @copyright 2026 Nicolas Michaud — ZM40 / Magic Garden
 * @license   GPL-3.0-or-later
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'coolstats/lib/zm40/Zm40Common.php';

class CoolStats extends Module
{
    /** Modules marketplace dont la présence active automatiquement le mode "hybride". */
    public static $marketplaceModules = array(
        'shoppingfeed',
        'shoppingflux',
        'commonservices',
        'lengow',
        'amazonmarketplace',
        'mkpfba',
        'ebay',
        'decathlonbe2bsync',
    );

    public function __construct()
    {
        $this->name = 'coolstats';
        $this->tab = 'administration';
        $this->version = '1.0.3';
        $this->author = 'ZM40';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('CoolStats Dashboard');
        $this->description = $this->l('Dashboard de statistiques moderne et adaptatif (vente directe + marketplaces).');
        $this->ps_versions_compliancy = array('min' => '1.7.0.0', 'max' => '9.99.99');
    }

    public function install()
    {
        if (!parent::install()
            || !$this->registerHook('displayBackOfficeHeader')
            || !$this->installTab()
            || !$this->installSchema()
        ) {
            return false;
        }

        // Branding
        Configuration::updateValue('COOLSTATS_BRAND_NAME', 'CoolStats');
        Configuration::updateValue('COOLSTATS_LOGO', '');
        Configuration::updateValue('COOLSTATS_VISUAL_THEME', 'aurora');            // aurora (default) | cozy | editorial | brutalist | terminal
        Configuration::updateValue('COOLSTATS_LOCALE', 'fr');

        // ZM40 Common — interrupteur réseau (check MAJ + feed modules), activé par défaut.
        Configuration::updateValue('ZM40_NET_ENABLED', 1);

        // Préférences runtime
        Configuration::updateValue('COOLSTATS_AUTO_REFRESH', 0);
        Configuration::updateValue('COOLSTATS_REFRESH_INTERVAL', 5);
        Configuration::updateValue('COOLSTATS_ORDERS_PER_PAGE', 25);
        Configuration::updateValue('COOLSTATS_EXPORT_SEPARATOR', ';');

        // Wizard premier lancement (à compléter par l'utilisateur)
        Configuration::updateValue('COOLSTATS_WIZARD_DONE', 0);
        Configuration::updateValue('COOLSTATS_VALID_STATES', '2,3,4,5,26,28');
        Configuration::updateValue('COOLSTATS_CANCELLED_STATES', '6,7');
        Configuration::updateValue('COOLSTATS_PAYMENT_INCLUDE', '');

        // Configs métier
        Configuration::updateValue('COOLSTATS_INCLUDE_SHIPPING_IN_CA', 1);   // CA = total_paid_tax_incl (avec shipping). Si 0 → on déduit shipping.
        Configuration::updateValue('COOLSTATS_EXCLUDE_FREE_ORDERS', 0);      // Si 1 → exclut les commandes à 0€ des KPI valides.
        Configuration::updateValue('COOLSTATS_INACTIVITY_DAYS', 90);         // Seuil "client inactif" (jours sans commande). Pour V2 (segments clients).

        // Configs UX et avancées
        Configuration::updateValue('COOLSTATS_DEFAULT_PERIOD', 'this_month');     // Période chargée par défaut au premier load.
        Configuration::updateValue('COOLSTATS_EXCLUDED_IPS', '');                  // 1 IP par ligne (filtrage trafic). Vide = aucune exclusion.
        Configuration::updateValue('COOLSTATS_AUTO_REFRESH_INTERVAL', 0);          // Minutes ; 0 = désactivé. Sinon 1, 5, 15.
        Configuration::updateValue('COOLSTATS_DEBUG', 0);                          // Mode debug : logs PHP + console JS.
        Configuration::updateValue('COOLSTATS_CSV_ENCODING', 'utf-8');             // utf-8 (default) | utf-8-bom | latin1
        Configuration::updateValue('COOLSTATS_TRAFFIC_PROVIDER', 'none');          // none (défaut) | native_ps | matomo | ga4 | plausible
        Configuration::updateValue('COOLSTATS_MATOMO_URL', '');
        Configuration::updateValue('COOLSTATS_MATOMO_TOKEN', '');
        Configuration::updateValue('COOLSTATS_MATOMO_SITE_ID', 0);
        Configuration::updateValue('COOLSTATS_GA4_PROPERTY_ID', 0);
        Configuration::updateValue('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON', '');

        // Objectifs mensuels (V1.1)
        Configuration::updateValue('COOLSTATS_GOAL_REVENUE', 0);                   // CA cible mensuel (€). 0 = pas d'objectif → section masquée.
        Configuration::updateValue('COOLSTATS_GOAL_ORDERS', 0);                    // Nb commandes cible mensuelles. 0 = pas d'objectif.

        return true;
    }

    public function uninstall()
    {
        $this->uninstallSchema();
        return parent::uninstall() && $this->uninstallTab();
    }

    private function installSchema()
    {
        $p = _DB_PREFIX_;
        $db = Db::getInstance();

        $sql = "CREATE TABLE IF NOT EXISTS `{$p}coolstats_section_prefs` (
            `id_pref` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `id_employee` INT UNSIGNED NOT NULL,
            `id_shop` INT UNSIGNED NOT NULL DEFAULT 1,
            `theme_id` VARCHAR(32) NOT NULL DEFAULT 'default',
            `section_id` VARCHAR(64) NOT NULL,
            `enabled` TINYINT(1) NOT NULL DEFAULT 1,
            `display_order` INT NOT NULL DEFAULT 100,
            `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id_pref`),
            UNIQUE KEY `unique_pref` (`id_employee`, `id_shop`, `theme_id`, `section_id`)
        ) ENGINE=" . _MYSQL_ENGINE_ . " DEFAULT CHARSET=utf8mb4;";
        if (!$db->execute($sql)) {
            return false;
        }

        // Migration : ajoute la colonne theme_id si la table existait déjà sans (upgrade 1.0.1 → 1.0.2)
        try {
            $hasCol = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '" . pSQL($p . 'coolstats_section_prefs') . "'
                AND COLUMN_NAME = 'theme_id'");
            if (!$hasCol) {
                $db->execute("ALTER TABLE `{$p}coolstats_section_prefs`
                    ADD COLUMN `theme_id` VARCHAR(32) NOT NULL DEFAULT 'default' AFTER `id_shop`");
                $db->execute("ALTER TABLE `{$p}coolstats_section_prefs`
                    DROP INDEX `unique_pref`,
                    ADD UNIQUE KEY `unique_pref` (`id_employee`, `id_shop`, `theme_id`, `section_id`)");
            }
        } catch (Exception $e) { /* non bloquant */ }

        // Index sur ps_connections.date_add : déclenché à la demande depuis le BO (onglet Avancé)
        // car ALTER TABLE peut prendre plusieurs minutes sur un gros historique → bloquerait l'install.
        return true;
    }

    /**
     * Crée l'index idx_coolstats_date_add sur ps_connections si absent.
     * À déclencher manuellement depuis le BO car potentiellement long sur gros volume.
     * @return array{status:string,message:string}
     */
    public function createConnectionsIndex()
    {
        $p = _DB_PREFIX_;
        $db = Db::getInstance();
        try {
            $hasTable = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.TABLES
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '" . pSQL($p . 'connections') . "'");
            if (!$hasTable) {
                return array('status' => 'warn', 'message' => 'Table ps_connections introuvable (module statsdata désactivé ?)');
            }
            $hasIndex = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '" . pSQL($p . 'connections') . "'
                AND INDEX_NAME = 'idx_coolstats_date_add'");
            if ($hasIndex) {
                return array('status' => 'ok', 'message' => 'Index déjà présent, rien à faire.');
            }
            $tStart = microtime(true);
            $db->execute("ALTER TABLE `{$p}connections` ADD INDEX `idx_coolstats_date_add` (`date_add`)");
            $elapsed = round(microtime(true) - $tStart, 1);
            return array('status' => 'ok', 'message' => 'Index créé en ' . $elapsed . 's. Les requêtes trafic seront plus rapides.');
        } catch (Exception $e) {
            return array('status' => 'error', 'message' => 'Erreur : ' . $e->getMessage());
        }
    }

    private function uninstallSchema()
    {
        $p = _DB_PREFIX_;
        return Db::getInstance()->execute("DROP TABLE IF EXISTS `{$p}coolstats_section_prefs`");
    }

    private function installTab()
    {
        // 1) Tab parent (cat\xc3\xa9gorie)
        $parent = new Tab();
        $parent->active = 1;
        $parent->class_name = 'AdminCoolStatsParent';
        $parent->id_parent = 0;
        $parent->module = $this->name;
        $parent->icon = 'bar_chart';
        foreach (Language::getLanguages(true) as $lang) {
            $parent->name[$lang['id_lang']] = 'CoolStats';
        }
        if (!$parent->add()) {
            return false;
        }

        // 2) Enfant : Dashboard (notre controller existant)
        $dashboard = new Tab();
        $dashboard->active = 1;
        $dashboard->class_name = 'AdminCoolStats';
        $dashboard->id_parent = (int) $parent->id;
        $dashboard->module = $this->name;
        $dashboard->icon = 'dashboard';
        foreach (Language::getLanguages(true) as $lang) {
            $dashboard->name[$lang['id_lang']] = 'Dashboard';
        }
        if (!$dashboard->add()) {
            return false;
        }

        // 3) Enfant : Configuration (controller qui redirige vers configure module)
        $config = new Tab();
        $config->active = 1;
        $config->class_name = 'AdminCoolStatsConfig';
        $config->id_parent = (int) $parent->id;
        $config->module = $this->name;
        $config->icon = 'settings';
        foreach (Language::getLanguages(true) as $lang) {
            $config->name[$lang['id_lang']] = 'Configuration';
        }
        return $config->add();
    }

    private function uninstallTab()
    {
        foreach (array('AdminCoolStats', 'AdminCoolStatsConfig', 'AdminCoolStatsParent') as $cls) {
            $idTab = (int) Tab::getIdFromClassName($cls);
            if ($idTab) {
                $tab = new Tab($idTab);
                $tab->delete();
            }
        }
        return true;
    }

    public function hookDisplayBackOfficeHeader()
    {
        // Cible uniquement le lien "Dashboard" (AdminCoolStats), pas Config ni Parent.
        // Ajoute lite_display=1 et target=_blank pour ouvrir le dashboard plein écran.
        return ''
            . '<script type="text/javascript">'
            . '$(document).ready(function() {'
            . '  $(\'a[href*="AdminCoolStats"]\').each(function() {'
            . '    var href = $(this).attr("href");'
            . '    if (!href) return;'
            . '    if (!/AdminCoolStats(?![A-Za-z])/.test(href)) return;'
            . '    if (href.indexOf("lite_display") === -1) {'
            . '      href += (href.indexOf("?") > -1 ? "&" : "?") + "lite_display=1";'
            . '      $(this).attr("href", href);'
            . '    }'
            . '    $(this).attr("target", "_blank");'
            . '  });'
            . '});'
            . '</script>';
    }

    public function getContent()
    {
        $confirmation = '';

        // Action ponctuelle : création de l'index ps_connections (perf trafic)
        if (Tools::isSubmit('submitCoolStatsCreateIndex')) {
            $res = $this->createConnectionsIndex();
            $confirmation = $res['message'];
        }

        if (Tools::isSubmit('submitCoolStatsConfig')) {
            $brand = trim((string) Tools::getValue('COOLSTATS_BRAND_NAME'));
            Configuration::updateValue('COOLSTATS_BRAND_NAME', $brand !== '' ? $brand : 'CoolStats');
            $visualTheme = (string) Tools::getValue('COOLSTATS_VISUAL_THEME');
            if (!in_array($visualTheme, array('cozy', 'aurora', 'editorial', 'brutalist', 'terminal'), true)) {
                $visualTheme = 'aurora';
            }
            Configuration::updateValue('COOLSTATS_VISUAL_THEME', $visualTheme);
            Configuration::updateValue('COOLSTATS_ORDERS_PER_PAGE', (int) Tools::getValue('COOLSTATS_ORDERS_PER_PAGE'));
            Configuration::updateValue('COOLSTATS_EXPORT_SEPARATOR', Tools::getValue('COOLSTATS_EXPORT_SEPARATOR'));
            Configuration::updateValue('COOLSTATS_COMPARE_DEFAULT', Tools::getValue('COOLSTATS_COMPARE_DEFAULT'));

            // Configs métier (toggles avec input hidden=0 pour gérer le cas décoché)
            Configuration::updateValue('COOLSTATS_INCLUDE_SHIPPING_IN_CA', (int) Tools::getValue('COOLSTATS_INCLUDE_SHIPPING_IN_CA'));
            Configuration::updateValue('COOLSTATS_EXCLUDE_FREE_ORDERS',    (int) Tools::getValue('COOLSTATS_EXCLUDE_FREE_ORDERS'));
            Configuration::updateValue('COOLSTATS_INACTIVITY_DAYS',        max(1, (int) Tools::getValue('COOLSTATS_INACTIVITY_DAYS')));

            // Nouvelles configs
            Configuration::updateValue('COOLSTATS_DEFAULT_PERIOD', Tools::getValue('COOLSTATS_DEFAULT_PERIOD'));
            Configuration::updateValue('COOLSTATS_EXCLUDED_IPS',   trim((string) Tools::getValue('COOLSTATS_EXCLUDED_IPS')));
            Configuration::updateValue('COOLSTATS_AUTO_REFRESH_INTERVAL', (int) Tools::getValue('COOLSTATS_AUTO_REFRESH_INTERVAL'));
            Configuration::updateValue('COOLSTATS_DEBUG',          (int) Tools::getValue('COOLSTATS_DEBUG'));
            Configuration::updateValue('COOLSTATS_CSV_ENCODING',   Tools::getValue('COOLSTATS_CSV_ENCODING'));

            // ZM40 Common — interrupteur réseau (toggle avec hidden=0 pour le décoché)
            Configuration::updateValue('ZM40_NET_ENABLED',         (int) Tools::getValue('ZM40_NET_ENABLED'));
            // Sauvegarde = rafraîchir le feed ZM40 (refetch au prochain rendu)
            Zm40Common::clearFeedCache();

            // Provider trafic (whitelist : none, native_ps, matomo, ga4, plausible)
            $tp = (string) Tools::getValue('COOLSTATS_TRAFFIC_PROVIDER');
            if (!in_array($tp, array('none', 'native_ps', 'matomo', 'ga4', 'plausible'), true)) {
                $tp = 'none';
            }
            Configuration::updateValue('COOLSTATS_TRAFFIC_PROVIDER', $tp);
            Configuration::updateValue('COOLSTATS_MATOMO_URL',     rtrim(trim((string) Tools::getValue('COOLSTATS_MATOMO_URL')), '/'));
            Configuration::updateValue('COOLSTATS_MATOMO_TOKEN',   trim((string) Tools::getValue('COOLSTATS_MATOMO_TOKEN')));
            Configuration::updateValue('COOLSTATS_MATOMO_SITE_ID', max(0, (int) Tools::getValue('COOLSTATS_MATOMO_SITE_ID')));
            Configuration::updateValue('COOLSTATS_GA4_PROPERTY_ID', max(0, (int) Tools::getValue('COOLSTATS_GA4_PROPERTY_ID')));
            // Service account JSON : validation minimale (parsable + client_email présent)
            $saJson = trim((string) Tools::getValue('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'));
            if ($saJson !== '') {
                $parsed = json_decode($saJson, true);
                if (is_array($parsed) && !empty($parsed['client_email']) && !empty($parsed['private_key'])) {
                    Configuration::updateValue('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON', $saJson);
                }
            } else {
                Configuration::updateValue('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON', '');
            }

            // Objectifs mensuels
            Configuration::updateValue('COOLSTATS_GOAL_REVENUE', max(0, (float) Tools::getValue('COOLSTATS_GOAL_REVENUE')));
            Configuration::updateValue('COOLSTATS_GOAL_ORDERS',  max(0, (int)   Tools::getValue('COOLSTATS_GOAL_ORDERS')));

            // Sections incluses dans l'export PDF (whitelist, vide = tout)
            $pdfSections = Tools::getValue('COOLSTATS_PDF_SECTIONS');
            if (!is_array($pdfSections)) {
                $pdfSections = array();
            }
            $pdfSections = array_values(array_map('strval', array_filter($pdfSections, 'strlen')));
            Configuration::updateValue('COOLSTATS_PDF_SECTIONS', json_encode($pdfSections));

            foreach (array('VALID', 'CANCELLED', 'SHIPPED', 'DELIVERED') as $key) {
                $name = 'COOLSTATS_' . $key . '_STATES';
                $val = Tools::getValue($name);
                if (is_array($val)) {
                    $val = implode(',', array_map('intval', $val));
                } else {
                    $val = (string) $val;
                }
                Configuration::updateValue($name, $val);
            }

            Configuration::updateValue('COOLSTATS_WIZARD_DONE', 1);
            $confirmation = $this->l('Configuration sauvegardée.');
        }

        require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsContext.php';
        $ctx = new CoolStatsContext();

        $stateGroups = array(
            array('key' => 'VALID',     'label' => 'États valides (KPI / CA)',
                  'help' => 'Si vide, tout sauf annulés.',
                  'selected' => $this->csvToArray(Configuration::get('COOLSTATS_VALID_STATES'))),
            array('key' => 'CANCELLED', 'label' => 'États annulés / remboursés',
                  'help' => 'Default PrestaShop : 6 (Annulé), 7 (Remboursé).',
                  'selected' => $this->csvToArray(Configuration::get('COOLSTATS_CANCELLED_STATES'))),
            array('key' => 'SHIPPED',   'label' => 'États expédiés',
                  'help' => 'Default PrestaShop : 4.',
                  'selected' => $this->csvToArray(Configuration::get('COOLSTATS_SHIPPED_STATES'))),
            array('key' => 'DELIVERED', 'label' => 'États livrés',
                  'help' => 'Default PrestaShop : 5.',
                  'selected' => $this->csvToArray(Configuration::get('COOLSTATS_DELIVERED_STATES'))),
        );

        $config = array(
            'COOLSTATS_BRAND_NAME'             => Configuration::get('COOLSTATS_BRAND_NAME') ?: 'CoolStats',
            'COOLSTATS_ORDERS_PER_PAGE'        => Configuration::get('COOLSTATS_ORDERS_PER_PAGE') ?: 25,
            'COOLSTATS_EXPORT_SEPARATOR'       => Configuration::get('COOLSTATS_EXPORT_SEPARATOR') ?: ';',
            'COOLSTATS_COMPARE_DEFAULT'        => Configuration::get('COOLSTATS_COMPARE_DEFAULT') ?: 'prev',
            'COOLSTATS_INCLUDE_SHIPPING_IN_CA' => (int) Configuration::get('COOLSTATS_INCLUDE_SHIPPING_IN_CA'),
            'COOLSTATS_EXCLUDE_FREE_ORDERS'    => (int) Configuration::get('COOLSTATS_EXCLUDE_FREE_ORDERS'),
            'COOLSTATS_INACTIVITY_DAYS'        => (int) (Configuration::get('COOLSTATS_INACTIVITY_DAYS') ?: 90),
            'COOLSTATS_DEFAULT_PERIOD'         => Configuration::get('COOLSTATS_DEFAULT_PERIOD') ?: 'this_month',
            'COOLSTATS_EXCLUDED_IPS'           => Configuration::get('COOLSTATS_EXCLUDED_IPS') ?: '',
            'COOLSTATS_AUTO_REFRESH_INTERVAL'  => (int) Configuration::get('COOLSTATS_AUTO_REFRESH_INTERVAL'),
            'COOLSTATS_DEBUG'                  => (int) Configuration::get('COOLSTATS_DEBUG'),
            'COOLSTATS_CSV_ENCODING'           => Configuration::get('COOLSTATS_CSV_ENCODING') ?: 'utf-8',
            'COOLSTATS_TRAFFIC_PROVIDER'       => Configuration::get('COOLSTATS_TRAFFIC_PROVIDER') ?: 'none',
            'COOLSTATS_MATOMO_URL'             => (string) Configuration::get('COOLSTATS_MATOMO_URL'),
            'COOLSTATS_MATOMO_TOKEN'           => (string) Configuration::get('COOLSTATS_MATOMO_TOKEN'),
            'COOLSTATS_MATOMO_SITE_ID'         => (int) Configuration::get('COOLSTATS_MATOMO_SITE_ID'),
            'COOLSTATS_GA4_PROPERTY_ID'        => (int) Configuration::get('COOLSTATS_GA4_PROPERTY_ID'),
            'COOLSTATS_GA4_SERVICE_ACCOUNT_JSON' => (string) Configuration::get('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'),
            'COOLSTATS_GOAL_REVENUE'           => (float) Configuration::get('COOLSTATS_GOAL_REVENUE'),
            'COOLSTATS_GOAL_ORDERS'            => (int)   Configuration::get('COOLSTATS_GOAL_ORDERS'),
            'COOLSTATS_VISUAL_THEME'           => Configuration::get('COOLSTATS_VISUAL_THEME') ?: 'aurora',
        );

        // ── Diagnostic trafic ──
        $trafficStatus = $this->getTrafficStatus();

        $statesMeta = $this->getOrderStatesWithMeta();
        $statesSelected = array(
            'VALID'     => $this->csvToArray(Configuration::get('COOLSTATS_VALID_STATES')),
            'CANCELLED' => $this->csvToArray(Configuration::get('COOLSTATS_CANCELLED_STATES')),
            'SHIPPED'   => $this->csvToArray(Configuration::get('COOLSTATS_SHIPPED_STATES')),
            'DELIVERED' => $this->csvToArray(Configuration::get('COOLSTATS_DELIVERED_STATES')),
        );

        $this->context->smarty->assign(array(
            'cs_module_version'  => $this->version,
            'cs_shop_name'       => Configuration::get('PS_SHOP_NAME'),
            'cs_form_action'     => $_SERVER['REQUEST_URI'],
            'cs_confirmation'    => $confirmation,
            'cs_dashboard_link'  => $this->context->link->getAdminLink('AdminCoolStats') . '&lite_display=1',
            'cs_ajax_link'       => $this->context->link->getAdminLink('AdminCoolStats') . '&ajax=1',
            'cs_module_path'     => $this->_path,
            'cs_mkp_modules'     => $ctx->getActiveMarketplaceModules(),
            'cs_mkp_modules_str' => implode(', ', $ctx->getActiveMarketplaceModules()),
            'cs_ps_version'      => _PS_VERSION_,
            'cs_state_groups'    => $stateGroups,
            'cs_order_states'    => $this->getOrderStatesForSelect(),
            'cs_states_meta'     => $statesMeta,
            'cs_states_selected' => $statesSelected,
            'cs_config'          => $config,
            'cs_traffic_status'  => $trafficStatus,
            'cs_statsdata_link'  => $this->context->link->getAdminLink('AdminModules') . '&configure=statsdata&module_name=statsdata',
            'cs_all_sections'    => $this->listAllSections(),
            'cs_multishop_ctx'   => $this->getMultishopContext(),
            'cs_pdf_selected'    => $this->getPdfSelected(),
            // ── ZM40 Common (footer + notice MAJ + bloc open source + autres modules) ──
            'zm40_net_enabled'   => Zm40Common::isNetEnabled() ? 1 : 0,
            'zm40_footer_html'   => Zm40Common::footer('CoolStats', $this->version, 'coolstats'),
            'zm40_update'        => Zm40Common::checkUpdate('coolstats', $this->version),
            'zm40_modules'       => Zm40Common::modulesFeed('coolstats'),
            'zm40_about_name'    => 'CoolStats',
            'zm40_about_license' => 'GPL v3',
            'zm40_about_github'  => Zm40Common::githubUrl('coolstats'),
            'zm40_about_site'    => Zm40Common::siteUrl('coolstats', 'panel', '/contact'),
            'zm40_about_modules' => Zm40Common::siteUrl('coolstats', 'panel', '/'),
        ));

        return $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    /**
     * Retourne le contexte boutique courant dans le BO :
     * - scope : 'shop' | 'group' | 'all'
     * - label : nom de la boutique/groupe
     * - is_multishop : true si la fonctionnalité multi-shop est active
     * Permet à la TPL d'afficher l'info à l'admin (configure quelle boutique ?).
     */
    private function getMultishopContext()
    {
        $isMultishop = Shop::isFeatureActive();
        $ctx = Shop::getContext();
        $info = array(
            'is_multishop'  => $isMultishop,
            'scope'         => 'shop',
            'label'         => '',
            'warn_all'      => false,
        );
        if (!$isMultishop) {
            return $info;
        }
        if ($ctx === Shop::CONTEXT_ALL) {
            $info['scope'] = 'all';
            $info['label'] = 'Toutes les boutiques';
            $info['warn_all'] = true;
        } elseif ($ctx === Shop::CONTEXT_GROUP) {
            $info['scope'] = 'group';
            $idGroup = Shop::getContextShopGroupID();
            $group = new ShopGroup($idGroup);
            $info['label'] = 'Groupe : ' . $group->name;
            $info['warn_all'] = true;
        } else {
            $info['scope'] = 'shop';
            $idShop = Shop::getContextShopID();
            $shop = new Shop($idShop);
            $info['label'] = $shop->name;
        }
        return $info;
    }

    private function listAllSections()
    {
        $base = _PS_MODULE_DIR_ . 'coolstats/sections/';
        $out = array();
        if (!is_dir($base)) return $out;
        foreach (scandir($base) as $group) {
            if ($group === '.' || $group === '..' || !is_dir($base . $group)) continue;
            foreach (scandir($base . $group) as $name) {
                if ($name === '.' || $name === '..') continue;
                $sectionDir = $base . $group . '/' . $name;
                if (!is_dir($sectionDir)) continue;
                $manifestPath = $sectionDir . '/section.json';
                if (!is_file($manifestPath)) continue;
                $manifest = json_decode((string) file_get_contents($manifestPath), true);
                if (!is_array($manifest) || empty($manifest['id'])) continue;
                $out[] = array(
                    'id'    => $manifest['id'],
                    'title' => isset($manifest['title']) ? $manifest['title'] : $manifest['id'],
                    'order' => isset($manifest['order']) ? (int) $manifest['order'] : 100,
                );
            }
        }
        usort($out, function ($a, $b) { return $a['order'] - $b['order']; });
        return $out;
    }

    private function getPdfSelected()
    {
        $raw = (string) Configuration::get('COOLSTATS_PDF_SECTIONS');
        if ($raw === '') return array();
        $list = json_decode($raw, true);
        return is_array($list) ? $list : array();
    }

    private function getOrderStatesForSelect()
    {
        $idLang = (int) Configuration::get('PS_LANG_DEFAULT');
        $states = OrderState::getOrderStates($idLang);
        $list = array();
        foreach ($states as $s) {
            $list[] = array(
                'id_state' => (int) $s['id_order_state'],
                'name'     => '#' . (int) $s['id_order_state'] . ' — ' . $s['name'],
            );
        }
        return $list;
    }

    /**
     * États avec métadonnées : couleur PrestaShop + nombre de commandes (12 derniers mois).
     * Utilisé par la matrice de mapping.
     */
    /**
     * Diagnostic de la collecte de trafic (table connections + module statsdata).
     */
    private function getTrafficStatus()
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;

        $hasTable = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = '" . pSQL($p . 'connections') . "'");

        $hasIndex = false;
        if ($hasTable) {
            $hasIndex = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '" . pSQL($p . 'connections') . "'
                AND INDEX_NAME = 'idx_coolstats_date_add'") > 0;
        }

        $statsdataInstalled = Module::isInstalled('statsdata');
        $statsdataActive = $statsdataInstalled && Module::isEnabled('statsdata');

        $totalSessions = 0;
        $firstSessionAt = null;
        $lastSessionAt = null;
        if ($hasTable) {
            $totalSessions  = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections");
            $firstSessionAt = $db->getValue("SELECT MIN(date_add) FROM {$p}connections");
            $lastSessionAt  = $db->getValue("SELECT MAX(date_add) FROM {$p}connections");
        }

        return array(
            'has_table'           => (bool) $hasTable,
            'has_index'           => $hasIndex,
            'statsdata_installed' => $statsdataInstalled,
            'statsdata_active'    => $statsdataActive,
            'total_sessions'      => $totalSessions,
            'first_session_at'    => $firstSessionAt,
            'last_session_at'     => $lastSessionAt,
        );
    }

    private function getOrderStatesWithMeta()
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $idLang = (int) Configuration::get('PS_LANG_DEFAULT');

        $rows = $db->executeS("SELECT
            os.id_order_state, os.color, osl.name
        FROM {$p}order_state os
        LEFT JOIN {$p}order_state_lang osl ON osl.id_order_state = os.id_order_state AND osl.id_lang = {$idLang}
        WHERE os.deleted = 0
        ORDER BY os.id_order_state ASC");

        // Compter les commandes par état sur les 12 derniers mois (volume représentatif sans coût excessif).
        $since = date('Y-m-d', strtotime('-12 months')) . ' 00:00:00';
        $counts = array();
        $countRows = $db->executeS("SELECT current_state, COUNT(*) AS n
            FROM {$p}orders
            WHERE date_add >= '" . pSQL($since) . "'
            GROUP BY current_state");
        if (is_array($countRows)) {
            foreach ($countRows as $r) {
                $counts[(int) $r['current_state']] = (int) $r['n'];
            }
        }

        $list = array();
        if (is_array($rows)) {
            foreach ($rows as $s) {
                $id = (int) $s['id_order_state'];
                $list[] = array(
                    'id_state' => $id,
                    'name'     => $s['name'] ?: ('État #' . $id),
                    'color'    => $s['color'] ?: '#9ca3af',
                    'count'    => isset($counts[$id]) ? $counts[$id] : 0,
                );
            }
        }
        return $list;
    }

    private function csvToArray($csv)
    {
        $csv = trim((string) $csv);
        if ($csv === '') return array();
        return array_values(array_filter(array_map('intval', explode(',', $csv))));
    }

}
