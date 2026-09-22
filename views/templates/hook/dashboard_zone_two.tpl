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

{if $cs_dash_embed}
{* Dashboard complet sous le panneau. La vue lite_display se suffit à elle-même
   (ni menu ni header), et l'iframe garde son CSS et son JS à l'écart de ceux du
   back-office. Hauteur ajustée au contenu : même origine, donc lecture directe. *}
<section class="panel widget" style="padding:0;overflow:hidden">
    <iframe id="cs-dash-frame" src="{$cs_dash_embed_link|escape:'html':'UTF-8'}"
            style="display:block;width:100%;height:900px;border:0" scrolling="no"></iframe>
</section>
<script type="text/javascript">
(function () {
    var frame = document.getElementById('cs-dash-frame');
    if (!frame) { return; }
    frame.addEventListener('load', function () {
        var doc;
        try { doc = frame.contentDocument; } catch (e) { return; }
        if (!doc || !doc.body) { return; }
        // Le dashboard occupe toute la hauteur de la fenêtre quand il est seul sur
        // sa page ; embarqué, cette contrainte ferait grandir l'iframe sans fin.
        doc.body.style.minHeight = '0';
        var app = doc.getElementById('cs-app');
        if (app) { app.style.minHeight = '0'; }
        var fit = function () { frame.style.height = doc.body.scrollHeight + 'px'; };
        fit();
        if (window.ResizeObserver) { new ResizeObserver(fit).observe(doc.body); }
    });
})();
</script>
{/if}
