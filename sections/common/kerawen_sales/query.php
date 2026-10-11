<?php
/**
 * Section common/kerawen_sales — CA de la caisse Kerawen (magasin + web).
 *
 * Calculé sur les écritures de vente NF525 (CoolStatsKerawen), jamais sur les
 * totaux affichés par Kerawen. Ce CA n'est pas celui des commandes PrestaShop
 * (événements fiscaux, avoirs en négatif) : la ligne de rapprochement les
 * montre côte à côte sans les mélanger.
 *
 * Le bouton « Contrôle caisse » porte le statut des contrôles d'intégrité (tout
 * l'historique, sans le filtre de période) et ouvre leur détail. Chaque affichage
 * rafraîchit aussi le statut utilisé par l'alerte du tableau de bord natif.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsKerawen')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsKerawen.php';
}

function coolstats_section_kerawen_sales(CoolStatsContext $ctx, array $params)
{
    $from = $params['date_from'];
    $to   = $params['date_to'];
    $col  = CoolStatsHelpers::taxMode() === 'ht' ? 'ht' : 'ttc';

    $summary = function ($f, $t) use ($col) {
        $tills = CoolStatsKerawen::salesByTill($f, $t);
        $s = array('total' => 0.0, 'store' => 0.0, 'web' => 0.0, 'nb' => 0, 'nb_store' => 0, 'tills' => $tills);
        foreach ($tills as $r) {
            $s['total'] += $r[$col];
            $s['nb']    += $r['nb'];
            if ($r['id_till'] > 0) {
                $s['store']    += $r[$col];
                $s['nb_store'] += $r['nb'];
            } else {
                $s['web'] += $r[$col];
            }
        }
        $s['vat'] = CoolStatsKerawen::vatTotal($f, $t);
        $s['avg_store'] = $s['nb_store'] > 0 ? round($s['store'] / $s['nb_store'], 2) : 0.0;
        return $s;
    };

    $cur = $summary($from, $to);

    $kpis = array('total', 'store', 'web', 'vat', 'nb', 'avg_store');
    $trends = array_fill_keys($kpis, null);
    $compareMode = isset($params['compare_with']) ? (string) $params['compare_with'] : 'none';
    $cmp = CoolStatsHelpers::getCompareRangeForMode($from, $to, $compareMode);
    if (is_array($cmp)) {
        $prev = $summary($cmp['from'], $cmp['to']);
        foreach ($kpis as $k) {
            $trends[$k] = CoolStatsHelpers::trend($cur[$k], $prev[$k]);
        }
    }

    // Répartition : le web d'abord, puis une ligne par caisse physique.
    $tills = array();
    foreach ($cur['tills'] as $r) {
        $tills[] = array(
            'name'   => $r['id_till'] > 0 ? ($r['till_name'] !== '' ? $r['till_name'] : '#' . $r['id_till']) : 'Web',
            'web'    => $r['id_till'] === 0,
            'nb'     => $r['nb'],
            'amount' => $r[$col],
            'pct'    => $cur['total'] != 0 ? round($r[$col] / $cur['total'] * 100, 1) : 0,
        );
    }

    // Courbe : par jour jusqu'à 62 jours, par mois au-delà.
    $effectiveTo = min(strtotime($to), strtotime(date('Y-m-d')));
    $byDay = ($effectiveTo - strtotime($from)) / 86400 + 1 <= 62;
    $monthsFr = array('01' => 'Jan', '02' => 'Fév', '03' => 'Mar', '04' => 'Avr',
        '05' => 'Mai', '06' => 'Juin', '07' => 'Juil', '08' => 'Août',
        '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Déc');
    $buckets = array();
    if ($byDay) {
        for ($c = strtotime($from); $c <= $effectiveTo; $c = strtotime('+1 day', $c)) {
            $buckets[date('Y-m-d', $c)] = date('d', $c) . ' ' . $monthsFr[date('m', $c)];
        }
    } else {
        for ($m = date('Y-m', strtotime($from)); $m <= date('Y-m', $effectiveTo); $m = date('Y-m', strtotime($m . '-01 +1 month'))) {
            $buckets[$m] = $monthsFr[substr($m, 5, 2)] . ' ' . substr($m, 2, 2);
        }
    }
    $series = array('store' => array_fill_keys(array_keys($buckets), 0.0), 'web' => array_fill_keys(array_keys($buckets), 0.0));
    foreach (CoolStatsKerawen::series($from, $to, $byDay ? '%Y-%m-%d' : '%Y-%m') as $r) {
        if (isset($series[$r['channel']][$r['k']])) {
            $series[$r['channel']][$r['k']] = round($r[$col], 2);
        }
    }

    $reconcile = coolstats_kerawen_reconcile($from, $to, $col, $cur['total']);

    $checks = CoolStatsKerawen::integrity();
    $failures = CoolStatsKerawen::countFailures($checks);
    $errors = 0;
    foreach ($checks as $c) {
        if ($c['status'] === 'error') {
            $errors++;
        }
    }

    return array(
        'checks'       => $checks,
        'check_status' => $failures ? 'ko' : ($errors ? 'error' : 'ok'),
        'threshold'    => CoolStatsKerawen::gapThreshold(),
        'total'        => round($cur['total'], 2),
        'store'        => round($cur['store'], 2),
        'web'          => round($cur['web'], 2),
        'vat'          => $cur['vat'],
        'nb'           => $cur['nb'],
        'avg_store'    => $cur['avg_store'],
        'trends'       => $trends,
        'tills'        => $tills,
        'labels'       => array_values($buckets),
        'store_series' => array_values($series['store']),
        'web_series'   => array_values($series['web']),
        'reconcile'    => $reconcile,
        'tax_label'    => $col === 'ht' ? 'HT' : 'TTC',
    );
}

/**
 * Écart entre le CA fiscal Kerawen (K) et le CA commandes du bandeau (C, même
 * calcul : états valides, getRevenueExpression, commandes créées sur la période ;
 * sans les filtres pays / canal / produit, que Kerawen ne connaît pas), décomposé :
 *  A  écritures de la période sur des commandes créées hors période (avoirs, corrections) ;
 *  B  écritures de la période sur des commandes de la période dans un état non valide ;
 *  C  − CA des commandes valides de la période sans aucune écriture Kerawen sur la période ;
 *  D  le reste (frais de port exclus du CA, total_paid ≠ montant Kerawen, écriture sans commande…).
 * A + B + C + D = K − C par construction. Rien n'est arrondi avant la somme.
 */
