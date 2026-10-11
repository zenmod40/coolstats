<?php
/**
 * Section common/kerawen_vat — TVA de la caisse Kerawen par mois et par taux.
 *
 * Une ligne par mois et par taux (le format de l'export CSV pour le comptable),
 * avec la part magasin et la part web. Montants lus dans la ventilation TVA des
 * ventes NF525, sans recalcul.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

if (!class_exists('CoolStatsKerawen')) {
    require_once _PS_MODULE_DIR_ . 'coolstats/classes/CoolStatsKerawen.php';
}

function coolstats_section_kerawen_vat(CoolStatsContext $ctx, array $params)
{
    $col = CoolStatsHelpers::taxMode() === 'ht' ? 'ht' : 'ttc';
    $monthsFr = array('01' => 'janv.', '02' => 'févr.', '03' => 'mars', '04' => 'avr.',
        '05' => 'mai', '06' => 'juin', '07' => 'juil.', '08' => 'août',
        '09' => 'sept.', '10' => 'oct.', '11' => 'nov.', '12' => 'déc.');

    $rows = array();
    $total = array('ht' => 0.0, 'tax' => 0.0, 'ttc' => 0.0, 'store' => 0.0, 'web' => 0.0);
    foreach (CoolStatsKerawen::vatByMonth($params['date_from'], $params['date_to']) as $r) {
        $key = $r['month'] . '|' . $r['rate'];
        if (!isset($rows[$key])) {
            $rows[$key] = array(
                'month'       => $r['month'],
                'month_label' => $monthsFr[substr($r['month'], 5, 2)] . ' ' . substr($r['month'], 0, 4),
                'rate'        => $r['rate'],
                'ht' => 0.0, 'tax' => 0.0, 'ttc' => 0.0, 'store' => 0.0, 'web' => 0.0,
            );
        }
        $rows[$key]['ht']  += $r['ht'];
        $rows[$key]['tax'] += $r['tax'];
        $rows[$key]['ttc'] += $r['ttc'];
        $rows[$key][$r['channel']] += $r[$col];
        $total['ht']  += $r['ht'];
        $total['tax'] += $r['tax'];
        $total['ttc'] += $r['ttc'];
        $total[$r['channel']] += $r[$col];
    }

    return array(
        'rows'      => array_values($rows),
        'total'     => $total,
        'tax_label' => $col === 'ht' ? 'HT' : 'TTC',
    );
}
