{function name=cs_trend val=null}
    {if $val === null}{else}
        {if $val > 0}<span class="cs-trend cs-trend-up"><i class="bi bi-arrow-up-short"></i>+{$val}%</span>
        {elseif $val < 0}<span class="cs-trend cs-trend-down"><i class="bi bi-arrow-down-short"></i>{$val}%</span>
        {else}<span class="cs-trend cs-trend-neutral">~</span>{/if}
    {/if}
{/function}
{assign var=kd value=$section_data}
<div class="cs-section cs-kerawen-section" data-cs-section="kerawen_sales"
     data-chart-labels="{$kd.labels|@json_encode|escape:'html'}"
     data-chart-store="{$kd.store_series|@json_encode|escape:'html'}"
     data-chart-web="{$kd.web_series|@json_encode|escape:'html'}">
    <div class="cs-section-header"><span title="{l s='Ventes, avoirs et corrections enregistrés sur la période. C\'est la référence pour la comptabilité et la TVA.' mod='coolstats'}"><i class="bi bi-shop"></i> {$section.title} <small class="text-muted">· {$kd.tax_label} · {l s='Écritures Kerawen, magasin + web' mod='coolstats'}</small></span><button type="button" class="btn btn-sm btn-outline-secondary cs-kerawen-check-btn cs-kerawen--{$kd.check_status}" data-cs-kerawen-check title="{l s='Voir le contrôle des données caisse' mod='coolstats'}"><span class="cs-kerawen-dot"></span> {l s='Contrôle caisse' mod='coolstats'}</button></div>
    <div class="row g-3">
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-revenue"><i class="bi bi-cash-stack"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.total|number_format:0:',':' '}&euro; {cs_trend val=$kd.trends.total}</div>
                    <div class="cs-customer-stat-label">{l s='CA fiscal total' mod='coolstats'}</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-orders"><i class="bi bi-shop"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.store|number_format:0:',':' '}&euro; {cs_trend val=$kd.trends.store}</div>
                    <div class="cs-customer-stat-label">{l s='CA magasin' mod='coolstats'}</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-items"><i class="bi bi-globe"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.web|number_format:0:',':' '}&euro; {cs_trend val=$kd.trends.web}</div>
                    <div class="cs-customer-stat-label">{l s='CA web' mod='coolstats'}</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(245,158,11,.15);color:var(--cs-warning)"><i class="bi bi-percent"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.vat|number_format:0:',':' '}&euro; {cs_trend val=$kd.trends.vat}</div>
                    <div class="cs-customer-stat-label">{l s='TVA collectée' mod='coolstats'}</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-basket"><i class="bi bi-receipt"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.nb|number_format:0:',':' '} {cs_trend val=$kd.trends.nb}</div>
                    <div class="cs-customer-stat-label">{l s='Ventes' mod='coolstats'} <span class="text-muted">· {l s='avoirs compris' mod='coolstats'}</span></div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(99,102,241,.15);color:var(--cs-accent)"><i class="bi bi-basket"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$kd.avg_store|number_format:2:',':' '}&euro; {cs_trend val=$kd.trends.avg_store}</div>
                    <div class="cs-customer-stat-label">{l s='Panier moyen magasin' mod='coolstats'}</div>
                </div>
            </div>
        </div>
    </div>
    {if $kd.tills|@count}
    <div class="table-responsive mt-3">
        <table class="table table-sm cs-table mb-0">
            <thead>
                <tr>
                    <th>{l s='Caisse' mod='coolstats'}</th>
                    <th class="text-end">{l s='Ventes' mod='coolstats'}</th>
                    <th class="text-end">{l s='% du CA' mod='coolstats'}</th>
                    <th class="text-end">{l s='CA' mod='coolstats'} {$kd.tax_label}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$kd.tills item=t}
                <tr>
                    <td>{if $t.web}<i class="bi bi-globe"></i>{else}<i class="bi bi-shop"></i>{/if} {$t.name|escape:'html':'UTF-8'}</td>
                    <td class="text-end">{$t.nb}</td>
                    <td class="text-end">{$t.pct}%</td>
                    <td class="text-end fw-bold">{$t.amount|number_format:2:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    <div class="cs-chart-wrap mt-2">
        <canvas id="cs-chart-kerawen" height="200"></canvas>
    </div>
    {else}
    <div class="text-muted small mt-3">{l s='Aucune vente caisse sur la période.' mod='coolstats'}</div>
    {/if}
    {include file="{$section._dir}_reconcile.tpl"}
    {include file="{$section._dir}_check_modal.tpl"}
</div>
