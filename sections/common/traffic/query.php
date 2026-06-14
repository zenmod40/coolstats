<?php
/**
 * Section common/traffic — KPI trafic + top pages + sources + devices.
 *
 * Source des données : déléguée à un `CoolStatsTrafficProvider` choisi via
 * `CoolStatsTrafficFactory::getActive()`. V1 : provider natif PS uniquement.
 * V2 : Matomo / GA4 / Plausible se branchent sans toucher à cette section.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsTrafficFactory.php';

function coolstats_section_traffic(CoolStatsContext $ctx, array $params)
{
    $provider = CoolStatsTrafficFactory::getActive();

    if (!$provider) {
        return array(
            'available'        => false,
            'reason'           => 'no_provider_configured',
            'provider_id'      => null,
        );
    }

    $from = $params['date_from'];
    $to   = $params['date_to'];
    $context = array(
        'country'  => isset($params['country']) ? $params['country'] : null,
        'channels' => isset($params['channels']) ? $params['channels'] : array(),
    );

    $kpi      = $provider->getKpi($from, $to, $context);
    $topPages = $provider->getTopPages($from, $to, 5, $context);
    $sources  = $provider->getTopSources($from, $to, 5, $context);
    $devices  = $provider->getDevices($from, $to, $context);

    return array(
        'available'    => true,
        'provider_id'  => $provider->getId(),
        'provider_label' => $provider->getLabel(),
        'kpi'          => $kpi,
        'top_pages'    => $topPages,
        'top_sources'  => $sources,
        'devices'      => $devices,
    );
}
