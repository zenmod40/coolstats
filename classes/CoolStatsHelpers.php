<?php
/**
 * CoolStatsHelpers — fonctions SQL utilitaires partagées entre toutes les sections.
 *
 * Toutes les méthodes retournent des fragments SQL prêts à concaténer ou des arrays
 * { join, where } pour les jointures conditionnelles.
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

class CoolStatsHelpers
{
    /**
     * Retourne la condition SQL "o.date_add BETWEEN '...' AND '...'".
     *
     * @param string $alias  Alias de la table orders (ex: 'o')
     * @param string $from   Date au format Y-m-d
     * @param string $to     Date au format Y-m-d
     * @return string
     */
    public static function getDateRangeFilter($alias, $from, $to)
    {
        $from = pSQL($from);
        $to   = pSQL($to);
        return "{$alias}.date_add BETWEEN '{$from} 00:00:00' AND '{$to} 23:59:59'";
    }

    /**
     * Retourne la période de comparaison « précédente », avec détection calendaire :
     *  - Si la période = année calendaire entière → année précédente
     *  - Si la période = trimestre calendaire entier → trimestre précédent
     *  - Si la période = mois calendaire entier → mois précédent
     *  - Sinon → fenêtre glissante (même nombre de jours juste avant)
     *
     * Cette logique évite le décalage d'1 jour quand l'utilisateur attend une
     * comparaison année-sur-année (« Année -1 » vs son année précédente).
     *
     * @return array{from: string, to: string}
     */
    public static function getCompareRange($from, $to)
    {
        $tFrom = strtotime($from);
        $tTo   = strtotime($to);

        // Année calendaire complète : 01-01 → 12-31
        if (date('m-d', $tFrom) === '01-01' && date('m-d', $tTo) === '12-31') {
            return array(
                'from' => date('Y-m-d', strtotime($from . ' -1 year')),
                'to'   => date('Y-m-d', strtotime($to . ' -1 year')),
            );
        }

        // Trimestre calendaire complet : début sur Q1/Q2/Q3/Q4, fin = dernier jour du dernier mois du Q
        $monthFrom = (int) date('m', $tFrom);
        if (date('d', $tFrom) === '01'
            && in_array($monthFrom, array(1, 4, 7, 10), true)) {
            $expectedEnd = date('Y-m-t', strtotime(date('Y-m-01', $tFrom) . ' +2 months'));
            if (date('Y-m-d', $tTo) === $expectedEnd) {
                $prevQStart = strtotime(date('Y-m-01', $tFrom) . ' -3 months');
                return array(
                    'from' => date('Y-m-01', $prevQStart),
                    'to'   => date('Y-m-t', strtotime(date('Y-m-01', $prevQStart) . ' +2 months')),
                );
            }
        }

        // Mois calendaire complet : début = jour 1, fin = dernier jour du même mois
        if (date('d', $tFrom) === '01'
            && date('Y-m-d', $tTo) === date('Y-m-t', $tFrom)) {
            return array(
                'from' => date('Y-m-01', strtotime($from . ' -1 month')),
                'to'   => date('Y-m-t', strtotime($from . ' -1 month')),
            );
        }

        // Fallback : fenêtre glissante (même nombre de jours juste avant)
        $days = max(1, ($tTo - $tFrom) / 86400 + 1);
        $prevTo   = date('Y-m-d', strtotime($from . ' -1 day'));
        $prevFrom = date('Y-m-d', strtotime($prevTo . ' -' . ($days - 1) . ' days'));
        return array('from' => $prevFrom, 'to' => $prevTo);
    }

    /**
     * Liste d'états de commande à inclure (ou exclure) selon la config wizard.
     *
     * @param string $type 'valid' (NOT IN cancelled) | 'cancelled' (IN cancelled) | 'all'
     * @param string $alias
     * @return string|null Condition SQL ou null si type='all'
     */
    public static function getOrderStateCondition($type = 'valid', $alias = 'o')
    {
        if ($type === 'all') {
            return null;
        }

        $configKey = array(
            'valid'     => 'COOLSTATS_VALID_STATES',
            'cancelled' => 'COOLSTATS_CANCELLED_STATES',
            'shipped'   => 'COOLSTATS_SHIPPED_STATES',
            'delivered' => 'COOLSTATS_DELIVERED_STATES',
        );

        if ($type === 'valid') {
            // Si "valides" explicitement défini, on l'utilise (mode strict).
            $valid = trim((string) Configuration::get($configKey['valid']));
            if ($valid !== '') {
                $valid = implode(',', array_map('intval', explode(',', $valid)));
                if ($valid !== '') {
                    $base = "{$alias}.current_state IN ({$valid})";
                    return self::wrapValidExtras($base, $alias);
                }
            }
            // Sinon : tout sauf annulés (fallback permissif).
            $cancelled = trim((string) Configuration::get($configKey['cancelled']));
            $cancelled = $cancelled !== '' ? $cancelled : '6,7';
            $cancelled = implode(',', array_map('intval', explode(',', $cancelled)));
            if ($cancelled === '') $cancelled = '0';
            return self::wrapValidExtras("{$alias}.current_state NOT IN ({$cancelled})", $alias);
        }

        if (!isset($configKey[$type])) {
            return null;
        }
        $states = trim((string) Configuration::get($configKey[$type]));
        // Defaults raisonnables si pas configuré
        if ($states === '') {
            $defaults = array('cancelled' => '6,7', 'shipped' => '4', 'delivered' => '5');
            $states = $defaults[$type];
        }
        $states = implode(',', array_map('intval', explode(',', $states)));
        if ($states === '') return null;
        return "{$alias}.current_state IN ({$states})";
    }

    /**
     * Ajoute aux conditions "valides" les filtres métier (exclusion commandes gratuites, etc.).
     */
    private static function wrapValidExtras($base, $alias)
    {
        $excludeFree = (int) Configuration::get('COOLSTATS_EXCLUDE_FREE_ORDERS');
        if ($excludeFree) {
            return "({$base}) AND {$alias}.total_paid_tax_incl > 0";
        }
        return $base;
    }

    /**
     * Expression SQL du CA selon la config "inclure les frais de port".
     * Utilisée dans les SUM/AVG pour les sections KPI, country, paiement, etc.
     */
    public static function getRevenueExpression($alias = 'o')
    {
        $includeShipping = (int) Configuration::get('COOLSTATS_INCLUDE_SHIPPING_IN_CA');
        if ($includeShipping === 0) {
            // Évite de descendre négatif si shipping > paid (cas marginaux : avoirs, frais réintégrés).
            return "GREATEST({$alias}.total_paid_tax_incl - {$alias}.total_shipping_tax_incl, 0)";
        }
        return "{$alias}.total_paid_tax_incl";
    }

    /**
     * Condition SQL : commandes REMBOURSÉES (vrais retours), pour le « taux de
     * retour ». États lus depuis COOLSTATS_RETURN_REFUNDED_STATES (défaut 7) —
     * même source que la popup retours, pour garder KPI ↔ popup cohérents.
     * N'inclut PAS les annulations (état 6) : une annulation n'est pas un retour.
     */
    public static function getRefundedStateCondition($alias = 'o')
    {
        $states = trim((string) Configuration::get('COOLSTATS_RETURN_REFUNDED_STATES'));
        if ($states === '') {
            $states = '7';
        }
        $states = implode(',', array_map('intval', explode(',', $states)));
        if ($states === '') {
            $states = '7';
        }
        return "{$alias}.current_state IN ({$states})";
    }

    /**
     * Retourne le bloc de jointure pour filtrer par pays ISO2.
     *
     * @param string|null $iso     ISO 3166-1 alpha-2 (ex: 'FR')
     * @param string      $alias   Alias de la table orders
     * @return string Bloc INNER JOIN ou '' si pas de filtre
     */
    public static function getCountryJoin($iso, $alias = 'o')
    {
        if (!$iso || !preg_match('/^[A-Z]{2}$/', strtoupper($iso))) {
            return '';
        }
        $iso = pSQL(strtoupper($iso));
        $p = _DB_PREFIX_;
        return "INNER JOIN {$p}address a_cf ON a_cf.id_address = {$alias}.id_address_delivery
            INNER JOIN {$p}country co_cf ON co_cf.id_country = a_cf.id_country AND co_cf.iso_code = '{$iso}'";
    }

    /**
     * Lit et valide le filtre `country` depuis l'URL.
     *
     * @return string|null Code ISO ou null
     */
    public static function readCountryFilter()
    {
        $iso = strtoupper(trim((string) Tools::getValue('country', '')));
        return preg_match('/^[A-Z]{2}$/', $iso) ? $iso : null;
    }

    /**
     * Lit et valide le filtre `channels[]` ou `channels=a,b,c` depuis l'URL.
     *
     * @return string[]
     */
    public static function readChannelsFilter()
    {
        $raw = Tools::getValue('channels', '');
        if (is_array($raw)) {
            return array_values(array_filter(array_map('strval', $raw)));
        }
        $raw = trim((string) $raw);
        if ($raw === '') {
            return array();
        }
        return array_values(array_filter(array_map('trim', explode(',', $raw))));
    }

    /**
     * Bloc JOIN + WHERE pour filtrer les commandes par canal de vente
     * (marketplace) selon les channels actifs.
     *
     * Source : `marketplace_orders` (Common Service). Si la table n'existe pas
     * ou que `$channels` est vide → on retourne '' (pas de filtrage).
     *
     * Convention sur les codes channels :
     *   - 'direct'        → commandes SANS row dans marketplace_orders
     *   - 'amazon_fbm'    → mo.channel = 'MFN'
     *   - 'amazon_fba'    → mo.channel = 'AFN'
     *   - 'cdiscount'     → mo.cd_channel_name IS NOT NULL OU sales_channel = 'CDISFR'
     *   - 'decathlon_fbm' → mo.sales_channel = 'decathlon.eu'
     *   - 'decathlon_fbd' → mo.sales_channel = 'decathlon.eu2'
     *   - 'other'         → tout le reste (mo.id_order non null mais aucun WHEN ne match)
     *
     * @param string[] $channels Codes channels actifs (multi-select)
     * @param string   $alias    Alias de la table orders dans le SQL appelant
     * @return string Bloc SQL à injecter après la table orders (LEFT JOIN + AND ...).
     *                Vide si pas de filtre actif ou table absente.
     */
    public static function getChannelsJoin(array $channels, $alias = 'o')
    {
        if (empty($channels)) return '';

        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p  = _DB_PREFIX_;

        // Garde : table doit exister
        $tableExists = (bool) $db->getValue(
            "SELECT COUNT(*) FROM information_schema.tables
             WHERE table_schema = DATABASE() AND table_name = '" . pSQL($p . 'marketplace_orders') . "'"
        );
        if (!$tableExists) return '';

        // Détecte les colonnes présentes (cohérent avec
        // sections/marketplace/breakdown/query.php qui fait la même garde).
        $rows = $db->executeS(
            "SELECT column_name FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = '" . pSQL($p . 'marketplace_orders') . "'"
        );
        $cols = array();
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $name = isset($r['column_name']) ? $r['column_name']
                      : (isset($r['COLUMN_NAME']) ? $r['COLUMN_NAME'] : '');
                if ($name !== '') $cols[] = strtolower($name);
            }
        }
        $hasChan  = in_array('channel',         $cols, true);
        $hasSales = in_array('sales_channel',   $cols, true);
        $hasCdCn  = in_array('cd_channel_name', $cols, true);

        // Construction des conditions WHERE par channel demandé
        $orParts = array();
        foreach ($channels as $ch) {
            switch ($ch) {
                case 'direct':
                    $orParts[] = "mo_cf.id_order IS NULL";
                    break;
                case 'amazon_fbm':
                    if ($hasChan) $orParts[] = "mo_cf.channel = 'MFN'";
                    break;
                case 'amazon_fba':
                    if ($hasChan) $orParts[] = "mo_cf.channel = 'AFN'";
                    break;
                case 'cdiscount':
                    $sub = array();
                    if ($hasCdCn)  $sub[] = "mo_cf.cd_channel_name IS NOT NULL";
                    if ($hasSales) $sub[] = "mo_cf.sales_channel = 'CDISFR'";
                    if (!empty($sub)) $orParts[] = '(' . implode(' OR ', $sub) . ')';
                    break;
                case 'decathlon_fbm':
                    if ($hasSales) $orParts[] = "mo_cf.sales_channel = 'decathlon.eu'";
                    break;
                case 'decathlon_fbd':
                    if ($hasSales) $orParts[] = "mo_cf.sales_channel = 'decathlon.eu2'";
                    break;
                case 'other':
                    // "other" = mo_cf.id_order non null mais aucun WHEN connu ne match.
                    // En pratique on l'omet (rare en filtre) — si besoin futur l'ajouter
                    // ici via une négation des autres conditions.
                    break;
            }
        }

        if (empty($orParts)) return '';

        // INNER JOIN sur une subquery qui sélectionne les id_order matchant le filtre.
        // Pattern subquery : marche à la fois pour "direct" (mo.id_order IS NULL) et
        // pour les channels nominaux, et s'injecte proprement comme un simple JOIN
        // sans nécessiter de WHERE additionnel côté requête appelante.
        return "INNER JOIN (
            SELECT o2.id_order
            FROM {$p}orders o2
            LEFT JOIN {$p}marketplace_orders mo_cf ON mo_cf.id_order = o2.id_order
            WHERE " . implode(' OR ', $orParts) . "
        ) chan_cf ON chan_cf.id_order = {$alias}.id_order";
    }

    /**
     * Lit et valide le filtre de recherche produit (?product=).
     * Recherche par nom, référence ou EAN. Minimum 2 caractères.
     *
     * @return string|null Terme brut validé (longueur) ou null si absent/trop court.
     */
    public static function readProductFilter()
    {
        $term = trim((string) Tools::getValue('product', ''));
        return (Tools::strlen($term) >= 2) ? $term : null;
    }

    /**
     * Clause WHERE `EXISTS (...)` : ne garde que les commandes contenant un
     * article dont le nom / la référence / l'EAN correspond au terme (produit
     * ET déclinaison). Sert à scoper TOUS les blocs orientés commandes
     * (KPI, graphiques, pays, etc.) sur le produit recherché.
     *
     * @param string $term       Terme de recherche (déjà validé via readProductFilter)
     * @param string $orderAlias Alias de la table orders dans la requête appelante
     * @return string Clause SQL à concaténer (avec AND ...) ou '' si pas de terme.
     */
    public static function getProductFilterWhereSQL($term, $orderAlias = 'o')
    {
        $term = trim((string) $term);
        if (Tools::strlen($term) < 2) {
            return '';
        }
        $like = '%' . pSQL($term) . '%';
        $p = _DB_PREFIX_;
        return "EXISTS (
            SELECT 1
            FROM {$p}order_detail od_pf
            LEFT JOIN {$p}product pr_pf ON pr_pf.id_product = od_pf.product_id
            LEFT JOIN {$p}product_attribute pa_pf ON pa_pf.id_product_attribute = od_pf.product_attribute_id
            WHERE od_pf.id_order = {$orderAlias}.id_order
              AND (od_pf.product_name LIKE '{$like}'
                OR od_pf.product_reference LIKE '{$like}'
                OR pr_pf.reference LIKE '{$like}'
                OR pr_pf.ean13 LIKE '{$like}'
                OR pa_pf.reference LIKE '{$like}'
                OR pa_pf.ean13 LIKE '{$like}')
        )";
    }

    /**
     * Condition de correspondance DIRECTE sur la ligne de commande (order_detail) :
     * utilisée par les tableaux Top (produits / catégories) pour n'afficher QUE
     * le(s) produit(s) recherché(s) — et non les co-achats. Auto-suffisante :
     * ne requiert que l'alias order_detail (pas de join produit côté appelant).
     *
     * @param string $term    Terme de recherche (déjà validé)
     * @param string $odAlias Alias de la table order_detail dans la requête appelante
     * @return string Condition SQL (sans AND) ou '' si pas de terme.
     */
    public static function getProductLineMatchSQL($term, $odAlias = 'od')
    {
        $term = trim((string) $term);
        if (Tools::strlen($term) < 2) {
            return '';
        }
        $like = '%' . pSQL($term) . '%';
        $p = _DB_PREFIX_;
        return "({$odAlias}.product_name LIKE '{$like}'
            OR {$odAlias}.product_reference LIKE '{$like}'
            OR EXISTS (SELECT 1 FROM {$p}product pr_lm
                WHERE pr_lm.id_product = {$odAlias}.product_id
                AND (pr_lm.reference LIKE '{$like}' OR pr_lm.ean13 LIKE '{$like}'))
            OR EXISTS (SELECT 1 FROM {$p}product_attribute pa_lm
                WHERE pa_lm.id_product_attribute = {$odAlias}.product_attribute_id
                AND (pa_lm.reference LIKE '{$like}' OR pa_lm.ean13 LIKE '{$like}')))";
    }

    /**
     * Bloc LEFT JOIN d'une table dérivée renvoyant l'image « cover, sinon 1ʳᵉ »
     * par produit. Le caller sélectionne `{$joinAlias}.id_image`.
     *
     * @param string $prodCol   Colonne id_product côté requête (ex: 'p.id_product', 'od.product_id')
     * @param string $joinAlias Alias de la table dérivée
     * @return string Bloc LEFT JOIN.
     */
    public static function getProductImageJoin($prodCol, $joinAlias = 'img_cf')
    {
        $p = _DB_PREFIX_;
        return "LEFT JOIN (
            SELECT id_product, COALESCE(MAX(CASE WHEN cover = 1 THEN id_image END), MIN(id_image)) AS id_image
            FROM {$p}image
            GROUP BY id_product
        ) {$joinAlias} ON {$joinAlias}.id_product = {$prodCol}";
    }

    /**
     * Lit la fenêtre de dates depuis l'URL ou applique la période par défaut configurée.
     *
     * @return array{from:string,to:string}
     */
    public static function readDateRange()
    {
        $from = Tools::getValue('date_from');
        $to   = Tools::getValue('date_to');

        if ($from && $to && preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $from) && preg_match('/^\d{4}-\d{2}-\d{2}$/', (string) $to)) {
            return array('from' => $from, 'to' => $to);
        }

        // Pas de dates en URL : applique la période par défaut configurée.
        $preset = (string) Configuration::get('COOLSTATS_DEFAULT_PERIOD');
        return self::computeRangeFromPreset($preset ?: 'this_month');
    }

    /**
     * Calcule une fenêtre de dates à partir d'un preset PHP.
     */
    public static function computeRangeFromPreset($preset)
    {
        $now = time();
        $y = (int) date('Y', $now);
        $m = (int) date('m', $now);
        $d = (int) date('w', $now); // 0 = dimanche, 1 = lundi, ...
        $today = date('Y-m-d', $now);

        switch ($preset) {
            case 'this_week':
                $monday = strtotime(date('N', $now) === '1' ? 'today' : 'last monday', $now);
                return array('from' => date('Y-m-d', $monday), 'to' => $today);
            case 'last_week':
                $thisMon = strtotime(date('N', $now) === '1' ? 'today' : 'last monday', $now);
                return array(
                    'from' => date('Y-m-d', strtotime('-7 days', $thisMon)),
                    'to'   => date('Y-m-d', strtotime('-1 day', $thisMon)),
                );
            case 'last_month':
                return array(
                    'from' => date('Y-m-01', strtotime('first day of last month', $now)),
                    'to'   => date('Y-m-t', strtotime('last day of last month', $now)),
                );
            case 'this_quarter':
                $q = (int) floor(($m - 1) / 3);
                return array(
                    'from' => sprintf('%04d-%02d-01', $y, $q * 3 + 1),
                    'to'   => $today,
                );
            case 'this_year':
                return array('from' => sprintf('%04d-01-01', $y), 'to' => $today);
            case 'last_year':
                return array(
                    'from' => sprintf('%04d-01-01', $y - 1),
                    'to'   => sprintf('%04d-12-31', $y - 1),
                );
            case 'last_30':
                return array(
                    'from' => date('Y-m-d', strtotime('-29 days', $now)),
                    'to'   => $today,
                );
            case 'this_month':
            default:
                return array('from' => date('Y-m-01', $now), 'to' => $today);
        }
    }

    /**
     * Lit le mode de comparaison demandé (?compare_with=).
     *
     * @return string 'prev' (période immédiatement avant), 'yoy' (n-1 an), 'none'
     */
    public static function readCompareMode()
    {
        $m = (string) Tools::getValue('compare_with', 'prev');
        return in_array($m, array('prev', 'yoy', 'none'), true) ? $m : 'prev';
    }

    /**
     * Calcule la fenêtre de comparaison effective.
     *
     * @return array{from:string,to:string}|null null si compare='none'
     */
    public static function getCompareRangeForMode($from, $to, $mode)
    {
        if ($mode === 'none') {
            return null;
        }
        if ($mode === 'yoy') {
            return array(
                'from' => date('Y-m-d', strtotime($from . ' -1 year')),
                'to'   => date('Y-m-d', strtotime($to . ' -1 year')),
            );
        }
        return self::getCompareRange($from, $to);
    }

    /**
     * Calcule un % d'évolution arrondi à 1 décimale.
     */
    public static function trend($current, $previous)
    {
        $current = (float) $current;
        $previous = (float) $previous;
        if ($previous == 0.0) {
            return $current > 0 ? 100.0 : 0.0;
        }
        return round((($current - $previous) / $previous) * 100, 1);
    }
}
