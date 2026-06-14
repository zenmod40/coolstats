{* ── Section KPI · Variante Brutalist ──
 * Label en haut, gros chiffre en dessous, badge POSITIF/NÉGATIF en top-right.
 * Pas d'icônes, ombres dures, blocs colorés cyclés.
 *}
{function name=cs_brutal_badge val=null inverted=false}
    {if $val === null}<span class="cs-trend cs-trend-neutral">~</span>
    {else}
        {assign var=is_up value=$val > 0}
        {if $inverted}{assign var=is_up value=!$is_up}{/if}
        {if $val == 0}<span class="cs-trend cs-trend-neutral">0%</span>
        {elseif $is_up}<span class="cs-trend cs-trend-up">↑ {if $val > 0}+{/if}{$val}%</span>
        {else}<span class="cs-trend cs-trend-down">↓ {$val}%</span>{/if}
    {/if}
{/function}

<div class="cs-section cs-kpi-row" data-cs-section="kpi">
    <div class="row g-3">
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="orders" data-drill="orders">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Commandes</div>
                    <div class="cs-kpi-value">{$section_data.total_orders}</div>
                </div>
                {cs_brutal_badge val=$section_data.trends.orders}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="revenue" data-drill="revenue">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Chiffre d'affaires</div>
                    <div class="cs-kpi-value">{$section_data.total_revenue|number_format:0:',':' '}&euro;</div>
                </div>
                {cs_brutal_badge val=$section_data.trends.revenue}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes valides</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="items" data-drill="items">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Articles / panier</div>
                    <div class="cs-kpi-value">{$section_data.avg_items|number_format:2:',':' '}</div>
                </div>
                {cs_brutal_badge val=$section_data.trends.items}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par nb d'articles</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="basket" data-drill="basket">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Panier moyen</div>
                    <div class="cs-kpi-value">{$section_data.avg_basket|number_format:2:',':' '}&euro;</div>
                </div>
                {cs_brutal_badge val=$section_data.trends.basket}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par montant</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card" data-stat="returns">
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Taux de retour</div>
                    <div class="cs-kpi-value">{$section_data.return_rate}%</div>
                </div>
                <span class="cs-trend cs-trend-down cs-trend-returns">{l s='RETOUR' mod='coolstats'}</span>
            </div>
        </div>
    </div>
    {if $section_data.compare}
    <div class="cs-kpi-compare-note">
        {l s='Comparaison vs' mod='coolstats'} {$section_data.compare.from} → {$section_data.compare.to}
    </div>
    {/if}
</div>
