<?php
/**
 * Factory pour les providers de trafic.
 * Choisit le provider actif selon la configuration et leur disponibilité réelle.
 *
 * Ordre d'enregistrement = ordre de priorité.
 * V1 : seul le provider natif PS est enregistré.
 *
 * Utilisation :
 *   $provider = CoolStatsTrafficFactory::getById(Configuration::get('COOLSTATS_TRAFFIC_PROVIDER'));
 *   if ($provider && $provider->isAvailable()) { $kpi = $provider->getKpi($from, $to); }
 *
 * @author    ZM40 — Nicolas Michaud (Magic Garden)
 * @copyright 2026 Nicolas Michaud — ZM40 / Magic Garden
 * @license   https://opensource.org/licenses/OSL-3.0 Open Software License version 3.0
 *
 * This source file is subject to the Open Software License (OSL 3.0)
 * that is bundled with this package in the file LICENSE.
 * It is also available through the world-wide-web at this URL:
 * https://opensource.org/licenses/OSL-3.0
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
            );
        }
        return self::$providers;
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
