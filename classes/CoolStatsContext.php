<?php
/**
 * CoolStatsContext — détecte l'environnement de la boutique et expose
 * les capacités du dashboard (mode "vente directe pure" vs "hybride MKP").
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

class CoolStatsContext
{
    /** @var array<string,bool> Modules MKP détectés (nom → enabled) */
    private $detectedModules = array();

    /** @var bool|null Cache : présence de tables MKP avec données */
    private $hasMkpTablesCache = null;

    /** @var array<string> */
    private $mkpModules;

    public function __construct(array $mkpModules = array())
    {
        $this->mkpModules = !empty($mkpModules) ? $mkpModules : CoolStats::$marketplaceModules;
        $this->scanModules();
    }

    /**
     * Scan une seule fois la liste des modules MKP installés/actifs.
     */
    private function scanModules()
    {
        foreach ($this->mkpModules as $name) {
            if (Module::isInstalled($name) && Module::isEnabled($name)) {
                $this->detectedModules[$name] = true;
            }
        }
    }

    /**
     * @return bool true si au moins un module marketplace est actif, OU
     *              fallback : si une table marketplace contient des données récentes.
     */
    public function hasMarketplaces()
    {
        if (!empty($this->detectedModules)) {
            return true;
        }
        return $this->hasMarketplaceDataInTables();
    }

    /**
     * @return string[] Liste des IDs de modules MKP détectés et actifs.
     */
    public function getActiveMarketplaceModules()
    {
        return array_keys($this->detectedModules);
    }

    public function hasShoppingFeed()      { return isset($this->detectedModules['shoppingfeed']); }
    public function hasShoppingFlux()      { return isset($this->detectedModules['shoppingflux']); }
    public function hasCommonServices()    { return isset($this->detectedModules['commonservices']); }
    public function hasLengow()            { return isset($this->detectedModules['lengow']); }
    public function hasAmazonMkp()         { return isset($this->detectedModules['amazonmarketplace']) || isset($this->detectedModules['mkpfba']); }
    public function hasEbay()              { return isset($this->detectedModules['ebay']); }
    public function hasDecathlonSync()     { return isset($this->detectedModules['decathlonbe2bsync']); }

    /**
     * Détecte si l'auteur a custom une table MKP côté DB (cas où le module
     * a été désinstallé mais les données persistent, ou schéma maison).
     */
    public function hasMarketplaceDataInTables()
    {
        if ($this->hasMkpTablesCache !== null) {
            return $this->hasMkpTablesCache;
        }

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $candidates = array(
            _DB_PREFIX_ . 'marketplace_orders',
            _DB_PREFIX_ . 'shoppingfeed_order',
            _DB_PREFIX_ . 'sfx_order',
            _DB_PREFIX_ . 'lengow_orders',
        );

        // INFORMATION_SCHEMA \xe9vite "SHOW TABLES LIKE ... LIMIT 1" (incompatible MariaDB).
        $names = "'" . implode("','", array_map('pSQL', $candidates)) . "'";
        $exists = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME IN ({$names})");

        $this->hasMkpTablesCache = $exists > 0;
        return $this->hasMkpTablesCache;
    }

    /**
     * Décide quelles sections sont actives selon le contexte.
     *
     * @return array<string,bool> id_section → enabled
     */
    public function getSectionContextFlags()
    {
        $hasMkp = $this->hasMarketplaces();
        return array(
            'has_marketplaces' => $hasMkp,
            'native_only'      => !$hasMkp,
        );
    }

    /**
     * Teste si une section doit être affichée selon son manifest.
     *
     * @param array $manifest section.json décodé
     * @return bool
     */
    public function shouldRenderSection(array $manifest)
    {
        if (isset($manifest['enabled']) && !$manifest['enabled']) {
            return false;
        }
        $context = isset($manifest['context']) ? $manifest['context'] : 'always';
        switch ($context) {
            case 'native_only':
                return !$this->hasMarketplaces();
            case 'marketplace_only':
                return $this->hasMarketplaces();
            case 'always':
            default:
                return true;
        }
    }

    /**
     * Snapshot du contexte utile pour debug / page de config.
     */
    public function debug()
    {
        return array(
            'detected_modules'     => $this->getActiveMarketplaceModules(),
            'has_marketplaces'     => $this->hasMarketplaces(),
            'has_mkp_tables'       => $this->hasMarketplaceDataInTables(),
            'ps_version'           => _PS_VERSION_,
        );
    }
}
