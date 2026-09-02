<?php
/**
 * CoolStats Dashboard — mise à jour 1.0.9
 * Accroche le module sur le tableau de bord natif de PrestaShop.
 *
 * @author    ZM40 — Nicolas Michaud (Magic Garden)
 * @copyright 2026 Nicolas Michaud — ZM40 / Magic Garden
 * @license   https://opensource.org/licenses/OSL-3.0 Open Software License version 3.0
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

function upgrade_module_1_0_9($module)
{
    return $module->registerHook('dashboardZoneTwo')
        && $module->registerHook('dashboardData');
}
