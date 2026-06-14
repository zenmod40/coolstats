<?php
/**
 * Factory pour les providers de trafic.
 * Choisit le provider actif selon la configuration et leur disponibilité réelle.
 *
 * Ordre d'enregistrement = ordre de priorité.
 * V1 : seul le provider natif PS est enregistré.
 * V2 : Matomo / GA4 / Plausible ajoutés via `register()`.
 *
 * Utilisation :
 *   $provider = CoolStatsTrafficFactory::getActive();
 *   if ($provider) { $kpi = $provider->getKpi($from, $to); }
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

require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsTrafficProvider.php';
require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsNativeTrafficProvider.php';
require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsMatomoTrafficProvider.php';
require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsGA4TrafficProvider.php';

class CoolStatsTrafficFactory
{
    /** @var CoolStatsTrafficProvider[] */
    private static $providers = null;

    /**
     * Enregistre les providers disponibles. Ordre = priorité (premier = défaut).
     *
     * @return CoolStatsTrafficProvider[]
     */
    public static function getProviders()
    {
        if (self::$providers === null) {
            self::$providers = array(
                new CoolStatsMatomoTrafficProvider(),
                new CoolStatsGA4TrafficProvider(),
                new CoolStatsNativeTrafficProvider(),
                // V3 : new CoolStatsPlausibleTrafficProvider(),
            );
        }
        return self::$providers;
    }

    /**
     * Provider explicitement sélectionné par l'utilisateur (config).
     * Pas de fallback automatique : le provider natif PrestaShop (statsdata) est trop peu fiable
     * (champ mobile_theme déprécié, OS lookup obsolète, pas de filtrage bots) pour être utilisé
     * par défaut. Le client doit explicitement opter pour un provider via la config BO.
     *
     * @return CoolStatsTrafficProvider|null null tant que rien n'est explicitement configuré.
     */
    public static function getActive()
    {
        $preferredId = (string) Configuration::get('COOLSTATS_TRAFFIC_PROVIDER');
        if ($preferredId === '' || $preferredId === 'none') {
            return null;
        }
        foreach (self::getProviders() as $p) {
            if ($p->getId() === $preferredId && $p->isAvailable()) {
                return $p;
            }
        }
        return null;
    }

    /**
     * Provider par ID (utile pour la page de config admin pour montrer un diagnostic
     * même si le provider n'est pas disponible).
     *
     * @return CoolStatsTrafficProvider|null
     */
    public static function getById($id)
    {
        foreach (self::getProviders() as $p) {
            if ($p->getId() === $id) return $p;
        }
        return null;
    }

    /**
     * Liste les providers + leur statut (label, available, reason, diagnostic).
     * Utile pour la page de config admin.
     */
    public static function listWithStatus()
    {
        $list = array();
        foreach (self::getProviders() as $p) {
            $list[] = array(
                'id'          => $p->getId(),
                'label'       => $p->getLabel(),
                'available'   => $p->isAvailable(),
                'reason'      => $p->getUnavailableReason(),
                'diagnostic'  => $p->getDiagnostic(),
            );
        }
        return $list;
    }
}
