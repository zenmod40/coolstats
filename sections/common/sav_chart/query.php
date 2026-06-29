<?php
/**
 * Section common/sav_chart — Courbe d'évolution des demandes SAV (service client
 * natif PrestaShop : ps_customer_thread, par date de création du fil).
 *
 * Même moteur que la courbe des commandes : granularité auto (jour/semaine/mois)
 * + série de comparaison (période précédente / N-1) alignée index par index.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsHelpers')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsHelpers.php';
}

function coolstats_section_sav_chart(CoolStatsContext $ctx, array $params)
{
    $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
    $p  = _DB_PREFIX_;
    $from = $params['date_from'];
    $to   = $params['date_to'];
    $idShop = (int) Context::getContext()->shop->id;
    $shopWhere = $idShop ? " AND ct.id_shop = {$idShop}" : '';

    $effectiveTo = min(strtotime($to), strtotime(date('Y-m-d')));
    $days = max(1, ($effectiveTo - strtotime($from)) / 86400 + 1);

    if ($days <= 31) {
        $granularity = 'day';
        $sqlGroup = "DATE(ct.date_add)";
    } elseif ($days <= 365) {
        $granularity = 'week';
        $sqlGroup = "DATE_FORMAT(ct.date_add, '%x-S%v')";
    } else {
        $granularity = 'month';
        $sqlGroup = "DATE_FORMAT(ct.date_add, '%Y-%m')";
    }

    $monthsFr = array('01' => 'Jan', '02' => 'Fév', '03' => 'Mar', '04' => 'Avr',
        '05' => 'Mai', '06' => 'Juin', '07' => 'Juil', '08' => 'Août',
        '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Déc');

    $buildSeries = function ($pFrom, $pTo) use ($db, $p, $granularity, $sqlGroup, $shopWhere, $monthsFr) {
        $effTo = min(strtotime($pTo), strtotime(date('Y-m-d')));
        $buckets = array();
        $cursor = strtotime($pFrom);
        if ($granularity === 'day') {
            while ($cursor <= $effTo) {
                $buckets[date('Y-m-d', $cursor)] = array('label' => date('d', $cursor) . ' ' . $monthsFr[date('m', $cursor)], 'sav' => 0);
                $cursor = strtotime('+1 day', $cursor);
            }
        } elseif ($granularity === 'week') {
            $weekStart = $cursor;
            if (date('N', $weekStart) != 1) {
                $weekStart = strtotime('last monday', $weekStart);
            }
            while ($weekStart <= $effTo) {
                $key = date('o', $weekStart) . '-S' . date('W', $weekStart);
                $buckets[$key] = array('label' => date('d/m', $weekStart), 'sav' => 0);
                $weekStart = strtotime('+7 days', $weekStart);
            }
        } else {
            $cur = date('Y-m', $cursor);
            $endM = date('Y-m', $effTo);
            while ($cur <= $endM) {
                $buckets[$cur] = array('label' => $monthsFr[substr($cur, 5, 2)] . ' ' . substr($cur, 2, 2), 'sav' => 0);
                $cur = date('Y-m', strtotime($cur . '-01 +1 month'));
            }
        }

        $rows = $db->executeS("SELECT {$sqlGroup} AS k, COUNT(*) AS cnt
            FROM {$p}customer_thread ct
            WHERE ct.date_add BETWEEN '" . pSQL($pFrom) . " 00:00:00' AND '" . pSQL($pTo) . " 23:59:59'{$shopWhere}
            GROUP BY k ORDER BY k");
        if (is_array($rows)) {
            foreach ($rows as $r) {
                if (isset($buckets[$r['k']])) {
                    $buckets[$r['k']]['sav'] = (int) $r['cnt'];
                }
            }
        }

        $labels = $sav = array();
        foreach ($buckets as $b) {
            $labels[] = $b['label'];
            $sav[]    = $b['sav'];
        }
        return array('labels' => $labels, 'sav' => $sav);
    };

    $current = $buildSeries($from, $to);
    $labels  = $current['labels'];

    $savCompare = null;
    $compareMode = isset($params['compare_with']) ? (string) $params['compare_with'] : 'none';
    if ($compareMode !== 'none') {
        $cmp = CoolStatsHelpers::getCompareRangeForMode($from, $to, $compareMode);
        if (is_array($cmp) && !empty($cmp['from']) && !empty($cmp['to'])) {
            $cs = $buildSeries($cmp['from'], $cmp['to']);
            $n = count($labels);
            $savCompare = array_slice(array_pad($cs['sav'], $n, 0), 0, $n);
        }
    }

    return array(
        'labels'       => $labels,
        'sav_data'     => $current['sav'],
        'sav_compare'  => $savCompare,
        'compare_mode' => $compareMode,
        'granularity'  => $granularity,
    );
}
