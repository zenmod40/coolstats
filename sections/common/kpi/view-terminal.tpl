{* ── Section KPI · Variante Terminal ──
 * Label uppercase dim, value 22px phosphor green, trend ▲/▼ inline mono.
 * Pas d'icônes, pas de pill, pas de rotation, monospace partout.
 *}
{function name=cs_term_trend val=null inverted=false}
    {if $val === null}<div class="cs-trend cs-trend-neutral">~</div>
    {else}
        {assign var=is_up value=$val > 0}
        {if $inverted}{assign var=is_up value=!$is_up}{/if}
        {if $val == 0}<div class="cs-trend cs-trend-neutral">0%</div>
        {elseif $is_up}<div class="cs-trend cs-trend-up">{if $val > 0}+{/if}{$val}%</div>
        {else}<div class="cs-trend cs-trend-down">{$val}%</div>{/if}
    {/if}
{/function}

<div class="cs-section cs-kpi-row" data-cs-section="kpi">
    <div class="row g-3">
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="orders" data-drill="orders">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">{l s='Commandes' mod='coolstats'}</div>
                    <div class="cs-kpi-value">{$section_data.total_orders}</div>
                </div>
                {cs_term_trend val=$section_data.trends.orders}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Voir les commandes' mod='coolstats'}</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="revenue" data-drill="revenue">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">{l s='Chiffre d\'affaires' mod='coolstats'}</div>
                    <div class="cs-kpi-value">{$section_data.total_revenue|number_format:0:',':' '}&euro;</div>
                </div>
                {cs_term_trend val=$section_data.trends.revenue}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Voir les commandes valides' mod='coolstats'}</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="items" data-drill="items">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">{l s='Articles / panier' mod='coolstats'}</div>
                    <div class="cs-kpi-value">{$section_data.avg_items|number_format:2:',':' '}</div>
                </div>
                {cs_term_trend val=$section_data.trends.items}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Trier par nb d\'articles' mod='coolstats'}</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="basket" data-drill="basket">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">{l s='Panier moyen' mod='coolstats'}</div>
                    <div class="cs-kpi-value">{$section_data.avg_basket|number_format:2:',':' '}&euro;</div>
                </div>
                {cs_term_trend val=$section_data.trends.basket}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Trier par montant' mod='coolstats'}</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card" data-stat="returns">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">{l s='Taux de retour' mod='coolstats'}</div>
                    <div class="cs-kpi-value">{$section_data.return_rate}%</div>
                </div>
                <div class="cs-trend cs-trend-down cs-trend-returns">{l s='ret' mod='coolstats'}</div>
            </div>
        </div>
    </div>
    {if $section_data.compare}
    <div class="cs-kpi-compare-note">
        {l s='Comparaison' mod='coolstats'} : {$section_data.compare.from} → {$section_data.compare.to}
    </div>
    {/if}
</div>
