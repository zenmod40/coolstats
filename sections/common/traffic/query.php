<?php
/**
 * Section common/traffic — KPI trafic + top pages + sources + devices.
 *
 * Source des données : déléguée à un `CoolStatsTrafficProvider` choisi via
 * la configuration (COOLSTATS_TRAFFIC_PROVIDER). Sans source, ou si la source
 * choisie ne répond pas, la section dit pourquoi et renvoie vers la configuration.
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

require_once _PS_MODULE_DIR_ . 'coolstats/classes/traffic/CoolStatsTrafficFactory.php';

function coolstats_section_traffic(CoolStatsContext $ctx, array $params)
{
    $wanted = (string) Configuration::get('COOLSTATS_TRAFFIC_PROVIDER');
    $provider = ($wanted !== '' && $wanted !== 'none') ? CoolStatsTrafficFactory::getById($wanted) : null;

    if (!$provider || !$provider->isAvailable()) {
        $errors = array(
            'misconfigured'           => 'Réglages incomplets : URL, jeton ou identifiant manquant.',
            'invalid_url'             => 'L\'adresse du serveur doit commencer par http:// ou https://.',
            'unreachable'             => 'Le serveur ne répond pas : adresse, pare-feu ou délai dépassé.',
            'auth_error'              => 'Accès refusé : jeton invalide ou sans droit sur ce site.',
            'invalid_service_account' => 'Le fichier JSON du compte de service est invalide.',
            'auth_failed'             => 'Google refuse l\'authentification du compte de service.',
            'no_table'                => 'Les tables de statistiques de PrestaShop sont absentes.',
            'no_data'                 => 'Aucune visite enregistrée par PrestaShop pour l\'instant.',
        );
        $reason = $provider ? (string) $provider->getUnavailableReason() : '';
        // Bouton vers la configuration : seulement pour qui a le droit de la modifier.
        $context = Context::getContext();
        $module = Module::getInstanceByName('coolstats');
        $canConfigure = $module && $context->employee && $module->getPermission('configure', $context->employee);
        return array(
            'available'      => false,
            'reason'         => $provider ? 'provider_unavailable' : 'no_provider_configured',
            'provider_id'    => $provider ? $provider->getId() : null,
            'provider_label' => $provider ? $provider->getLabel() : null,
            'error'          => isset($errors[$reason]) ? $errors[$reason] : '',
            'config_link'    => $canConfigure ? $context->link->getAdminLink('AdminCoolStatsConfig') : '',
            'cooltrack'      => CoolStatsMatomoTrafficProvider::coolTrackSettings() !== null,
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
        'live'         => method_exists($provider, 'getLiveCounters') ? $provider->getLiveCounters(30) : null,
        // Après tous les appels : une erreur de l'API ne doit pas passer pour des zéros.
        'api_error'    => method_exists($provider, 'getLastError') ? $provider->getLastError() : null,
    );
}
