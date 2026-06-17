<?php
/**
 * CoolStats — Admin Controller
 *
 * Lit les filtres URL globaux et dispatche les sections déclaratives
 * (sections/{group}/{name}/section.json + query.php + view.tpl).
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

require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsContext.php';
require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsPrefs.php';

class AdminCoolStatsController extends ModuleAdminController
{
    /** @var CoolStatsContext */
    private $ctx;

    /** @var array{from:string,to:string} */
    private $dates;

    /** @var string|null */
    private $country;

    /** @var string[] */
    private $channels;

    /** @var string */
    private $compareMode;

    /** @var string|null Terme de recherche produit (filtre global) */
    private $product;

    public function __construct()
    {
        $this->bootstrap = true;
        $this->display = 'view';
        parent::__construct();

        $this->meta_title = $this->l('CoolStats');
        $this->dates       = CoolStatsHelpers::readDateRange();
        $this->country     = CoolStatsHelpers::readCountryFilter();
        $this->channels    = CoolStatsHelpers::readChannelsFilter();
        $this->compareMode = CoolStatsHelpers::readCompareMode();
        $this->product     = CoolStatsHelpers::readProductFilter();
        $this->ctx = new CoolStatsContext();
    }

    /**
     * Compatibilité traduction cross-version : PrestaShop 9 a retiré la méthode
     * legacy l() des contrôleurs admin. On délègue au natif sur 1.7/8, sinon on
     * passe par le traducteur Symfony (repli : chaîne source).
     */
    public function l($string, $class = null, $addslashes = false, $htmlentities = true)
    {
        if (method_exists(get_parent_class($this), 'l')) {
            return parent::l($string, $class, $addslashes, $htmlentities);
        }
        if (method_exists($this, 'trans')) {
            return $this->trans($string, array(), 'Modules.Coolstats.Admin');
        }

        return $string;
    }

    public function initContent()
    {
        if (Tools::getValue('ajax')) {
            $this->dispatchAjax((string) Tools::getValue('action'));
            return;
        }

        if (Tools::getValue('lite_display')) {
            $this->renderDashboard(true);
            die();
        }

        parent::initContent();
        $this->renderDashboard(false);
    }

    /**
     * @return array params communs passés à toutes les sections.
     */
    private function getSectionParams()
    {
        return array(
            'date_from'    => $this->dates['from'],
            'date_to'      => $this->dates['to'],
            'country'      => $this->country,
            'channels'     => $this->channels,
            'compare_with' => $this->compareMode,
            'product'      => $this->product,
        );
    }

    private function renderDashboard($liteDisplay)
    {
        $tDashStart = microtime(true);
        $sections = $this->loadSections();
        $sectionsHtml = $this->renderSections($sections);
        $tDashTotal = (microtime(true) - $tDashStart) * 1000;

        // Métadonnées de toutes les sections disponibles (pour la modale "Personnaliser" côté JS).
        $available = $this->listAvailableSections();
        $requiredIds = array();
        $sectionsMeta = array();
        foreach ($available as $s) {
            $sectionsMeta[$s['id']] = array(
                'title'    => isset($s['title']) ? $s['title'] : $s['id'],
                'order'    => isset($s['order']) ? (int) $s['order'] : 100,
                'required' => !empty($s['required']),
            );
            if (!empty($s['required'])) {
                $requiredIds[] = $s['id'];
            }
        }
        // Sections actuellement absentes du dashboard (désactivées par l'utilisateur).
        $activeIds = array();
        foreach ($sections as $s) $activeIds[] = $s['id'];
        $missingSections = array_values(array_diff(array_keys($sectionsMeta), $activeIds));

        $this->context->smarty->assign(array(
            'cs_brand_name'    => Configuration::get('COOLSTATS_BRAND_NAME') ?: 'CoolStats',
            'cs_visual_theme'  => Configuration::get('COOLSTATS_VISUAL_THEME') ?: 'aurora',
            'cs_logo_print_png'=> $this->getPrintLogoPng(),
            'cs_employee_firstname' => ($this->context->employee && $this->context->employee->firstname) ? $this->context->employee->firstname : '',
            'cs_module_path'   => $this->module->getPathUri(),
            'cs_lite_display'  => $liteDisplay,
            'cs_date_from'     => $this->dates['from'],
            'cs_date_to'       => $this->dates['to'],
            'cs_country'       => $this->country,
            'cs_channels'      => $this->channels,
            'cs_compare_mode'  => $this->compareMode,
            'cs_product'       => $this->product,
            'cs_zm40_url'      => Zm40Common::siteUrl('coolstats', 'footer'),
            'cs_current_date'  => $this->formatFrenchDate(),
            'cs_current_date_numeric' => date('d.m.y') . ' · ' . date('H:i'),
            'cs_version'       => $this->module->version,
            'cs_context'         => $this->ctx->debug(),
            'cs_sections_html'   => $sectionsHtml,
            'cs_required_sections'   => json_encode($requiredIds),
            'cs_sections_meta_json'  => json_encode($sectionsMeta),
            'cs_missing_sections_json' => json_encode($missingSections),
            'cs_auto_refresh_min'    => (int) Configuration::get('COOLSTATS_AUTO_REFRESH_INTERVAL'),
            'cs_debug'               => (int) Configuration::get('COOLSTATS_DEBUG'),
            'cs_pdf_sections_json'   => $this->getPdfSectionsJson($sectionsMeta),
            'cs_perf_timings'        => $this->perfTimings,
            'cs_perf_dash_total'     => $tDashTotal,
        ));

        $tplPath = _PS_MODULE_DIR_ . 'coolstats/views/templates/admin/dashboard.tpl';

        if ($liteDisplay) {
            echo $this->context->smarty->fetch($tplPath);
        } else {
            $this->context->smarty->assign('content', $this->context->smarty->fetch($tplPath));
        }
    }

    /**
     * Liste des sections incluses dans l'export PDF.
     * Si la config est vide → toutes les sections sont incluses par défaut.
     */
    /**
     * Format de date court à la française : "12 mai · 12:18".
     */
    private function formatFrenchDate()
    {
        $months = array(1=>'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.');
        $monthsLong = array(1=>'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre');
        $m = (int) date('n');
        return (int) date('j') . ' ' . $monthsLong[$m] . ' · ' . date('H:i');
    }

    /**
     * Retourne le nom de fichier PNG du logo à utiliser pour l'export PDF / print.
     * Le print force le mode "light" donc on prend la variante claire (Aurora a un seul PNG).
     */
    private function getPrintLogoPng()
    {
        $theme = Configuration::get('COOLSTATS_VISUAL_THEME') ?: 'aurora';
        $map = array(
            'cozy'      => 'logo-cozy-light-64.png',
            'aurora'    => 'logo-aurora-64.png',
            'editorial' => 'logo-editorial-light-64.png',
            'brutalist' => 'logo-brutalist-light-64.png',
            'terminal'  => 'logo-terminal-light-64.png',
        );
        return isset($map[$theme]) ? $map[$theme] : 'logo-aurora-64.png';
    }

    private function getPdfSectionsJson(array $sectionsMeta)
    {
        $raw = (string) Configuration::get('COOLSTATS_PDF_SECTIONS');
        if ($raw === '') {
            return json_encode(array_keys($sectionsMeta));
        }
        $list = json_decode($raw, true);
        if (!is_array($list)) {
            return json_encode(array_keys($sectionsMeta));
        }
        return json_encode(array_values($list));
    }

    /**
     * Scan /sections/{group}/{name}/section.json et retourne les manifests filtrés.
     *
     * @return array<int,array> Manifests triés par "order" croissant.
     */
    private function loadSections()
    {
        $base = _PS_MODULE_DIR_ . 'coolstats/sections/';
        $groups = array('common', 'marketplace', 'native');
        $sections = array();
        $prefs = CoolStatsPrefs::getCurrent();

        foreach ($groups as $group) {
            $groupDir = $base . $group . '/';
            if (!is_dir($groupDir)) {
                continue;
            }
            foreach (scandir($groupDir) as $entry) {
                if ($entry === '.' || $entry === '..') {
                    continue;
                }
                if (!is_dir($groupDir . $entry)) {
                    continue;
                }
                $manifestPath = $groupDir . $entry . '/section.json';
                if (!is_file($manifestPath)) {
                    continue;
                }
                $manifest = json_decode((string) file_get_contents($manifestPath), true);
                if (!is_array($manifest) || empty($manifest['id'])) {
                    continue;
                }
                if (!$this->ctx->shouldRenderSection($manifest)) {
                    continue;
                }

                // Override de l'ordre par th\xc3\xa8me si le manifest le sp\xc3\xa9cifie.
                $activeTheme = CoolStatsPrefs::getActiveTheme();
                if (isset($manifest['order_by_theme'][$activeTheme])) {
                    $manifest['order'] = (float) $manifest['order_by_theme'][$activeTheme];
                }

                // Override avec les pr\xc3\xa9f\xc3\xa9rences utilisateur (sauf required).
                $isRequired = !empty($manifest['required']);
                if (!$isRequired && isset($prefs[$manifest['id']])) {
                    $manifest['enabled'] = $prefs[$manifest['id']]['enabled'] ? true : false;
                    $manifest['order']   = $prefs[$manifest['id']]['display_order'];
                }
                if (!$isRequired && empty($manifest['enabled'])) {
                    continue;
                }

                $manifest['_dir']   = $groupDir . $entry . '/';
                $manifest['_group'] = $group;
                $sections[] = $manifest;
            }
        }

        usort($sections, function ($a, $b) {
            $oa = isset($a['order']) ? (float) $a['order'] : 100.0;
            $ob = isset($b['order']) ? (float) $b['order'] : 100.0;
            return $oa <=> $ob;
        });

        return $sections;
    }

    /**
     * Liste toutes les sections **applicables au contexte courant** (avant filtrage prefs).
     * Utilisé pour la modale "Personnaliser" qui doit afficher toutes les sections actuelles.
     *
     * @return array<int,array> Manifests bruts (sans application des prefs).
     */
    private function listAvailableSections()
    {
        $base = _PS_MODULE_DIR_ . 'coolstats/sections/';
        $groups = array('common', 'marketplace', 'native');
        $sections = array();
        foreach ($groups as $group) {
            $groupDir = $base . $group . '/';
            if (!is_dir($groupDir)) continue;
            foreach (scandir($groupDir) as $entry) {
                if ($entry === '.' || $entry === '..' || !is_dir($groupDir . $entry)) continue;
                $manifestPath = $groupDir . $entry . '/section.json';
                if (!is_file($manifestPath)) continue;
                $manifest = json_decode((string) file_get_contents($manifestPath), true);
                if (!is_array($manifest) || empty($manifest['id'])) continue;
                if (!$this->ctx->shouldRenderSection($manifest)) continue;
                $sections[] = $manifest;
            }
        }
        usort($sections, function ($a, $b) {
            $oa = isset($a['order']) ? (float) $a['order'] : 100.0;
            $ob = isset($b['order']) ? (float) $b['order'] : 100.0;
            return $oa <=> $ob;
        });
        return $sections;
    }

    /** @var array<string,array{query:float,render:float,total:float}> Timings par section (debug) */
    private $perfTimings = array();

    private function renderSections(array $sections)
    {
        $html = '';
        $params = $this->getSectionParams();
        foreach ($sections as $s) {
            $html .= $this->renderOneSection($s, $params);
        }
        return $html;
    }

    /**
     * Render d'une seule section. Ré-utilisé pour le full render et pour l'AJAX refresh.
     * En mode debug : mesure query/render time et injecte un badge dans le HTML.
     */
    private function renderOneSection(array $manifest, array $params)
    {
        $debug = (int) Configuration::get('COOLSTATS_DEBUG') === 1;
        $tQueryStart = $debug ? microtime(true) : 0;

        $data = array();
        $queryFile = $manifest['_dir'] . 'query.php';
        if (is_file($queryFile)) {
            require_once $queryFile;
            $fn = 'coolstats_section_' . $manifest['id'];
            if (function_exists($fn)) {
                $data = $fn($this->ctx, $params);
            }
        }
        $tQueryEnd = $debug ? microtime(true) : 0;

        // Résolution par thème : on cherche d'abord view-{theme}.tpl, sinon fallback view.tpl
        $theme = Configuration::get('COOLSTATS_VISUAL_THEME') ?: 'aurora';
        $themedTpl = $manifest['_dir'] . 'view-' . $theme . '.tpl';
        $defaultTpl = $manifest['_dir'] . 'view.tpl';
        $tplFile = is_file($themedTpl) ? $themedTpl : $defaultTpl;
        if (!is_file($tplFile)) {
            return '';
        }
        // Override des titres pour Editorial : versions courtes "rapport trimestriel" (traduisibles)
        $editorialHeadline = null;
        if ($theme === 'editorial') {
            $module = $this->module;
            $editorialTitles = array(
                'customers'        => $module->l('Clientèle'),
                'top_products'     => $module->l('Catalogue'),
                'country_map'      => $module->l('Géographie'),
                'payment_breakdown'=> $module->l('Paiements'),
                'native_payment'   => $module->l('Paiements'),
                'orders_chart'     => $module->l('Tendance'),
                'recent_orders'    => $module->l('Commandes'),
                'recent_activity'  => $module->l('Activité'),
                'highlights'       => $module->l('Faits saillants'),
                'performance'      => $module->l('Transport'),
                'traffic'          => $module->l('Trafic'),
                'goals'            => $module->l('Objectifs'),
                'margins'          => $module->l('Marges'),
                'signups'          => $module->l('Conversion'),
                'abandoned_carts'  => $module->l('Paniers perdus'),
            );
            if (isset($editorialTitles[$manifest['id']])) {
                $manifest['title'] = $editorialTitles[$manifest['id']];
            }
            // Sous-titre éditorial sérif gros (traduisible)
            $editorialHeadlines = array(
                'customers'        => $module->l('La base s\'élargit, plus qu\'elle ne se fidélise.'),
                'top_products'     => $module->l('Les articles qui ont fait la période.'),
                'country_map'      => $module->l('La France, et puis l\'archipel.'),
                'payment_breakdown'=> $module->l('Comment vos clients vous paient.'),
                'native_payment'   => $module->l('Comment vos clients vous paient.'),
                'orders_chart'     => $module->l('La courbe sur la durée.'),
                'recent_orders'    => $module->l('Le détail, ligne à ligne.'),
                'recent_activity'  => $module->l('Le flux du jour.'),
                'highlights'       => $module->l('Les pépites du moment.'),
                'performance'      => $module->l('Combien on livre, et comment.'),
                'traffic'          => $module->l('Qui passe par chez vous.'),
                'goals'            => $module->l('Le cap du mois.'),
                'margins'          => $module->l('La marge, sans détour.'),
                'signups'          => $module->l('Du visiteur au client, le chemin.'),
                'abandoned_carts'  => $module->l('Ce qui aurait pu être.'),
            );
            $editorialHeadline = isset($editorialHeadlines[$manifest['id']]) ? $editorialHeadlines[$manifest['id']] : null;
        }
        $this->context->smarty->assign(array(
            'section'      => $manifest,
            'section_data' => $data,
            'cs_visual_theme' => $theme,
        ));
        $html = $this->context->smarty->fetch($tplFile);

        // Injection du sous-titre éditorial JUSTE APRÈS le .cs-section-header (avant le contenu).
        // On ne peut pas utiliser une regex simple : le section-header peut contenir des <div> imbriqués
        // (form-switch, gap-2, etc.). On compte les open/close de <div> pour trouver le vrai </div> fermant.
        if ($editorialHeadline !== null) {
            $html = $this->injectAfterSectionHeader(
                $html,
                '<div class="cs-ed-section-headline">' . htmlspecialchars($editorialHeadline, ENT_QUOTES, 'UTF-8') . '</div>'
            );
        }
        $tRenderEnd = $debug ? microtime(true) : 0;

        if ($debug && $tQueryStart > 0) {
            $qTime = ($tQueryEnd - $tQueryStart) * 1000;
            $rTime = ($tRenderEnd - $tQueryEnd) * 1000;
            $total = ($tRenderEnd - $tQueryStart) * 1000;
            $this->perfTimings[$manifest['id']] = array(
                'query'  => $qTime,
                'render' => $rTime,
                'total'  => $total,
            );
            // Couleur selon temps : <200ms vert, <800ms orange, >=800ms rouge
            $cls = $total < 200 ? 'cs-perf-ok' : ($total < 800 ? 'cs-perf-warn' : 'cs-perf-bad');
            $badge = sprintf(
                '<span class="cs-perf-badge %s" title="Query: %.0fms · Render: %.0fms">&#9201; %.0fms</span>',
                $cls, $qTime, $rTime, $total
            );
            // Injecte le badge juste après l'ouverture du wrapper section
            $html = preg_replace(
                '/(<div[^>]*data-cs-section=[^>]*>)/',
                '$1' . $badge,
                $html,
                1
            );
        }

        return $html;
    }

    /**
     * Récupère le récap des timings (vidé par accès).
     */
    /**
     * Injecte un fragment HTML juste après le </div> qui ferme le .cs-section-header.
     * Compte les ouvertures/fermetures de <div> pour trouver le bon closing tag
     * (un section-header peut contenir des divs imbriqués : form-switch, gap-2, etc.).
     */
    private function injectAfterSectionHeader($html, $fragment)
    {
        $pos = strpos($html, 'class="cs-section-header');
        if ($pos === false) return $html;
        // Trouve le > qui ferme la balise d'ouverture
        $openEnd = strpos($html, '>', $pos);
        if ($openEnd === false) return $html;
        $i = $openEnd + 1;
        $depth = 1;
        $len = strlen($html);
        while ($i < $len && $depth > 0) {
            $nextOpen  = stripos($html, '<div', $i);
            $nextClose = stripos($html, '</div>', $i);
            if ($nextClose === false) return $html;
            if ($nextOpen !== false && $nextOpen < $nextClose) {
                $depth++;
                $i = $nextOpen + 4;
            } else {
                $depth--;
                if ($depth === 0) {
                    $insertAt = $nextClose + 6; // après </div>
                    return substr($html, 0, $insertAt) . $fragment . substr($html, $insertAt);
                }
                $i = $nextClose + 6;
            }
        }
        return $html;
    }

    public function getPerfTimings()
    {
        return $this->perfTimings;
    }

    /**
     * Trouve un manifest par son id en scannant les groupes connus.
     */
    private function findSectionById($id)
    {
        $base = _PS_MODULE_DIR_ . 'coolstats/sections/';
        foreach (array('common', 'marketplace', 'native') as $group) {
            $groupDir = $base . $group . '/';
            if (!is_dir($groupDir)) {
                continue;
            }
            foreach (scandir($groupDir) as $entry) {
                if ($entry === '.' || $entry === '..' || !is_dir($groupDir . $entry)) {
                    continue;
                }
                $manifestPath = $groupDir . $entry . '/section.json';
                if (!is_file($manifestPath)) {
                    continue;
                }
                $manifest = json_decode((string) file_get_contents($manifestPath), true);
                if (is_array($manifest) && isset($manifest['id']) && $manifest['id'] === $id) {
                    $manifest['_dir']   = $groupDir . $entry . '/';
                    $manifest['_group'] = $group;
                    return $manifest;
                }
            }
        }
        return null;
    }

    /**
     * Routeur AJAX.
     *  - context : snapshot du contexte (debug)
     *  - section : retourne le HTML d'une section unique avec filtres URL appliqués
     */
    private function dispatchAjax($action)
    {
        switch ($action) {
            case 'context':
                header('Content-Type: application/json');
                echo json_encode($this->ctx->debug());
                die();
            case 'section':
                $id = (string) Tools::getValue('id');
                $manifest = $this->findSectionById($id);
                if (!$manifest || !$this->ctx->shouldRenderSection($manifest)) {
                    http_response_code(404);
                    header('Content-Type: application/json');
                    echo json_encode(array('error' => 'Section introuvable ou inactive : ' . $id));
                    die();
                }
                header('Content-Type: text/html; charset=utf-8');
                echo $this->renderOneSection($manifest, $this->getSectionParams());
                die();
            case 'saveSections':
                $this->ajaxSaveSections();
                return;
            case 'resetSections':
                $this->ajaxResetSections();
                return;
            case 'availableSections':
                header('Content-Type: application/json');
                echo json_encode($this->listAvailableSections());
                die();
            case 'setVisualTheme':
                $this->ajaxSetVisualTheme();
                die();
            case 'searchProducts':
                $this->ajaxSearchProducts();
                die();
            case 'getTopCategories':
                $this->ajaxGetTopCategories();
                die();
            case 'getTopReturns':
                $this->ajaxGetTopReturns();
                die();
            case 'getCarriersStats':
                $this->ajaxGetCarriersStats();
                die();
            case 'exportTopProducts':
                $this->ajaxExportTopProducts();
                die();
            case 'deleteAbandonedCart':
                $this->ajaxDeleteAbandonedCart();
                die();
            case 'testMatomo':
                $this->ajaxTestMatomo();
                die();
            case 'testGA4':
                $this->ajaxTestGA4();
                die();
            default:
                http_response_code(404);
                header('Content-Type: application/json');
                echo json_encode(array('error' => 'Action inconnue : ' . $action));
                die();
        }
    }

    private function ajaxSaveSections()
    {
        header('Content-Type: application/json');
        $employee = $this->context->employee;
        if (!$employee || !$employee->id) {
            http_response_code(403);
            echo json_encode(array('error' => 'Non authentifi\xc3\xa9'));
            die();
        }

        $payload = (string) file_get_contents('php://input');
        $data = json_decode($payload, true);
        if (!is_array($data) || empty($data['sections'])) {
            http_response_code(400);
            echo json_encode(array('error' => 'Payload invalide'));
            die();
        }

        // Whitelist : seules les sections existantes et non-required.
        $available = $this->listAvailableSections();
        $allowed = array();
        foreach ($available as $s) {
            if (empty($s['required'])) {
                $allowed[$s['id']] = true;
            }
        }

        $clean = array();
        foreach ($data['sections'] as $s) {
            if (empty($s['id']) || !isset($allowed[$s['id']])) continue;
            $clean[] = array(
                'id'            => $s['id'],
                'enabled'       => !empty($s['enabled']) ? 1 : 0,
                'display_order' => isset($s['display_order']) ? (int) $s['display_order'] : 100,
            );
        }

        $ok = CoolStatsPrefs::saveCurrent($clean);
        echo json_encode(array('ok' => (bool) $ok, 'count' => count($clean)));
        die();
    }

    private function ajaxResetSections()
    {
        header('Content-Type: application/json');
        $ok = CoolStatsPrefs::resetCurrent();
        echo json_encode(array('ok' => (bool) $ok));
        die();
    }

    /**
     * Change le thème visuel depuis le header du dashboard (persistance config,
     * comme l'onglet Apparence du BO). Le JS recharge ensuite la page.
     */
    private function ajaxSetVisualTheme()
    {
        header('Content-Type: application/json');
        $theme = (string) Tools::getValue('theme');
        $allowed = array('cozy', 'aurora', 'editorial', 'brutalist', 'terminal');
        if (!in_array($theme, $allowed, true)) {
            echo json_encode(array('ok' => false, 'error' => 'Thème inconnu'));
            die();
        }
        Configuration::updateValue('COOLSTATS_VISUAL_THEME', $theme);
        echo json_encode(array('ok' => true, 'theme' => $theme));
        die();
    }

    /**
     * Autocomplete catalogue : recherche par nom / référence / EAN (produit ET
     * déclinaison). Image cover-or-first. Sert la barre de recherche du header.
     * Paramètre : ?q= (>=2 chars). Retourne LIMIT 15 suggestions.
     */
    private function ajaxSearchProducts()
    {
        header('Content-Type: application/json');

        $term = trim((string) Tools::getValue('q', ''));
        if (Tools::strlen($term) < 2) {
            echo json_encode(array('products' => array()));
            die();
        }

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $idLang = (int) $this->context->language->id;
        $idShop = (int) $this->context->shop->id;
        $like = '%' . pSQL($term) . '%';
        $imageJoin = CoolStatsHelpers::getProductImageJoin('p.id_product', 'imgc');

        $rows = $db->executeS("SELECT
            p.id_product,
            p.reference,
            p.ean13,
            pl.name,
            imgc.id_image
        FROM {$p}product p
        LEFT JOIN {$p}product_lang pl ON pl.id_product = p.id_product AND pl.id_lang = {$idLang} AND pl.id_shop = {$idShop}
        LEFT JOIN {$p}product_attribute pa ON pa.id_product = p.id_product
        {$imageJoin}
        WHERE (pl.name LIKE '{$like}'
            OR p.reference LIKE '{$like}'
            OR p.ean13 LIKE '{$like}'
            OR pa.reference LIKE '{$like}'
            OR pa.ean13 LIKE '{$like}')
        GROUP BY p.id_product
        ORDER BY pl.name ASC
        LIMIT 15");
        $rows = is_array($rows) ? $rows : array();

        $linkObj = $this->context->link;
        $products = array();
        foreach ($rows as $r) {
            $idProduct = (int) $r['id_product'];
            $idImage = (int) $r['id_image'];
            $ref = (string) ($r['reference'] ?: '');
            $ean = (string) ($r['ean13'] ?: '');
            // Terme appliqué au filtre : la référence est la plus discriminante,
            // sinon l'EAN, sinon le nom.
            $applyTerm = $ref !== '' ? $ref : ($ean !== '' ? $ean : (string) $r['name']);
            $products[] = array(
                'id_product' => $idProduct,
                'name'       => (string) $r['name'],
                'reference'  => $ref,
                'ean13'      => $ean,
                'image'      => $idImage ? $linkObj->getImageLink('product', $idProduct . '-' . $idImage, 'small_default') : '',
                'term'       => $applyTerm,
            );
        }

        echo json_encode(array('products' => $products));
        die();
    }

    /**
     * Top 10 catégories (par catégorie par défaut du produit) sur la période.
     * Partage le sélecteur CA/Volume avec le Top produits (?sort=qty|revenue).
     * Respecte les filtres actifs (pays, canaux, recherche produit).
     */
    private function ajaxGetTopCategories()
    {
        header('Content-Type: application/json');

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $idLang = (int) $this->context->language->id;
        $idShop = (int) $this->context->shop->id;

        $sort = Tools::getValue('sort') === 'revenue' ? 'revenue' : 'qty';
        $orderBy = $sort === 'revenue' ? 'total_revenue' : 'total_qty';

        $dateWhere   = CoolStatsHelpers::getDateRangeFilter('o', $this->dates['from'], $this->dates['to']);
        $valid       = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        $countryJoin = CoolStatsHelpers::getCountryJoin($this->country, 'o');
        $channelsJoin = CoolStatsHelpers::getChannelsJoin($this->channels, 'o');
        $validWhere  = $valid ? (' AND ' . $valid) : '';

        // Filtre produit : appliqué au Top 10 (n'affiche que la catégorie du
        // produit recherché), PAS au total global → le % reste « part du total ».
        $productWhere = '';
        if ($this->product) {
            $line = CoolStatsHelpers::getProductLineMatchSQL($this->product, 'od');
            if ($line !== '') $productWhere = ' AND ' . $line;
        }

        // Tronc commun de jointures/filtres (hors produit).
        $commonFrom = "FROM {$p}order_detail od
            INNER JOIN {$p}orders o ON o.id_order = od.id_order
            LEFT JOIN {$p}product pr ON pr.id_product = od.product_id
            {$countryJoin}
            {$channelsJoin}
            WHERE {$dateWhere}
            {$validWhere}
            AND pr.id_category_default > 0";

        $rows = $db->executeS("SELECT
            pr.id_category_default AS id_category,
            MAX(cl.name) AS name,
            COUNT(DISTINCT od.product_id) AS product_count,
            SUM(od.product_quantity) AS total_qty,
            SUM(od.total_price_tax_incl) AS total_revenue
        FROM {$p}order_detail od
        INNER JOIN {$p}orders o ON o.id_order = od.id_order
        LEFT JOIN {$p}product pr ON pr.id_product = od.product_id
        LEFT JOIN {$p}category_lang cl ON cl.id_category = pr.id_category_default AND cl.id_lang = {$idLang} AND cl.id_shop = {$idShop}
        {$countryJoin}
        {$channelsJoin}
        WHERE {$dateWhere}
        {$validWhere}
        AND pr.id_category_default > 0
        {$productWhere}
        GROUP BY pr.id_category_default
        ORDER BY {$orderBy} DESC
        LIMIT 10");
        $rows = is_array($rows) ? $rows : array();

        $categories = array();
        $topQty = 0; $topRevenue = 0.0;
        foreach ($rows as $r) {
            $qty = (int) $r['total_qty'];
            $rev = round((float) $r['total_revenue'], 2);
            $topQty += $qty;
            $topRevenue += $rev;
            $categories[] = array(
                'id_category'   => (int) $r['id_category'],
                'name'          => (string) ($r['name'] ?: ('#' . (int) $r['id_category'])),
                'product_count' => (int) $r['product_count'],
                'total_qty'     => $qty,
                'total_revenue' => $rev,
            );
        }

        // Totaux globaux (toutes catégories, SANS filtre produit) pour calculer
        // la part du Top 10 / la part du produit recherché sur l'ensemble.
        $global = $db->getRow("SELECT
            SUM(od.product_quantity) AS global_qty,
            SUM(od.total_price_tax_incl) AS global_revenue
        {$commonFrom}");
        $globalQty = (int) ($global['global_qty'] ?? 0);
        $globalRevenue = round((float) ($global['global_revenue'] ?? 0), 2);

        echo json_encode(array(
            'categories' => $categories,
            'sort_mode'  => $sort,
            'totals'     => array(
                'top_qty'        => $topQty,
                'top_revenue'    => round($topRevenue, 2),
                'global_qty'     => $globalQty,
                'global_revenue' => $globalRevenue,
                'pct_qty'        => $globalQty > 0 ? round($topQty / $globalQty * 100, 1) : 0,
                'pct_revenue'    => $globalRevenue > 0 ? round($topRevenue / $globalRevenue * 100, 1) : 0,
            ),
        ));
        die();
    }

    /**
     * Produits les plus retournés, REGROUPÉS PAR COMMANDE.
     * - ?returns_type = refunded (défaut, état 7) | cancelled (état 6)
     * - Filtre sur la DATE DE TRANSITION vers l'état (order_history), pas la date
     *   de création de la commande.
     * - Renvoie orders[] groupés (en-tête commande + lignes articles).
     */
    private function ajaxGetTopReturns()
    {
        header('Content-Type: application/json');

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $idLang = (int) $this->context->language->id;

        $type = Tools::getValue('returns_type') === 'cancelled' ? 'cancelled' : 'refunded';
        if ($type === 'cancelled') {
            $states = trim((string) Configuration::get('COOLSTATS_RETURN_CANCELLED_STATES'));
            if ($states === '') $states = '6';
        } else {
            $states = trim((string) Configuration::get('COOLSTATS_RETURN_REFUNDED_STATES'));
            if ($states === '') $states = '7';
        }
        $states = implode(',', array_map('intval', explode(',', $states)));
        if ($states === '') $states = ($type === 'cancelled' ? '6' : '7');

        $from = pSQL($this->dates['from']) . ' 00:00:00';
        $to   = pSQL($this->dates['to']) . ' 23:59:59';
        $countryJoin = CoolStatsHelpers::getCountryJoin($this->country, 'o');
        $imageJoin = CoolStatsHelpers::getProductImageJoin('od.product_id', 'imgc');

        $productWhere = '';
        if ($this->product) {
            $pf = CoolStatsHelpers::getProductFilterWhereSQL($this->product, 'o');
            if ($pf !== '') $productWhere = ' AND ' . $pf;
        }

        $rows = $db->executeS("SELECT
            o.id_order,
            o.reference,
            o.current_state,
            osl.name AS state_name,
            ohx.state_date,
            od.id_order_detail,
            od.product_id,
            od.product_name,
            od.product_reference,
            COALESCE(NULLIF(pa.ean13, ''), p.ean13, '') AS ean13,
            od.product_quantity AS qty,
            od.total_price_tax_incl AS value,
            imgc.id_image
        FROM {$p}orders o
        INNER JOIN (
            SELECT id_order, MAX(date_add) AS state_date
            FROM {$p}order_history
            WHERE id_order_state IN ({$states})
            GROUP BY id_order
        ) ohx ON ohx.id_order = o.id_order
        INNER JOIN {$p}order_detail od ON od.id_order = o.id_order
        LEFT JOIN {$p}product p ON p.id_product = od.product_id
        LEFT JOIN {$p}product_attribute pa ON pa.id_product_attribute = od.product_attribute_id
        LEFT JOIN {$p}order_state_lang osl ON osl.id_order_state = o.current_state AND osl.id_lang = {$idLang}
        {$imageJoin}
        {$countryJoin}
        WHERE ohx.state_date BETWEEN '{$from}' AND '{$to}'
        AND o.current_state IN ({$states})
        {$productWhere}
        ORDER BY ohx.state_date DESC, o.id_order DESC, od.id_order_detail ASC
        LIMIT 300");
        $rows = is_array($rows) ? $rows : array();

        $linkObj = $this->context->link;
        $orderToken = Tools::getAdminTokenLite('AdminOrders');
        $productToken = Tools::getAdminTokenLite('AdminProducts');

        $orders = array();
        $seq = array();
        foreach ($rows as $r) {
            $idOrder = (int) $r['id_order'];
            if (!isset($orders[$idOrder])) {
                $seq[] = $idOrder;
                $orders[$idOrder] = array(
                    'id_order'    => $idOrder,
                    'reference'   => (string) $r['reference'],
                    'date'        => $r['state_date'] ? date('d/m/Y', strtotime($r['state_date'])) : '',
                    'state'       => (string) ($r['state_name'] ?: ''),
                    'bo_link'     => 'index.php?controller=AdminOrders&id_order=' . $idOrder . '&vieworder&token=' . $orderToken,
                    'total_qty'   => 0,
                    'total_value' => 0.0,
                    'products'    => array(),
                );
            }
            $idProduct = (int) $r['product_id'];
            $idImage = (int) $r['id_image'];
            $qty = (int) $r['qty'];
            $value = round((float) $r['value'], 2);
            $orders[$idOrder]['total_qty'] += $qty;
            $orders[$idOrder]['total_value'] = round($orders[$idOrder]['total_value'] + $value, 2);
            $orders[$idOrder]['products'][] = array(
                'name'      => (string) $r['product_name'],
                'reference' => (string) ($r['product_reference'] ?: ''),
                'ean13'     => (string) ($r['ean13'] ?: ''),
                'qty'       => $qty,
                'value'     => $value,
                'image'     => $idImage ? $linkObj->getImageLink('product', $idProduct . '-' . $idImage, 'small_default') : '',
                'bo_link'   => $idProduct ? ('index.php?controller=AdminProducts&id_product=' . $idProduct . '&updateproduct&token=' . $productToken) : '',
            );
        }

        $ordered = array();
        foreach ($seq as $idOrder) {
            $ordered[] = $orders[$idOrder];
        }

        echo json_encode(array(
            'orders'        => $ordered,
            'total_returns' => count($ordered),
            'type'          => $type,
            'date_from'     => date('d/m/Y', strtotime($this->dates['from'])),
            'date_to'       => date('d/m/Y', strtotime($this->dates['to'])),
        ));
        die();
    }

    /**
     * Export CSV du Top produits — respecte les filtres actifs (pays, dates, sort, limit).
     * Configurable via COOLSTATS_EXPORT_SEPARATOR et COOLSTATS_CSV_ENCODING.
     */
    private function ajaxExportTopProducts()
    {
        if (!function_exists('coolstats_section_top_products')) {
            require_once _PS_MODULE_DIR_ . 'coolstats/sections/common/top_products/query.php';
        }
        $data = coolstats_section_top_products($this->ctx, $this->getSectionParams());
        $products = isset($data['products']) ? $data['products'] : array();

        $sep = Configuration::get('COOLSTATS_EXPORT_SEPARATOR') ?: ';';
        if (strlen($sep) !== 1) $sep = ';';
        $encoding = Configuration::get('COOLSTATS_CSV_ENCODING') ?: 'utf-8';
        $sortMode = isset($data['sort_mode']) ? $data['sort_mode'] : 'qty';
        $limit    = isset($data['limit']) ? (int) $data['limit'] : 25;

        $filename = 'coolstats_top' . $limit . '_produits_' . $this->dates['from'] . '_' . $this->dates['to'] . '.csv';

        while (ob_get_level() > 0) { ob_end_clean(); }
        header('Content-Type: text/csv; charset=' . ($encoding === 'latin1' ? 'iso-8859-1' : 'utf-8'));
        header('Content-Disposition: attachment; filename="' . $filename . '"');
        header('Cache-Control: no-cache, no-store, must-revalidate');

        $out = fopen('php://output', 'w');
        if ($encoding === 'utf-8-bom') {
            fprintf($out, chr(0xEF) . chr(0xBB) . chr(0xBF));
        }

        $writeRow = function ($row) use ($out, $sep, $encoding) {
            if ($encoding === 'latin1') {
                $row = array_map(function ($v) { return @iconv('UTF-8', 'ISO-8859-1//TRANSLIT', (string) $v); }, $row);
            }
            fputcsv($out, $row, $sep);
        };

        $writeRow(array('Rang', 'ID Produit', 'Produit', 'Reference', 'EAN13', 'Quantite vendue', 'CA TTC'));
        foreach ($products as $i => $p) {
            $writeRow(array(
                $i + 1,
                $p['id_product'],
                $p['name'],
                $p['reference'],
                $p['ean13'],
                $p['total_qty'],
                number_format($p['total_revenue'], 2, ',', ''),
            ));
        }
        fclose($out);
    }

    /**
     * Supprime définitivement un panier abandonné (cart + cart_product).
     *
     * Guards :
     *   - Méthode POST uniquement
     *   - id_cart > 0
     *   - Le panier doit être réellement abandonné (pas de commande associée)
     *     pour éviter qu'un appel forgé ne casse une commande payée.
     *   - Le panier doit avoir plus de 2h (cohérent avec la définition section)
     *
     * Réponse JSON : { success, message, id_cart }
     */
    private function ajaxDeleteAbandonedCart()
    {
        header('Content-Type: application/json');

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(array('success' => false, 'message' => 'POST requis'));
            return;
        }

        $idCart = (int) Tools::getValue('id_cart', 0);
        if ($idCart <= 0) {
            http_response_code(400);
            echo json_encode(array('success' => false, 'message' => 'id_cart manquant ou invalide'));
            return;
        }

        $db = Db::getInstance();
        $p  = _DB_PREFIX_;

        // Vérif : le panier doit exister, n'avoir AUCUNE commande associée,
        // et avoir plus de 2h (filet de sécurité contre suppression d'un panier
        // en cours de checkout).
        $check = $db->getRow("SELECT c.id_cart, c.date_add,
                COALESCE((SELECT COUNT(*) FROM {$p}orders o WHERE o.id_cart = c.id_cart), 0) AS nb_orders
            FROM {$p}cart c
            WHERE c.id_cart = " . $idCart);

        if (!$check) {
            http_response_code(404);
            echo json_encode(array('success' => false, 'message' => 'Panier introuvable'));
            return;
        }
        if ((int) $check['nb_orders'] > 0) {
            http_response_code(409);
            echo json_encode(array('success' => false, 'message' => 'Ce panier est lié à une commande — suppression refusée.'));
            return;
        }
        if (strtotime($check['date_add']) > time() - 2 * 3600) {
            http_response_code(409);
            echo json_encode(array('success' => false, 'message' => 'Panier trop récent (< 2h) — suppression refusée.'));
            return;
        }

        // Suppression atomique cart_product puis cart.
        try {
            $db->execute("DELETE FROM {$p}cart_product WHERE id_cart = " . $idCart);
            $db->execute("DELETE FROM {$p}cart WHERE id_cart = " . $idCart);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(array('success' => false, 'message' => 'Erreur SQL : ' . $e->getMessage()));
            return;
        }

        echo json_encode(array(
            'success' => true,
            'message' => 'Panier #' . $idCart . ' supprimé',
            'id_cart' => $idCart,
        ));
    }

    /**
     * Test de connexion à Matomo : ne touche pas à la config persistée,
     * utilise les valeurs POST envoyées par le formulaire (preview avant save).
     */
    private function ajaxTestMatomo()
    {
        header('Content-Type: application/json');
        $url     = rtrim(trim((string) Tools::getValue('matomo_url')), '/');
        $token   = trim((string) Tools::getValue('matomo_token'));
        $siteId  = (int) Tools::getValue('matomo_site');

        if ($url === '' || $token === '' || $siteId <= 0) {
            echo json_encode(array('ok' => false, 'error' => 'Paramètres manquants'));
            return;
        }
        if (!preg_match('#^https?://#i', $url)) {
            echo json_encode(array('ok' => false, 'error' => 'URL invalide (doit commencer par http:// ou https://)'));
            return;
        }

        $call = function ($method) use ($url, $token, $siteId) {
            $body = http_build_query(array(
                'module'     => 'API',
                'method'     => $method,
                'idSite'     => $siteId,
                'format'     => 'json',
                'token_auth' => $token,
            ));
            $ctx = stream_context_create(array(
                'http' => array(
                    'method'        => 'POST',
                    'header'        => "Content-Type: application/x-www-form-urlencoded\r\n",
                    'content'       => $body,
                    'timeout'       => 6,
                    'ignore_errors' => true,
                    'user_agent'    => 'CoolStats/1.0 PrestaShop module',
                ),
            ));
            $raw = @file_get_contents($url . '/index.php', false, $ctx);
            return $raw === false ? null : json_decode($raw, true);
        };

        $version = $call('API.getMatomoVersion');
        if ($version === null) {
            echo json_encode(array('ok' => false, 'error' => 'Serveur Matomo injoignable (timeout ou URL incorrecte)'));
            return;
        }
        if (isset($version['result']) && $version['result'] === 'error') {
            echo json_encode(array('ok' => false, 'error' => 'Erreur Matomo : ' . (isset($version['message']) ? $version['message'] : 'authentification refusée')));
            return;
        }
        $site = $call('SitesManager.getSiteFromId');
        echo json_encode(array(
            'ok'             => true,
            'matomo_version' => isset($version['value']) ? $version['value'] : null,
            'site_name'      => is_array($site) && isset($site['name']) ? $site['name'] : null,
        ));
    }

    /**
     * Test connexion GA4 : utilise la config sauvée en base (le JSON est trop volumineux
     * et trop sensible pour transiter via la requête de test).
     */
    private function ajaxTestGA4()
    {
        header('Content-Type: application/json');
        require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsGA4TrafficProvider.php';
        $provider = new CoolStatsGA4TrafficProvider();

        $cfg = Configuration::getMultiple(array('COOLSTATS_GA4_PROPERTY_ID', 'COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'));
        if (empty($cfg['COOLSTATS_GA4_PROPERTY_ID']) || empty($cfg['COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'])) {
            echo json_encode(array('ok' => false, 'error' => 'Property ID et JSON service account requis. Sauvegardez d\'abord la config.'));
            return;
        }
        $sa = json_decode($cfg['COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'], true);
        if (!is_array($sa) || empty($sa['client_email']) || empty($sa['private_key'])) {
            echo json_encode(array('ok' => false, 'error' => 'JSON service account invalide (champs client_email/private_key manquants).'));
            return;
        }

        $token = $provider->getAccessToken();
        if (!$token) {
            echo json_encode(array('ok' => false, 'error' => 'Impossible d\'obtenir un access token Google. Vérifiez le JSON et que l\'API Analytics Data est activée.'));
            return;
        }

        // Tente une requête minimale runReport pour valider l'accès à la propriété
        $url = 'https://analyticsdata.googleapis.com/v1beta/properties/' . (int) $cfg['COOLSTATS_GA4_PROPERTY_ID'] . ':runReport';
        $body = json_encode(array(
            'dateRanges' => array(array('startDate' => '7daysAgo', 'endDate' => 'today')),
            'metrics'    => array(array('name' => 'sessions')),
            'limit'      => 1,
        ));
        $ctx = stream_context_create(array(
            'http' => array(
                'method'        => 'POST',
                'header'        => "Authorization: Bearer {$token}\r\nContent-Type: application/json\r\n",
                'content'       => $body,
                'timeout'       => 8,
                'ignore_errors' => true,
                'user_agent'    => 'CoolStats/1.0 PrestaShop module',
            ),
        ));
        $raw = @file_get_contents($url, false, $ctx);
        if ($raw === false) {
            echo json_encode(array('ok' => false, 'error' => 'API Google Analytics injoignable (timeout réseau).'));
            return;
        }
        $decoded = json_decode($raw, true);
        if (isset($decoded['error'])) {
            $msg = isset($decoded['error']['message']) ? $decoded['error']['message'] : 'Erreur API inconnue';
            echo json_encode(array('ok' => false, 'error' => 'GA4 : ' . $msg . ' — vérifiez que le service account a accès à la propriété (rôle Viewer).'));
            return;
        }
        echo json_encode(array(
            'ok'          => true,
            'property_id' => (int) $cfg['COOLSTATS_GA4_PROPERTY_ID'],
        ));
    }

    /**
     * Stats par transporteur (nb commandes, %, délai moyen d'expédition).
     */
    private function ajaxGetCarriersStats()
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $from = pSQL($this->dates['from']) . ' 00:00:00';
        $to   = pSQL($this->dates['to']) . ' 23:59:59';
        $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        $countryJoin = CoolStatsHelpers::getCountryJoin($this->country, 'o');

        // États "expédié" depuis la config (default 4) pour le calcul du délai d'expédition
        $shippedStates = trim((string) Configuration::get('COOLSTATS_SHIPPED_STATES'));
        $shippedStates = $shippedStates !== '' ? $shippedStates : '4';
        $shippedStates = implode(',', array_map('intval', explode(',', $shippedStates))) ?: '4';

        $rows = $db->executeS("SELECT
            o.id_carrier,
            COALESCE(NULLIF(ca.name, ''), 'Sans transporteur') AS carrier_name,
            COUNT(o.id_order) AS total_orders,
            AVG(DATEDIFF(oh_min.min_date, o.date_add)) AS avg_delay
        FROM {$p}orders o
        LEFT JOIN {$p}carrier ca ON ca.id_carrier = o.id_carrier
        LEFT JOIN (
            SELECT oh.id_order, MIN(oh.date_add) AS min_date
            FROM {$p}order_history oh
            WHERE oh.id_order_state IN ({$shippedStates})
            GROUP BY oh.id_order
        ) oh_min ON oh_min.id_order = o.id_order
        {$countryJoin}
        WHERE o.date_add BETWEEN '{$from}' AND '{$to}'
        AND {$valid}
        GROUP BY o.id_carrier, carrier_name
        ORDER BY total_orders DESC");
        $rows = is_array($rows) ? $rows : array();

        $totalOrders = 0;
        foreach ($rows as $r) $totalOrders += (int) $r['total_orders'];

        $carriers = array();
        foreach ($rows as $r) {
            $orders = (int) $r['total_orders'];
            $carriers[] = array(
                'id_carrier' => (int) $r['id_carrier'],
                'name'       => $r['carrier_name'],
                'orders'     => $orders,
                'pct_orders' => $totalOrders > 0 ? round(($orders / $totalOrders) * 100, 1) : 0,
                'avg_delay'  => $r['avg_delay'] !== null ? round((float) $r['avg_delay'], 1) : null,
            );
        }

        header('Content-Type: application/json');
        echo json_encode(array(
            'carriers'     => $carriers,
            'total_orders' => $totalOrders,
            'date_from'    => date('d/m/Y', strtotime($this->dates['from'])),
            'date_to'      => date('d/m/Y', strtotime($this->dates['to'])),
        ));
        die();
    }
}
