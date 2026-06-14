<?php
/**
 * CoolStatsPrefs — gestion des préférences utilisateur (sections affichées).
 *
 * Stockage par (id_employee, id_shop, theme_id, section_id). Si aucune ligne n'existe pour
 * un employé sur le thème courant, les défauts du manifest s'appliquent (enabled + order).
 *
 * Le scope `theme_id` permet à chaque utilisateur d'avoir des layouts différents
 * selon le thème visuel actif (ex: ordre/visibilité distincts entre Cozy et Aurora).
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

class CoolStatsPrefs
{
    /**
     * Retourne le thème visuel actif (depuis la config BO).
     */
    public static function getActiveTheme()
    {
        $t = (string) Configuration::get('COOLSTATS_VISUAL_THEME');
        return $t !== '' ? $t : 'default';
    }

    /**
     * Préférences pour l'employé courant + shop courant + thème courant.
     *
     * @return array<string,array{enabled:int,display_order:int}>
     */
    public static function getCurrent()
    {
        $ctx = Context::getContext();
        if (!$ctx || !$ctx->employee || !$ctx->employee->id) {
            return array();
        }
        $idShop = ($ctx->shop && $ctx->shop->id) ? (int) $ctx->shop->id : 1;
        return self::getFor((int) $ctx->employee->id, $idShop, self::getActiveTheme());
    }

    /**
     * @return array<string,array{enabled:int,display_order:int}>
     */
    public static function getFor($idEmployee, $idShop, $themeId = 'default')
    {
        $db = Db::getInstance(_PS_USE_SQL_SLAVE_);
        $p = _DB_PREFIX_;
        $rows = $db->executeS("SELECT section_id, enabled, display_order
            FROM {$p}coolstats_section_prefs
            WHERE id_employee = " . (int) $idEmployee . "
            AND id_shop = " . (int) $idShop . "
            AND theme_id = '" . pSQL((string) $themeId) . "'");
        $prefs = array();
        if (is_array($rows)) {
            foreach ($rows as $r) {
                $prefs[$r['section_id']] = array(
                    'enabled'       => (int) $r['enabled'],
                    'display_order' => (int) $r['display_order'],
                );
            }
        }
        return $prefs;
    }

    /**
     * Sauvegarde un lot de préférences (upsert par UNIQUE KEY).
     *
     * @param array<int,array{id:string,enabled:int,display_order?:int}> $sections
     * @return bool
     */
    public static function save($idEmployee, $idShop, array $sections, $themeId = 'default')
    {
        if (!$idEmployee || empty($sections)) {
            return false;
        }
        $db = Db::getInstance();
        $p = _DB_PREFIX_;
        $themeIdEsc = pSQL((string) $themeId);
        $ok = true;
        foreach ($sections as $s) {
            if (empty($s['id'])) continue;
            $sid = pSQL($s['id']);
            $en  = (int) !empty($s['enabled']);
            $ord = isset($s['display_order']) ? (int) $s['display_order'] : 100;
            $sql = "INSERT INTO {$p}coolstats_section_prefs
                (id_employee, id_shop, theme_id, section_id, enabled, display_order, updated_at)
                VALUES (" . (int) $idEmployee . ", " . (int) $idShop . ", '{$themeIdEsc}', '{$sid}', {$en}, {$ord}, NOW())
                ON DUPLICATE KEY UPDATE
                    enabled = VALUES(enabled),
                    display_order = VALUES(display_order),
                    updated_at = NOW()";
            $ok = $db->execute($sql) && $ok;
        }
        return $ok;
    }

    /**
     * Sauvegarde pour l'employé + shop + thème courant (raccourci).
     */
    public static function saveCurrent(array $sections)
    {
        $ctx = Context::getContext();
        if (!$ctx || !$ctx->employee || !$ctx->employee->id) return false;
        $idShop = ($ctx->shop && $ctx->shop->id) ? (int) $ctx->shop->id : 1;
        return self::save((int) $ctx->employee->id, $idShop, $sections, self::getActiveTheme());
    }

    /**
     * Supprime les préférences d'un employé pour un thème donné (retour aux défauts du thème).
     */
    public static function resetFor($idEmployee, $idShop, $themeId = 'default')
    {
        $db = Db::getInstance();
        $p = _DB_PREFIX_;
        return $db->execute("DELETE FROM {$p}coolstats_section_prefs
            WHERE id_employee = " . (int) $idEmployee . "
            AND id_shop = " . (int) $idShop . "
            AND theme_id = '" . pSQL((string) $themeId) . "'");
    }

    public static function resetCurrent()
    {
        $ctx = Context::getContext();
        if (!$ctx || !$ctx->employee || !$ctx->employee->id) return false;
        $idShop = ($ctx->shop && $ctx->shop->id) ? (int) $ctx->shop->id : 1;
        return self::resetFor((int) $ctx->employee->id, $idShop, self::getActiveTheme());
    }
}
