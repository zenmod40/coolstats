<?php
/**
 * CoolStatsKerawen — lecture des écritures de caisse Kerawen (tables NF525).
 *
 * Toutes les requêtes Kerawen du module sont ici, et nulle part ailleurs : si
 * Kerawen change son modèle de données (V3), c'est le seul fichier à reprendre.
 *
 * Source de vérité : les tables {prefix}kerawen_525_*, écritures fiscales
 * signées. Lecture seule, sans exception : CoolStats constate, il ne répare pas.
 *
 *  - Le CA se calcule sur les ventes (kerawen_525_sale) datées par leur
 *    opération, jamais en remontant des lignes d'articles vers les commandes :
 *    c'est ce chemin qu'une collision d'identifiants fausse, il ne sert qu'au
 *    contrôle.
 *  - operation.id_till = 0 : vente web ; > 0 : caisse physique (till_name).
 *  - Aucun identifiant Kerawen n'est supposé suivre l'ordre chronologique.
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

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

class CoolStatsKerawen
{
    /** Tolérance d'écart entre une vente et ses lignes, par mois (€). */
    const LINES_TOLERANCE = 0.01;

    /** Durée de vie du statut mis en cache pour le tableau de bord natif (s). */
    const ALERT_TTL = 3600;

    /** @var bool|null */
    private static $available = null;

    /**
     * Kerawen NF525 présent : les cinq tables lues par le module existent.
     * Sans elles, les sections Kerawen restent masquées.
     */
    public static function isAvailable()
    {
        if (self::$available !== null) {
            return self::$available;
        }
        $tables = array();
        foreach (array('operation', 'sale', 'sale_tax', 'order', 'sale_detail') as $t) {
            $tables[] = "'" . pSQL(_DB_PREFIX_ . 'kerawen_525_' . $t) . "'";
        }
        try {
            $rows = self::rows("SELECT COUNT(*) AS n FROM information_schema.TABLES
                WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME IN (" . implode(',', $tables) . ")");
            self::$available = (int) $rows[0]['n'] === count($tables);
        } catch (Exception $e) {
            self::$available = false;
        }
        return self::$available;
    }

    /**
     * CA par caisse sur la période : une ligne par id_till (0 = web).
     *
     * @return array<int,array{id_till:int,till_name:string,nb:int,ttc:float,ht:float}>
     */
    public static function salesByTill($from, $to)
    {
        $out = array();
        foreach (self::rows("SELECT op.id_till, MAX(op.till_name) AS till_name, COUNT(*) AS nb,
                SUM(s.total_ti) AS ttc, SUM(s.total_te) AS ht
            " . self::saleFrom() . self::period($from, $to) . "
            GROUP BY op.id_till
            ORDER BY op.id_till") as $r) {
            $out[] = array(
                'id_till'   => (int) $r['id_till'],
                'till_name' => (string) $r['till_name'],
                'nb'        => (int) $r['nb'],
                'ttc'       => round((float) $r['ttc'], 2),
                'ht'        => round((float) $r['ht'], 2),
            );
        }
        return $out;
    }

    /** TVA collectée sur la période (somme des ventilations par taux). */
    public static function vatTotal($from, $to)
    {
        $p = _DB_PREFIX_;
        $rows = self::rows("SELECT SUM(st.tax_amount) AS tax
            " . self::saleFrom("INNER JOIN {$p}kerawen_525_sale_tax st ON st.id_sale = s.id_sale") . self::period($from, $to));
        return round((float) $rows[0]['tax'], 2);
    }

    /**
     * CA par tranche de temps et par canal, pour la courbe.
     *
     * @param string $sqlFormat Format DATE_FORMAT de la tranche ('%Y-%m-%d' ou '%Y-%m')
     * @return array<int,array{k:string,channel:string,ttc:float,ht:float}>
     */
    public static function series($from, $to, $sqlFormat)
    {
        $out = array();
        foreach (self::rows("SELECT DATE_FORMAT(op.date, '" . pSQL($sqlFormat) . "') AS k,
                IF(op.id_till > 0, 'store', 'web') AS channel,
                SUM(s.total_ti) AS ttc, SUM(s.total_te) AS ht
            " . self::saleFrom() . self::period($from, $to) . "
            GROUP BY k, channel") as $r) {
            $out[] = array(
                'k'       => (string) $r['k'],
                'channel' => (string) $r['channel'],
                'ttc'     => (float) $r['ttc'],
                'ht'      => (float) $r['ht'],
            );
        }
        return $out;
    }

    /**
     * Montant Kerawen de chaque commande PrestaShop sur la période : lignes
     * kerawen_525_order rattachées à une vente datée dans la période, cumulées
     * par ps_order (0 = écriture sans commande PrestaShop). Sert au rapprochement
     * avec le CA commandes ; jamais au calcul du CA lui-même.
     *
     * @return array<int,array{ttc:float,ht:float}> ps_order => montants
     */
    public static function amountsByPsOrder($from, $to)
    {
        $p = _DB_PREFIX_;
        $out = array();
        foreach (self::rows("SELECT COALESCE(ko.ps_order, 0) AS ps_order, SUM(ko.total_ti) AS ttc, SUM(ko.total_te) AS ht
            " . self::saleFrom("INNER JOIN {$p}kerawen_525_order ko ON ko.id_sale = s.id_sale") . self::period($from, $to) . "
            GROUP BY COALESCE(ko.ps_order, 0)") as $r) {
            $out[(int) $r['ps_order']] = array('ttc' => (float) $r['ttc'], 'ht' => (float) $r['ht']);
        }
        return $out;
    }

    /**
     * Ventilation TVA par mois, canal et taux.
     *
     * @return array<int,array{month:string,channel:string,rate:float,ttc:float,ht:float,tax:float}>
     */
    public static function vatByMonth($from, $to)
    {
        $p = _DB_PREFIX_;
        $out = array();
        foreach (self::rows("SELECT DATE_FORMAT(op.date, '%Y-%m') AS month,
                IF(op.id_till > 0, 'store', 'web') AS channel,
                st.tax_rate AS rate,
                SUM(st.total_ti) AS ttc, SUM(st.total_te) AS ht, SUM(st.tax_amount) AS tax
            " . self::saleFrom("INNER JOIN {$p}kerawen_525_sale_tax st ON st.id_sale = s.id_sale") . self::period($from, $to) . "
            GROUP BY month, channel, rate
            ORDER BY month, rate DESC") as $r) {
            $out[] = array(
                'month'   => (string) $r['month'],
                'channel' => (string) $r['channel'],
                'rate'    => (float) $r['rate'],
                'ttc'     => (float) $r['ttc'],
                'ht'      => (float) $r['ht'],
                'tax'     => (float) $r['tax'],
            );
        }
        return $out;
    }

    /**
     * Contrôles d'intégrité sur tout l'historique (filtre de période ignoré).
     * Chaque contrôle : status 'ok' | 'ko' | 'error', count, amount (TTC), details.
     * Le nombre de contrôles en rouge est mis en cache pour le tableau de bord natif.
     *
     * @return array<string,array>
     */
    public static function integrity()
    {
        $checks = array(
            'collision' => 'checkCollision',
            'lines'     => 'checkLines',
            'missing'   => 'checkMissingOrders',
            'gap'       => 'checkGap',
        );
        $out = array();
        foreach ($checks as $key => $method) {
            try {
                $out[$key] = self::$method();
            } catch (Exception $e) {
                // Une requête qui échoue ne doit jamais passer pour « 0 anomalie ».
                $out[$key] = array('status' => 'error', 'count' => 0, 'amount' => 0.0, 'details' => array());
            }
        }
        Configuration::updateValue('COOLSTATS_KERAWEN_ALERT', json_encode(array(
            'at'  => time(),
            'red' => self::countFailures($out),
        )));
        return $out;
    }

    /**
     * Nombre de contrôles en rouge, recalculé au plus une fois par heure
     * (le dashboard CoolStats rafraîchit aussi le cache à chaque affichage).
     */
    public static function alertCount()
    {
        $cache = json_decode((string) Configuration::get('COOLSTATS_KERAWEN_ALERT'), true);
        if (is_array($cache) && isset($cache['at'], $cache['red']) && (int) $cache['at'] > time() - self::ALERT_TTL) {
            return (int) $cache['red'];
        }
        return self::countFailures(self::integrity());
    }

    public static function countFailures(array $checks)
    {
        $n = 0;
        foreach ($checks as $c) {
            if ($c['status'] === 'ko') {
                $n++;
            }
        }
        return $n;
    }

    /**
     * 1. Lignes d'articles rattachées, via leur commande, à la vente d'une autre
     *    commande. Attendu : 0. Sinon, le CA calculé par Kerawen est faux.
     */
    private static function checkCollision()
    {
        $p = _DB_PREFIX_;
        $r = self::rows("SELECT COUNT(*) AS n, SUM(d.total_ti) AS amount
            FROM {$p}kerawen_525_sale_detail d
            INNER JOIN {$p}kerawen_525_order o ON o.id_order = d.id_order
            INNER JOIN {$p}kerawen_525_sale s ON s.id_sale = d.id_sale
            INNER JOIN {$p}kerawen_525_operation op ON op.id_operation = s.id_operation
            WHERE o.id_sale <> d.id_sale" . CoolStatsHelpers::shopRestriction('op'));
        $n = (int) $r[0]['n'];
        return array(
            'status'  => $n > 0 ? 'ko' : 'ok',
            'count'   => $n,
            'amount'  => round((float) $r[0]['amount'], 2),
            'details' => array(),
        );
    }

    /**
     * 2. Par mois : total des ventes vs total des lignes rattachées par
     *    order.id_sale (le chemin du pilotage Kerawen). Écart > 0,01 € = rouge.
     */
    private static function checkLines()
    {
        $p = _DB_PREFIX_;
        $sales = $lines = array();
        foreach (self::rows("SELECT DATE_FORMAT(op.date, '%Y-%m') AS m, SUM(s.total_ti) AS t
            " . self::saleFrom() . " GROUP BY m") as $r) {
            $sales[$r['m']] = (float) $r['t'];
        }
        foreach (self::rows("SELECT DATE_FORMAT(op.date, '%Y-%m') AS m, SUM(d.total_ti) AS t
            " . self::saleFrom("INNER JOIN {$p}kerawen_525_order o ON o.id_sale = s.id_sale
                INNER JOIN {$p}kerawen_525_sale_detail d ON d.id_order = o.id_order") . " GROUP BY m") as $r) {
            $lines[$r['m']] = (float) $r['t'];
        }
        ksort($sales);
        $details = array();
        $amount = 0.0;
        foreach ($sales as $m => $t) {
            $l = isset($lines[$m]) ? $lines[$m] : 0.0;
            $diff = round($l - $t, 2);
            if (abs($diff) > self::LINES_TOLERANCE) {
                $details[] = array('month' => $m, 'sales' => round($t, 2), 'lines' => round($l, 2), 'diff' => $diff);
                $amount += abs($diff);
            }
        }
        return array(
            'status'  => $details ? 'ko' : 'ok',
            'count'   => count($details),
            'amount'  => round($amount, 2),
            'details' => $details,
        );
    }

    /**
     * 3. Commandes caisse PrestaShop (module kerawen, état valide) sans écriture
     *    kerawen_525_order, par mois. Seulement depuis la première opération du
     *    journal : les ventes antérieures à l'installation de NF525 n'y sont pas,
     *    et ce n'est pas une anomalie.
     */
    private static function checkMissingOrders()
    {
        $p = _DB_PREFIX_;
        $first = self::rows("SELECT MIN(op.date) AS d FROM {$p}kerawen_525_operation op
            WHERE 1" . CoolStatsHelpers::shopRestriction('op'));
        $first = (string) $first[0]['d'];
        if ($first === '') {
            return array('status' => 'ok', 'count' => 0, 'amount' => 0.0, 'details' => array());
        }
        $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        // Table dérivée plutôt que NOT EXISTS : ps_order n'est pas forcément indexé,
        // MySQL indexe lui-même la table dérivée.
        $rows = self::rows("SELECT DATE_FORMAT(o.date_add, '%Y-%m') AS m, COUNT(*) AS n,
                SUM(o.total_paid_tax_incl) AS amount
            FROM {$p}orders o
            LEFT JOIN (SELECT DISTINCT ps_order FROM {$p}kerawen_525_order) ko ON ko.ps_order = o.id_order
            WHERE o.module = 'kerawen' AND ko.ps_order IS NULL
            AND o.date_add >= '" . pSQL($first) . "'" . ($valid ? ' AND ' . $valid : '')
            . CoolStatsHelpers::shopRestriction('o') . "
            GROUP BY m ORDER BY m");
        $n = 0;
        $amount = 0.0;
        $details = array();
        foreach ($rows as $r) {
            $n += (int) $r['n'];
            $amount += (float) $r['amount'];
            $details[] = array('month' => $r['m'], 'count' => (int) $r['n'], 'amount' => round((float) $r['amount'], 2));
        }
        return array(
            'status'  => $n > 0 ? 'ko' : 'ok',
            'count'   => $n,
            'amount'  => round($amount, 2),
            'details' => $details,
        );
    }

    /**
     * 4. Trous dans le journal : jours sans vente plus longs que le seuil
     *    (COOLSTATS_KERAWEN_GAP_DAYS) alors que PrestaShop a enregistré des
     *    commandes valides dans l'intervalle. Le trou en cours (dernière vente →
     *    aujourd'hui) compte aussi : c'est celui d'un journal qui s'arrête.
     *    Sans LAG() (MySQL 5.6) : jours triés, écarts calculés en PHP.
     */
    private static function checkGap()
    {
        $p = _DB_PREFIX_;
        $threshold = self::gapThreshold();
        $days = array();
        foreach (self::rows("SELECT DISTINCT DATE(op.date) AS d " . self::saleFrom() . " ORDER BY d") as $r) {
            $days[] = $r['d'];
        }
        if (!$days) {
            return array('status' => 'ok', 'count' => 0, 'amount' => 0.0, 'details' => array());
        }
        $days[] = date('Y-m-d');

        $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
        $details = array();
        $amount = 0.0;
        for ($i = 1, $c = count($days); $i < $c; $i++) {
            $gap = (int) round((strtotime($days[$i]) - strtotime($days[$i - 1])) / 86400);
            if ($gap <= $threshold) {
                continue;
            }
            // Jours pleins sans vente : du lendemain de la dernière à la veille de la suivante.
            $start = date('Y-m-d', strtotime($days[$i - 1] . ' +1 day'));
            $end   = date('Y-m-d', strtotime($days[$i] . ' -1 day'));
            $r = self::rows("SELECT COUNT(*) AS n, SUM(o.total_paid_tax_incl) AS amount
                FROM {$p}orders o
                WHERE o.date_add BETWEEN '{$start} 00:00:00' AND '{$end} 23:59:59'"
                . ($valid ? ' AND ' . $valid : '') . CoolStatsHelpers::shopRestriction('o'));
            if ((int) $r[0]['n'] > 0) {
                $details[] = array('from' => $start, 'to' => $end, 'days' => $gap - 1, 'orders' => (int) $r[0]['n'], 'amount' => round((float) $r[0]['amount'], 2));
                $amount += (float) $r[0]['amount'];
            }
        }
        usort($details, function ($a, $b) { return $b['days'] - $a['days']; });
        return array(
            'status'    => $details ? 'ko' : 'ok',
            'count'     => count($details),
            'amount'    => round($amount, 2),
            'details'   => $details,
        );
    }

    /** Seuil du contrôle 4, en jours sans vente (réglage du module, 7 par défaut). */
    public static function gapThreshold()
    {
        $days = (int) Configuration::get('COOLSTATS_KERAWEN_GAP_DAYS');
        return $days > 0 ? $days : 7;
    }

    /**
     * FROM commun aux requêtes de vente : ventes et leur opération SALE,
     * restreintes aux boutiques du contexte. $join s'insère avant le WHERE.
     */
    private static function saleFrom($join = '')
    {
        $p = _DB_PREFIX_;
        return "FROM {$p}kerawen_525_sale s
            INNER JOIN {$p}kerawen_525_operation op ON op.id_operation = s.id_operation
            {$join}
            WHERE op.type = 'SALE'" . CoolStatsHelpers::shopRestriction('op');
    }

    private static function period($from, $to)
    {
        return " AND op.date BETWEEN '" . pSQL($from) . " 00:00:00' AND '" . pSQL($to) . " 23:59:59'";
    }

    /**
     * executeS qui lève au lieu de rendre false : une erreur SQL et un résultat
     * vide se ressemblent, et c'est précisément ce qu'on ne veut pas confondre ici.
     */
    private static function rows($sql)
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $rows = $db->executeS($sql);
        if (!is_array($rows)) {
            throw new Exception('CoolStats Kerawen : ' . $db->getMsgError());
        }
        return $rows;
    }
}
