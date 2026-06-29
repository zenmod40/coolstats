<?php
/**
 * Provider Matomo : interroge l'API Reporting de Matomo (ex-Piwik).
 *
 * Documentation : https://developer.matomo.org/api-reference/reporting-api
 *
 * Configuration (BO) :
 *   COOLSTATS_MATOMO_URL     URL de base de l'instance Matomo (ex: https://analytics.example.com)
 *   COOLSTATS_MATOMO_TOKEN   token d'authentification (auth_token, créé dans Matomo → Préférences personnelles)
 *   COOLSTATS_MATOMO_SITE_ID id du site dans Matomo
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

class CoolStatsMatomoTrafficProvider implements CoolStatsTrafficProvider
{
    /** @var bool|null */
    private $availableCache = null;
    /** @var string|null */
    private $unavailableReason = null;

    public function getId() { return 'matomo'; }
    public function getLabel() { return 'Matomo'; }

    private function getConfig()
    {
        return array(
            'url'     => rtrim((string) Configuration::get('COOLSTATS_MATOMO_URL'), '/'),
            'token'   => (string) Configuration::get('COOLSTATS_MATOMO_TOKEN'),
            'site_id' => (int) Configuration::get('COOLSTATS_MATOMO_SITE_ID'),
        );
    }

    public function isAvailable()
    {
        if ($this->availableCache !== null) return $this->availableCache;

        $cfg = $this->getConfig();
        if ($cfg['url'] === '' || $cfg['token'] === '' || $cfg['site_id'] <= 0) {
            $this->unavailableReason = 'misconfigured';
            return $this->availableCache = false;
        }
        if (!preg_match('#^https?://#i', $cfg['url'])) {
            $this->unavailableReason = 'invalid_url';
            return $this->availableCache = false;
        }
        // Test connectivity : on demande la version de Matomo (méthode très légère).
        $res = $this->callApi('API.getMatomoVersion', array());
        if ($res === null) {
            $this->unavailableReason = 'unreachable';
            return $this->availableCache = false;
        }
        if (isset($res['result']) && $res['result'] === 'error') {
            $this->unavailableReason = 'auth_error';
            return $this->availableCache = false;
        }
        $this->unavailableReason = null;
        return $this->availableCache = true;
    }

    public function getUnavailableReason() { return $this->unavailableReason; }

    /**
     * Appel générique à l'API Matomo.
     * @return array|null Tableau décodé ou null si erreur HTTP/réseau.
     */
    private function callApi($method, array $params = array())
    {
        $cfg = $this->getConfig();
        $payload = array_merge(array(
            'module'     => 'API',
            'method'     => $method,
            'idSite'     => $cfg['site_id'],
            'format'     => 'json',
            'token_auth' => $cfg['token'],
        ), $params);

        // Matomo exige token_auth en POST (sinon "must be sent as a POST parameter").
        $ctx = stream_context_create(array(
            'http' => array(
                'method'        => 'POST',
                'header'        => "Content-Type: application/x-www-form-urlencoded\r\n",
                'content'       => http_build_query($payload),
                'timeout'       => 6,
                'ignore_errors' => true,
                'user_agent'    => 'CoolStats/1.0 PrestaShop module',
            ),
        ));
        $raw = @file_get_contents($cfg['url'] . '/index.php', false, $ctx);
        if ($raw === false) return null;
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : null;
    }

    /**
     * Format de période Matomo : period=range, date=YYYY-MM-DD,YYYY-MM-DD
     */
    private function periodParams($from, $to)
    {
        return array('period' => 'range', 'date' => $from . ',' . $to);
    }

    public function getKpi($from, $to, array $context = array())
    {
        $r = $this->callApi('VisitsSummary.get', $this->periodParams($from, $to));
        $empty = array(
            'unique_visitors'   => 0,
            'sessions'          => 0,
            'page_views'        => 0,
            'pages_per_session' => 0,
            'avg_duration_sec'  => 0,
            'conversion_rate'   => 0,
        );
        if (!is_array($r)) return $empty;
        $sessions = (int) ($r['nb_visits'] ?? 0);
        $unique   = (int) ($r['nb_uniq_visitors'] ?? 0);
        $views    = (int) ($r['nb_actions'] ?? 0);
        $avgDur   = (int) ($r['avg_time_on_site'] ?? 0);

        // Fallback : si Matomo ne calcule pas les uniques pour period=range
        // (option serveur enable_processing_unique_visitors_year désactivée par défaut),
        // on agrège jour par jour. Note : overcount possible (visiteur revenu plusieurs jours).
        if ($unique === 0 && $sessions > 0) {
            $daily = $this->callApi('VisitsSummary.get', array('period' => 'day', 'date' => $from . ',' . $to));
            if (is_array($daily)) {
                foreach ($daily as $day) {
                    if (is_array($day) && isset($day['nb_uniq_visitors'])) {
                        $unique += (int) $day['nb_uniq_visitors'];
                    }
                }
            }
        }

        // Conversion : calculé côté CoolStats (orders / unique_visitors) pour cohérence avec les KPI dashboard.
        if (!class_exists('CoolStatsHelpers')) {
            require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
        }
        $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        $f = pSQL($from) . ' 00:00:00';
        $t = pSQL($to)   . ' 23:59:59';
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $orders = (int) $db->getValue("SELECT COUNT(*) FROM {$p}orders o
            WHERE o.date_add BETWEEN '{$f}' AND '{$t}' AND {$valid}");
        $conv = $unique > 0 ? round(($orders / $unique) * 100, 2) : 0;

        return array(
            'unique_visitors'   => $unique,
            'sessions'          => $sessions,
            'page_views'        => $views,
            'pages_per_session' => $sessions > 0 ? round($views / $sessions, 1) : 0,
            'avg_duration_sec'  => $avgDur,
            'conversion_rate'   => $conv,
        );
    }

    public function getTopPages($from, $to, $limit = 5, array $context = array())
    {
        $r = $this->callApi('Actions.getPageTitles', array_merge(
            $this->periodParams($from, $to),
            array('filter_limit' => (int) $limit)
        ));
        $result = array();
        if (is_array($r)) {
            foreach ($r as $row) {
                if (!is_array($row)) continue;
                $result[] = array(
                    'label' => isset($row['label']) ? (string) $row['label'] : '—',
                    'views' => (int) ($row['nb_hits'] ?? $row['nb_visits'] ?? 0),
                );
            }
        }
        return $result;
    }

    public function getTopSources($from, $to, $limit = 5, array $context = array())
    {
        // On combine direct/inconnu + top hostnames (cohérent avec l'UX historique).
        $result = array();

        // 1) Direct / inconnu via getRefererType
        $types = $this->callApi('Referrers.getRefererType', array_merge(
            $this->periodParams($from, $to),
            array('filter_limit' => 10)
        ));
        $directHits = 0;
        if (is_array($types)) {
            foreach ($types as $row) {
                if (!is_array($row)) continue;
                $label = strtolower((string) ($row['label'] ?? ''));
                // Direct Entry / "Entrées directes" → Matomo localise selon la langue
                if (strpos($label, 'direct') !== false || (isset($row['referer_type']) && (int) $row['referer_type'] === 1)) {
                    $directHits += (int) ($row['nb_visits'] ?? 0);
                }
            }
        }
        if ($directHits > 0) {
            $result[] = array('source' => 'Direct / Inconnu', 'hits' => $directHits);
        }

        // 2) Top sites référents (hostnames)
        $sites = $this->callApi('Referrers.getWebsites', array_merge(
            $this->periodParams($from, $to),
            array('filter_limit' => (int) $limit)
        ));
        if (is_array($sites)) {
            foreach ($sites as $row) {
                if (!is_array($row)) continue;
                $result[] = array(
                    'source' => (string) ($row['label'] ?? '—'),
                    'hits'   => (int) ($row['nb_visits'] ?? 0),
                );
            }
        }

        // 3) Search engines (cumulé)
        $search = $this->callApi('Referrers.getSearchEngines', array_merge(
            $this->periodParams($from, $to),
            array('filter_limit' => 10)
        ));
        if (is_array($search)) {
            foreach ($search as $row) {
                if (!is_array($row)) continue;
                $result[] = array(
                    'source' => (string) ($row['label'] ?? '—'),
                    'hits'   => (int) ($row['nb_visits'] ?? 0),
                );
            }
        }

        usort($result, function ($a, $b) { return $b['hits'] - $a['hits']; });
        return array_slice($result, 0, (int) $limit);
    }

    public function getDevices($from, $to, array $context = array())
    {
        $r = $this->callApi('DevicesDetection.getType', $this->periodParams($from, $to));
        $mobile = 0; $desktop = 0;
        if (is_array($r)) {
            foreach ($r as $row) {
                if (!is_array($row)) continue;
                // Le label est LOCALISÉ par Matomo (« Desktop » → « Ordinateur de bureau »
                // en FR), donc on identifie le desktop via le segment (`deviceType==desktop`)
                // ou le logo (`.../devices/desktop.png`), indépendants de la langue.
                // Le label reste un dernier recours.
                $label   = strtolower(isset($row['label'])   ? (string) $row['label']   : '');
                $segment = strtolower(isset($row['segment']) ? (string) $row['segment'] : '');
                $logo    = strtolower(isset($row['logo'])    ? (string) $row['logo']    : '');
                $visits = (int) ($row['nb_visits'] ?? 0);
                $isDesktop = (strpos($segment, 'desktop') !== false)
                          || (strpos($logo, 'desktop') !== false)
                          || (strpos($label, 'desktop') !== false);
                if ($isDesktop) {
                    $desktop += $visits;
                } elseif ($label !== '' || $segment !== '') {
                    // Tablet, smartphone, phablet, console, smarttv → "mobile/autre"
                    $mobile += $visits;
                }
            }
        }
        $total = $mobile + $desktop;
        return array(
            'mobile'      => $mobile,
            'desktop'     => $desktop,
            'mobile_pct'  => $total > 0 ? round(($mobile / $total) * 100, 1) : 0,
            'desktop_pct' => $total > 0 ? round(($desktop / $total) * 100, 1) : 0,
        );
    }

    public function getDiagnostic()
    {
        $cfg = $this->getConfig();
        $diag = array(
            'url'              => $cfg['url'] ?: null,
            'site_id'          => $cfg['site_id'] ?: null,
            'token_configured' => $cfg['token'] !== '',
        );
        // Tente un appel pour récupérer la version + le nom du site
        if ($this->isAvailable()) {
            $version = $this->callApi('API.getMatomoVersion', array());
            $site    = $this->callApi('SitesManager.getSiteFromId', array());
            $diag['matomo_version'] = is_array($version) && isset($version['value']) ? $version['value'] : null;
            $diag['site_name'] = is_array($site) && isset($site['name']) ? $site['name'] : null;
        }
        return $diag;
    }
}
