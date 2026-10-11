{* ── CA fiscal caisse (Kerawen) · Variante Terminal ── (grille et table des sections Clients et Paiements) *}
{function name=cs_trend val=null}{if $val !== null} <span class="cs-customers-term-pct">{if $val > 0}+{/if}{$val}%</span>{/if}{/function}
{assign var=kd value=$section_data}
<div class="cs-section cs-customers-term" data-cs-section="kerawen_sales"
     data-chart-labels="{$kd.labels|@json_encode|escape:'html'}"
     data-chart-store="{$kd.store_series|@json_encode|escape:'html'}"
     data-chart-web="{$kd.web_series|@json_encode|escape:'html'}">
    <div class="cs-section-header">
        <span title="{l s='Ventes, avoirs et corrections enregistrés sur la période. C\'est la référence pour la comptabilité et la TVA.' mod='coolstats'}">§ {l s='CA fiscal caisse' mod='coolstats'} <span class="cs-customers-term-meta">{l s='Écritures Kerawen, magasin + web' mod='coolstats'}</span></span>
        <span class="cs-customers-term-meta">{$kd.tax_label} <button type="button" class="btn btn-sm btn-outline-secondary cs-kerawen-check-btn cs-kerawen--{$kd.check_status}" data-cs-kerawen-check title="{l s='Voir le contrôle des données caisse' mod='coolstats'}"><span class="cs-kerawen-dot"></span> {l s='Contrôle caisse' mod='coolstats'}</button></span>
    </div>
    <div class="cs-customers-term-grid">
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$kd.total|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.total}</div>
            <div class="cs-customers-term-l">{l s='CA fiscal' mod='coolstats'}<br>{l s='total' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$kd.store|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.store}</div>
            <div class="cs-customers-term-l">{l s='CA' mod='coolstats'}<br>{l s='magasin' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$kd.web|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.web}</div>
            <div class="cs-customers-term-l">{l s='CA' mod='coolstats'}<br>{l s='web' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat cs-customers-term-stat--amber">
            <div class="cs-customers-term-v">{$kd.vat|number_format:0:',':' '}&euro;{cs_trend val=$kd.trends.vat}</div>
            <div class="cs-customers-term-l">{l s='TVA' mod='coolstats'}<br>{l s='collectée' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$kd.nb|number_format:0:',':' '}{cs_trend val=$kd.trends.nb}</div>
            <div class="cs-customers-term-l">{l s='Ventes' mod='coolstats'}<br>{l s='avoirs compris' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat cs-customers-term-stat--neutral">
            <div class="cs-customers-term-v">{$kd.avg_store|number_format:2:',':' '}&euro;{cs_trend val=$kd.trends.avg_store}</div>
            <div class="cs-customers-term-l">{l s='Panier moyen' mod='coolstats'}<br>{l s='magasin' mod='coolstats'}</div>
        </div>
    </div>
    <div class="cs-native-payment-term-body">
        {if $kd.tills|@count}
        <table class="cs-native-payment-term-table">
            <thead><tr><th>{l s='Caisse' mod='coolstats'}</th><th class="text-end">{l s='Ventes' mod='coolstats'}</th><th class="text-end">{l s='% du CA' mod='coolstats'}</th><th class="text-end">{l s='CA' mod='coolstats'} {$kd.tax_label}</th></tr></thead>
            <tbody>
                {foreach from=$kd.tills item=t}
                <tr>
                    <td class="cs-native-payment-term-method">{$t.name|escape:'html':'UTF-8'}</td>
                    <td class="text-end cs-native-payment-term-orders">{$t.nb}</td>
                    <td class="text-end cs-native-payment-term-pct">{$t.pct}%</td>
                    <td class="text-end cs-native-payment-term-ca">{$t.amount|number_format:2:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        <div class="cs-chart-wrap mt-2"><canvas id="cs-chart-kerawen" height="200"></canvas></div>
        {else}
        <div class="cs-term-empty">{l s='Aucune vente caisse sur la période' mod='coolstats'}</div>
        {/if}
        {include file="{$section._dir}_reconcile.tpl"}
    </div>
    {include file="{$section._dir}_check_modal.tpl"}
</div>
