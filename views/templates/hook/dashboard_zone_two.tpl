{*
 * CoolStats Dashboard
 * Panneau natif du tableau de bord PrestaShop (zone centrale) : 5 indicateurs clés.
 * L'id de la section doit être le nom du module : le JS natif s'en sert pour
 * appeler hookDashboardData au changement de période.
 *
 * @author    ZM40 — Nicolas Michaud (Magic Garden)
 * @copyright 2026 Nicolas Michaud — ZM40 / Magic Garden
 * @license   https://opensource.org/licenses/OSL-3.0 Open Software License version 3.0
 *}
{function name=cs_dash_tile id='' label='' trend=null}
    <dl class="col-xs-6 col-sm-4 col-lg-2">
        <dt>{$label}</dt>
        <dd class="data_value size_l"><span id="{$id}">{$cs_dash_values[$id]}</span></dd>
        {if $trend !== null}
            <dd class="dash_trend dash_trend_{$trend.way}"><span id="{$id}_trend">{$trend.value}</span></dd>
        {/if}
    </dl>
{/function}

<section id="coolstats" class="panel widget">
    <header class="panel-heading">
        <i class="icon-bar-chart"></i> CoolStats
        <span class="panel-heading-action">
            <a class="list-toolbar-btn" href="#" onclick="refreshDashboard('coolstats'); return false;" title="Actualiser">
                <i class="process-icon-refresh"></i>
            </a>
        </span>
    </header>
    <div class="row">
        {cs_dash_tile id='cs_dash_orders'  label='Commandes'          trend=$cs_dash_trends.cs_dash_orders_trend}
        {cs_dash_tile id='cs_dash_revenue' label="Chiffre d'affaires" trend=$cs_dash_trends.cs_dash_revenue_trend}
        {cs_dash_tile id='cs_dash_items'   label='Articles / panier'  trend=$cs_dash_trends.cs_dash_items_trend}
        {cs_dash_tile id='cs_dash_basket'  label='Panier moyen'       trend=$cs_dash_trends.cs_dash_basket_trend}
        {cs_dash_tile id='cs_dash_returns' label='Taux de retour'}
        <div class="col-xs-6 col-sm-4 col-lg-2 text-center" style="padding-top:12px">
            <a class="btn btn-primary" href="{$cs_dash_link|escape:'html':'UTF-8'}">
                <i class="icon-external-link"></i> Dashboard complet
            </a>
        </div>
    </div>
</section>
