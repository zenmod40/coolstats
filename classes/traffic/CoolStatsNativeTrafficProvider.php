<?php
/**
 * Provider natif PrestaShop : lit les tables `ps_connections`, `ps_connections_page`, `ps_page`,
 * `ps_page_type`, `ps_guest`. Alimentées par le module `statsdata` (livré avec PS).
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

class CoolStatsNativeTrafficProvider implements CoolStatsTrafficProvider
{
    /** @var bool|null Cache du résultat de isAvailable() */
    private $availableCache = null;
    /** @var string|null */
    private $unavailableReason = null;

    public function getId() { return 'native_ps'; }
    public function getLabel() { return 'PrestaShop natif (statsdata)'; }

    /**
     * Retourne la condition WHERE pour exclure les IPs configurées.
     * Vide si pas d'IPs ou pas de wildcard support.
     */
    private function getIpExclusionWhere($alias = 'c')
    {
        $raw = trim((string) Configuration::get('COOLSTATS_EXCLUDED_IPS'));
        if ($raw === '') return '';
        $lines = preg_split('/[\r\n,]+/', $raw);
        $conditions = array();
        foreach ($lines as $ip) {
            $ip = trim($ip);
            if ($ip === '') continue;
            // Support wildcard simple : 192.168.* → LIKE '192.168.%'
            if (strpos($ip, '*') !== false) {
                $like = pSQL(str_replace('*', '%', $ip));
                $conditions[] = "{$alias}.ip_address NOT LIKE '{$like}'";
            } else {
                $conditions[] = "{$alias}.ip_address != '" . pSQL($ip) . "'";
            }
        }
        return $conditions ? ' AND (' . implode(' AND ', $conditions) . ')' : '';
    }

    public function isAvailable()
    {
        if ($this->availableCache !== null) return $this->availableCache;

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $hasTable = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = '" . pSQL($p . 'connections') . "'");

        if (!$hasTable) {
            $this->unavailableReason = 'no_table';
            $this->availableCache = false;
            return false;
        }

        $hasAny = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections");
        if (!$hasAny) {
            $this->unavailableReason = 'no_data';
            $this->availableCache = false;
            return false;
        }

        $this->unavailableReason = null;
        $this->availableCache = true;
        return true;
    }

    public function getUnavailableReason() { return $this->unavailableReason; }

    public function getKpi($from, $to, array $context = array())
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $f = pSQL($from) . ' 00:00:00';
        $t = pSQL($to)   . ' 23:59:59';
        $ipFilter = $this->getIpExclusionWhere('c');

        $sessions = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections c
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}");

        if ($sessions === 0) {
            return array(
                'unique_visitors' => 0, 'sessions' => 0, 'page_views' => 0,
                'pages_per_session' => 0, 'avg_duration_sec' => 0, 'conversion_rate' => 0,
            );
        }

        $unique = (int) $db->getValue("SELECT COUNT(DISTINCT id_guest) FROM {$p}connections c
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}");

        $pageViews = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections_page cp
            INNER JOIN {$p}connections c ON c.id_connections = cp.id_connections
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}");

        $avgDur = $db->getRow("SELECT AVG(diff) AS avg_dur FROM (
            SELECT TIMESTAMPDIFF(SECOND, MIN(cp.time_start), MAX(cp.time_end)) AS diff
            FROM {$p}connections_page cp
            INNER JOIN {$p}connections c ON c.id_connections = cp.id_connections
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}
            AND cp.time_start IS NOT NULL AND cp.time_end IS NOT NULL
            GROUP BY c.id_connections
        ) sub");
        $avgDuration = $avgDur && isset($avgDur['avg_dur']) ? (int) round((float) $avgDur['avg_dur']) : 0;

        // Taux de conversion = orders valides / visiteurs uniques
        if (!class_exists('CoolStatsHelpers')) {
            require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
        }
        $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        $orders = (int) $db->getValue("SELECT COUNT(*) FROM {$p}orders o
            WHERE o.date_add BETWEEN '{$f}' AND '{$t}'
            AND {$valid}");
        $conv = $unique > 0 ? round(($orders / $unique) * 100, 2) : 0;

        return array(
            'unique_visitors'   => $unique,
            'sessions'          => $sessions,
            'page_views'        => $pageViews,
            'pages_per_session' => $sessions > 0 ? round($pageViews / $sessions, 1) : 0,
            'avg_duration_sec'  => $avgDuration,
            'conversion_rate'   => $conv,
        );
    }

    public function getTopPages($from, $to, $limit = 5, array $context = array())
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $f = pSQL($from) . ' 00:00:00';
        $t = pSQL($to)   . ' 23:59:59';
        $limit = max(1, (int) $limit);

        $ipFilter = $this->getIpExclusionWhere('c');
        $rows = $db->executeS("SELECT pt.name AS label, COUNT(*) AS views
            FROM {$p}connections_page cp
            INNER JOIN {$p}connections c ON c.id_connections = cp.id_connections
            INNER JOIN {$p}page p ON p.id_page = cp.id_page
            INNER JOIN {$p}page_type pt ON pt.id_page_type = p.id_page_type
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}
            GROUP BY pt.name
            ORDER BY views DESC
            LIMIT {$limit}");
        $result = array();
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $result[] = array('label' => $r['label'], 'views' => (int) $r['views']);
            }
        }
        return $result;
    }

    public function getTopSources($from, $to, $limit = 5, array $context = array())
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $f = pSQL($from) . ' 00:00:00';
        $t = pSQL($to)   . ' 23:59:59';
        $limit = max(1, (int) $limit);

        $ipFilter = $this->getIpExclusionWhere('c');
        $referers = $db->executeS("SELECT c.http_referer, COUNT(*) AS hits
            FROM {$p}connections c
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}
            AND c.http_referer IS NOT NULL AND c.http_referer != ''
            GROUP BY c.http_referer
            ORDER BY hits DESC
            LIMIT 50");
        $referers = is_array($referers) ? $referers : array();

        $bySource = array();
        foreach ($referers as $r) {
            $host = parse_url($r['http_referer'], PHP_URL_HOST);
            if (!$host) continue;
            $host = preg_replace('/^www\./i', '', $host);
            if (!isset($bySource[$host])) $bySource[$host] = 0;
            $bySource[$host] += (int) $r['hits'];
        }
        arsort($bySource);

        $top = array();
        $i = 0;
        foreach ($bySource as $host => $hits) {
            if ($i++ >= $limit) break;
            $top[] = array('source' => $host, 'hits' => $hits);
        }

        $directHits = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections c
            WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}
            AND (c.http_referer IS NULL OR c.http_referer = '')");
        if ($directHits > 0) {
            array_unshift($top, array('source' => 'Direct / Inconnu', 'hits' => $directHits));
            $top = array_slice($top, 0, $limit);
        }
        return $top;
    }

    public function getDevices($from, $to, array $context = array())
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $f = pSQL($from) . ' 00:00:00';
        $t = pSQL($to)   . ' 23:59:59';

        $ipFilter = $this->getIpExclusionWhere('c');
        $row = $db->getRow("SELECT
            SUM(CASE WHEN g.mobile_theme = 1 THEN 1 ELSE 0 END) AS mobile_count,
            SUM(CASE WHEN g.mobile_theme = 0 THEN 1 ELSE 0 END) AS desktop_count
        FROM {$p}connections c
        INNER JOIN {$p}guest g ON g.id_guest = c.id_guest
        WHERE c.date_add BETWEEN '{$f}' AND '{$t}' {$ipFilter}");

        $mobile = (int) ($row['mobile_count'] ?? 0);
        $desktop = (int) ($row['desktop_count'] ?? 0);
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
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;

        $hasTable = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = '" . pSQL($p . 'connections') . "'");
        $hasIndex = false;
        $totalSessions = 0;
        $lastAt = null;
        if ($hasTable) {
            $hasIndex = (int) $db->getValue("SELECT COUNT(*) FROM information_schema.STATISTICS
                WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = '" . pSQL($p . 'connections') . "'
                AND INDEX_NAME = 'idx_coolstats_date_add'") > 0;
            $totalSessions = (int) $db->getValue("SELECT COUNT(*) FROM {$p}connections");
            $lastAt = $db->getValue("SELECT MAX(date_add) FROM {$p}connections");
        }

        return array(
            'has_table'           => (bool) $hasTable,
            'has_index'           => $hasIndex,
            'statsdata_installed' => (bool) Module::isInstalled('statsdata'),
            'statsdata_active'    => (bool) (Module::isInstalled('statsdata') && Module::isEnabled('statsdata')),
            'total_sessions'      => $totalSessions,
            'last_session_at'     => $lastAt,
        );
    }
}