function coolstats_kerawen_reconcile($from, $to, $col, $kerawenTotal)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p = _DB_PREFIX_;
    $valid = CoolStatsHelpers::getOrderStateCondition('valid', 'o');
    $validSql = $valid ? '(' . $valid . ')' : '1';
    $shop = CoolStatsHelpers::shopRestriction('o');
    $start = $from . ' 00:00:00';
    $end = $to . ' 23:59:59';

    $amounts = CoolStatsKerawen::amountsByPsOrder($from, $to);

    // C (CA commandes) et le CA des commandes valides sans écriture Kerawen.
    $ordersCa = 0.0;
    $withoutEntry = 0.0;
    $rows = $db->executeS('SELECT o.id_order, ' . CoolStatsHelpers::getRevenueExpression('o') . ' AS rev
        FROM ' . $p . 'orders o
        WHERE ' . CoolStatsHelpers::getDateRangeFilter('o', $from, $to) . ' AND ' . $validSql . $shop);
    foreach (is_array($rows) ? $rows : array() as $r) {
        $ordersCa += (float) $r['rev'];
        if (!isset($amounts[(int) $r['id_order']])) {
            $withoutEntry += (float) $r['rev'];
        }
    }

    // A et B : les commandes PrestaShop qui portent une écriture Kerawen de la période.
    $a = 0.0;
    $b = 0.0;
    $bStates = array();
    $ids = array_filter(array_keys($amounts));
    if ($ids) {
        $idLang = (int) Context::getContext()->language->id;
        $rows = $db->executeS('SELECT o.id_order, o.date_add, IF(' . $validSql . ', 1, 0) AS is_valid, osl.name AS state_name
            FROM ' . $p . 'orders o
            LEFT JOIN ' . $p . 'order_state_lang osl ON osl.id_order_state = o.current_state AND osl.id_lang = ' . $idLang . '
            WHERE o.id_order IN (' . implode(',', array_map('intval', $ids)) . ')' . $shop);
        foreach (is_array($rows) ? $rows : array() as $r) {
            $amount = $amounts[(int) $r['id_order']][$col];
            if ($r['date_add'] < $start || $r['date_add'] > $end) {
                $a += $amount;
            } elseif (!(int) $r['is_valid']) {
                $b += $amount;
                $bStates[(string) $r['state_name']] = true;
            }
        }
    }

    $gap = $kerawenTotal - $ordersCa;
    $c = $withoutEntry != 0 ? -$withoutEntry : 0.0; // pas de « -0,00 € » à l'affichage
    $d = $gap - $a - $b - $c;

    return array(
        'orders_ca' => $ordersCa,
        'gap'       => $gap,
        'a'         => $a,
        'b'         => $b,
        'b_states'  => implode(', ', array_keys($bStates)),
        'c'         => $c,
        'd'         => abs($d) < 0.005 ? 0.0 : $d,
    );
}
