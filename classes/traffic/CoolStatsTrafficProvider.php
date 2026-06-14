<?php
/**
 * Interface CoolStatsTrafficProvider
 *
 * Contrat que toute source de trafic (PrestaShop natif, Matomo, GA4, Plausible…)
 * doit implémenter pour alimenter la section "Trafic & visiteurs".
 *
 * V1 : seul `CoolStatsNativeTrafficProvider` (lecture de ps_connections).
 * V2 : Matomo / GA4 / Plausible viendront se greffer sans toucher à la section view.
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

interface CoolStatsTrafficProvider
{
    /**
     * Identifiant technique du provider (ex: 'native_ps', 'matomo', 'ga4').
     */
    public function getId();

    /**
     * Nom affiché à l'utilisateur (ex: "PrestaShop natif (statsdata)").
     */
    public function getLabel();

    /**
     * @return bool true si le provider peut servir des données (config OK + données disponibles).
     */
    public function isAvailable();

    /**
     * Raison de l'indisponibilité, pour message UX (ex: 'no_table', 'no_data', 'misconfigured').
     * Retourne null si le provider est disponible.
     *
     * @return string|null
     */
    public function getUnavailableReason();

    /**
     * KPI principaux sur la période :
     * unique_visitors, sessions, page_views, pages_per_session, avg_duration_sec, conversion_rate.
     *
     * @param string $from Y-m-d
     * @param string $to   Y-m-d
     * @param array  $context Optionnel (id_shop, country, etc.)
     * @return array<string, int|float>
     */
    public function getKpi($from, $to, array $context = array());

    /**
     * @return array<int, array{label:string, views:int}>
     */
    public function getTopPages($from, $to, $limit = 5, array $context = array());

    /**
     * @return array<int, array{source:string, hits:int}>
     */
    public function getTopSources($from, $to, $limit = 5, array $context = array());

    /**
     * @return array{mobile:int, desktop:int, mobile_pct:float, desktop_pct:float}
     */
    public function getDevices($from, $to, array $context = array());

    /**
     * Diagnostic technique (pour la page de config admin) :
     * statut tables, indexes, modules dépendants, etc.
     *
     * @return array<string, mixed>
     */
    public function getDiagnostic();
}
