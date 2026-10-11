{* ── CA fiscal caisse (Kerawen) · Variante Brutalist ── (grille et table des sections Clients et Commandes) *}
{function name=cs_trend val=null}{if $val !== null} <span class="cs-customers-brutal-pct">{if $val > 0}+{/if}{$val}%</span>{/if}{/function}
{assign var=kd value=$section_data}
<div class="cs-section cs-customers-brutal" data-cs-section="kerawen_sales"
     data-chart-labels="{$kd.labels|@json_encode|escape:'html'}"
     data-chart-store="{$kd.store_series|@json_encode|escape:'html'}"
     data-chart-web="{$kd.web_series|@json_encode|escape:'html'}">
    <div class="cs-customers-brutal-header">
        <span class="cs-customers-brutal-badge" title="{l s='Ventes, avoirs et corrections enregistrés sur la période. C\'est la référence pour la comptabilité et la TVA.' mod='coolstats'}">§ {l s='CA fiscal caisse' mod='coolstats'} · {$kd.tax_label}</span>
        <div class="cs-customers-brutal-rule"></div>
        <button type="button" class="btn btn-sm btn-outline-secondary cs-kerawen-check-btn cs-kerawen--{$kd.check_status}" data-cs-kerawen-check title="{l s='Voir le contrôle des données caisse' mod='coolstats'}"><span class="cs-kerawen-dot"></span> {l s='Contrôle caisse' mod='coolstats'}</button>
    </div>
    <div class="cs-customers-brutal-grid">
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.total|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.total}</div>
            <div class="cs-customers-brutal-label">{l s='CA fiscal total' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.store|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.store}</div>
            <div class="cs-customers-brutal-label">{l s='CA magasin' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.web|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.web}</div>
            <div class="cs-customers-brutal-label">{l s='CA web' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.vat|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.vat}</div>
            <div class="cs-customers-brutal-label">{l s='TVA collectée' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.nb|number_format:0:',':' '}{cs_trend val=$kd.trends.nb}</div>
            <div class="cs-customers-brutal-label">{l s='Ventes, avoirs compris' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$kd.avg_store|number_format:2:',':' '}&euro;{cs_trend val=$kd.trends.avg_store}</div>
            <div class="cs-customers-brutal-label">{l s='Panier moyen magasin' mod='coolstats'}</div>
        </div>
    </div>
    {if $kd.tills|@count}
    <table class="cs-orders-brutal-table mt-3">
        <thead><tr><th>{l s='Caisse' mod='coolstats'}</th><th>{l s='Ventes' mod='coolstats'}</th><th>{l s='% du CA' mod='coolstats'}</th><th>{l s='CA' mod='coolstats'} {$kd.tax_label}</th></tr></thead>
        <tbody>
            {foreach from=$kd.tills item=t}
            <tr><td>{$t.name|escape:'html':'UTF-8'}</td><td>{$t.nb}</td><td>{$t.pct}%</td><td>{$t.amount|number_format:2:',':' '}&euro;</td></tr>
            {/foreach}
        </tbody>
    </table>
    <div class="cs-chart-wrap mt-2"><canvas id="cs-chart-kerawen" height="200"></canvas></div>
    {/if}
    {include file="{$section._dir}_reconcile.tpl"}
    {include file="{$section._dir}_check_modal.tpl"}
</div>
