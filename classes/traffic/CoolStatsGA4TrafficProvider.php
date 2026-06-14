<?php
/**
 * Provider Google Analytics 4 — auth via Service Account.
 *
 * Setup côté Google Cloud (à faire une fois) :
 *   1. Créer un projet GCP (https://console.cloud.google.com)
 *   2. Activer l'API "Google Analytics Data API"
 *   3. Créer un Service Account (IAM & Admin → Service Accounts)
 *   4. Générer une clé JSON pour ce service account
 *   5. Dans GA4 (Admin → Property → Property access management),
 *      ajouter l'email du service account avec le rôle "Viewer"
 *
 * Configuration BO :
 *   COOLSTATS_GA4_PROPERTY_ID            int (ex: 123456789, sans "properties/")
 *   COOLSTATS_GA4_SERVICE_ACCOUNT_JSON   contenu JSON du fichier de clé
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

class CoolStatsGA4TrafficProvider implements CoolStatsTrafficProvider
{
    /** @var bool|null */
    private $availableCache = null;
    /** @var string|null */
    private $unavailableReason = null;
    /** @var string|null Cache de l'access token Bearer pour la durée de la requête. */
    private $accessTokenCache = null;

    const SCOPE     = 'https://www.googleapis.com/auth/analytics.readonly';
    const TOKEN_URL = 'https://oauth2.googleapis.com/token';
    const API_BASE  = 'https://analyticsdata.googleapis.com/v1beta';

    public function getId() { return 'ga4'; }
    public function getLabel() { return 'Google Analytics 4'; }

    private function getConfig()
    {
        return array(
            'property_id' => (int) Configuration::get('COOLSTATS_GA4_PROPERTY_ID'),
            'sa_json'     => (string) Configuration::get('COOLSTATS_GA4_SERVICE_ACCOUNT_JSON'),
        );
    }

    public function isAvailable()
    {
        if ($this->availableCache !== null) return $this->availableCache;

        $cfg = $this->getConfig();
        if ($cfg['property_id'] <= 0 || $cfg['sa_json'] === '') {
            $this->unavailableReason = 'misconfigured';
            return $this->availableCache = false;
        }
        $sa = json_decode($cfg['sa_json'], true);
        if (!is_array($sa) || empty($sa['client_email']) || empty($sa['private_key'])) {
            $this->unavailableReason = 'invalid_service_account';
            return $this->availableCache = false;
        }
        // Tente de récupérer un access token + un appel léger
        $token = $this->getAccessToken();
        if ($token === null) {
            $this->unavailableReason = 'auth_failed';
            return $this->availableCache = false;
        }
        $this->unavailableReason = null;
        return $this->availableCache = true;
    }

    public function getUnavailableReason() { return $this->unavailableReason; }

    /**
     * Construit + signe un JWT RS256 à partir du service account, l'échange contre
     * un access token Bearer Google (valide 1h). Cache en mémoire pour la requête.
     */
    public function getAccessToken()
    {
        if ($this->accessTokenCache !== null) return $this->accessTokenCache;

        $cfg = $this->getConfig();
        $sa = json_decode($cfg['sa_json'], true);
        if (!is_array($sa) || empty($sa['client_email']) || empty($sa['private_key'])) {
            return null;
        }

        $now = time();
        $jwtHeader = self::base64UrlEncode(json_encode(array('alg' => 'RS256', 'typ' => 'JWT')));
        $jwtClaim  = self::base64UrlEncode(json_encode(array(
            'iss'   => $sa['client_email'],
            'scope' => self::SCOPE,
            'aud'   => self::TOKEN_URL,
            'exp'   => $now + 3600,
            'iat'   => $now,
        )));
        $signingInput = $jwtHeader . '.' . $jwtClaim;

        $signature = '';
        $ok = @openssl_sign($signingInput, $signature, $sa['private_key'], 'sha256WithRSAEncryption');
        if (!$ok) {
            return null;
        }
        $jwt = $signingInput . '.' . self::base64UrlEncode($signature);

        $body = http_build_query(array(
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion'  => $jwt,
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
        $raw = @file_get_contents(self::TOKEN_URL, false, $ctx);
        if ($raw === false) return null;
        $decoded = json_decode($raw, true);
        if (!is_array($decoded) || empty($decoded['access_token'])) {
            return null;
        }
        return $this->accessTokenCache = (string) $decoded['access_token'];
    }

    /**
     * Appel runReport sur l'API GA4 Data v1.
     * @return array|null Tableau décodé (rows, totals, etc.) ou null en cas d'erreur.
     */
    private function runReport(array $reportBody)
    {
        $token = $this->getAccessToken();
        if ($token === null) return null;

        $cfg = $this->getConfig();
        $url = self::API_BASE . '/properties/' . $cfg['property_id'] . ':runReport';

        $ctx = stream_context_create(array(
            'http' => array(
                'method'        => 'POST',
                'header'        => "Authorization: Bearer {$token}\r\nContent-Type: application/json\r\n",
                'content'       => json_encode($reportBody),
                'timeout'       => 8,
                'ignore_errors' => true,
                'user_agent'    => 'CoolStats/1.0 PrestaShop module',
            ),
        ));
        $raw = @file_get_contents($url, false, $ctx);
        if ($raw === false) return null;
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : null;
    }

    public function getKpi($from, $to, array $context = array())
    {
        $r = $this->runReport(array(
            'dateRanges' => array(array('startDate' => $from, 'endDate' => $to)),
            'metrics'    => array(
                array('name' => 'totalUsers'),
                array('name' => 'sessions'),
                array('name' => 'screenPageViews'),
                array('name' => 'averageSessionDuration'),
            ),
        ));
        $empty = array(
            'unique_visitors'   => 0,
            'sessions'          => 0,
            'page_views'        => 0,
            'pages_per_session' => 0,
            'avg_duration_sec'  => 0,
            'conversion_rate'   => 0,
        );
        if (!is_array($r) || empty($r['rows'][0]['metricValues'])) return $empty;
        $vals = $r['rows'][0]['metricValues'];
        $unique   = isset($vals[0]['value']) ? (int) $vals[0]['value'] : 0;
        $sessions = isset($vals[1]['value']) ? (int) $vals[1]['value'] : 0;
        $views    = isset($vals[2]['value']) ? (int) $vals[2]['value'] : 0;
        $avgDur   = isset($vals[3]['value']) ? (int) round((float) $vals[3]['value']) : 0;

        // Conversion calculée côté CoolStats pour cohérence
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
        $r = $this->runReport(array(
            'dateRanges' => array(array('startDate' => $from, 'endDate' => $to)),
            'metrics'    => array(array('name' => 'screenPageViews')),
            'dimensions' => array(array('name' => 'pageTitle')),
            'orderBys'   => array(array('metric' => array('metricName' => 'screenPageViews'), 'desc' => true)),
            'limit'      => (int) $limit,
        ));
        $result = array();
        if (is_array($r) && !empty($r['rows'])) {
            foreach ($r['rows'] as $row) {
                $label = isset($row['dimensionValues'][0]['value']) ? (string) $row['dimensionValues'][0]['value'] : '—';
                $views = isset($row['metricValues'][0]['value']) ? (int) $row['metricValues'][0]['value'] : 0;
                $result[] = array('label' => $label, 'views' => $views);
            }
        }
        return $result;
    }

    public function getTopSources($from, $to, $limit = 5, array $context = array())
    {
        $r = $this->runReport(array(
            'dateRanges' => array(array('startDate' => $from, 'endDate' => $to)),
            'metrics'    => array(array('name' => 'sessions')),
            'dimensions' => array(array('name' => 'sessionSource')),
            'orderBys'   => array(array('metric' => array('metricName' => 'sessions'), 'desc' => true)),
            'limit'      => (int) $limit,
        ));
        $result = array();
        if (is_array($r) && !empty($r['rows'])) {
            foreach ($r['rows'] as $row) {
                $src = isset($row['dimensionValues'][0]['value']) ? (string) $row['dimensionValues'][0]['value'] : '—';
                $hits = isset($row['metricValues'][0]['value']) ? (int) $row['metricValues'][0]['value'] : 0;
                // GA4 retourne "(direct)" pour le trafic direct → harmonise avec Matomo/natif
                if ($src === '(direct)' || $src === '(none)') {
                    $src = 'Direct / Inconnu';
                }
                $result[] = array('source' => $src, 'hits' => $hits);
            }
        }
        return $result;
    }

    public function getDevices($from, $to, array $context = array())
    {
        $r = $this->runReport(array(
            'dateRanges' => array(array('startDate' => $from, 'endDate' => $to)),
            'metrics'    => array(array('name' => 'sessions')),
            'dimensions' => array(array('name' => 'deviceCategory')),
        ));
        $mobile = 0; $desktop = 0;
        if (is_array($r) && !empty($r['rows'])) {
            foreach ($r['rows'] as $row) {
                $cat = strtolower(isset($row['dimensionValues'][0]['value']) ? (string) $row['dimensionValues'][0]['value'] : '');
                $sessions = isset($row['metricValues'][0]['value']) ? (int) $row['metricValues'][0]['value'] : 0;
                if ($cat === 'desktop') {
                    $desktop += $sessions;
                } elseif ($cat !== '') {
                    // mobile, tablet, smart tv → "mobile/autre"
                    $mobile += $sessions;
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
        $sa = $cfg['sa_json'] !== '' ? json_decode($cfg['sa_json'], true) : null;
        return array(
            'property_id'         => $cfg['property_id'] ?: null,
            'service_account_set' => is_array($sa) && !empty($sa['client_email']),
            'service_account_mail'=> is_array($sa) && !empty($sa['client_email']) ? $sa['client_email'] : null,
        );
    }

    /**
     * Encodage base64 url-safe sans padding (JWT spec).
     */
    private static function base64UrlEncode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
