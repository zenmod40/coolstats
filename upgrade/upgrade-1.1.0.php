<?php
/**
 * CoolStats Dashboard — mise à jour 1.1.0
 * Seuil par défaut du contrôle « trou dans le journal » de la caisse Kerawen.
 *
 * @author    ZM40 — Nicolas Michaud (Magic Garden)
 * @copyright 2026 Nicolas Michaud — ZM40 / Magic Garden
 * @license   https://opensource.org/licenses/OSL-3.0 Open Software License version 3.0
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

function upgrade_module_1_1_0($module)
{
    return Configuration::updateValue('COOLSTATS_KERAWEN_GAP_DAYS', 7);
}
