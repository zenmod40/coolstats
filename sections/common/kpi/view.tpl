{* ── Section KPI : 5 cartes avec valeur, label, tendance ── *}
{function name=cs_trend val=null}
    {if $val === null}<span class="cs-trend cs-trend-neutral">~</span>
    {elseif $val > 0}<span class="cs-trend cs-trend-up"><i class="bi bi-arrow-up-short"></i>+{$val}%</span>
    {elseif $val < 0}<span class="cs-trend cs-trend-down"><i class="bi bi-arrow-down-short"></i>{$val}%</span>
    {else}<span class="cs-trend cs-trend-neutral">~</span>{/if}
{/function}

<div class="cs-section cs-kpi-row" data-cs-section="kpi">
    <div class="row g-3">
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="orders" data-drill="orders">
                <div class="cs-kpi-icon cs-kpi-icon-orders"><i class="bi bi-bag-check"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-value">{$section_data.total_orders}</div>
                    <div class="cs-kpi-label">Commandes</div>
                </div>
                {cs_trend val=$section_data.trends.orders}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="revenue" data-drill="revenue">
                <div class="cs-kpi-icon cs-kpi-icon-revenue"><i class="bi bi-currency-euro"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-value">{$section_data.total_revenue|number_format:0:',':' '}&euro;</div>
                    <div class="cs-kpi-label">Chiffre d'affaires</div>
                </div>
                {cs_trend val=$section_data.trends.revenue}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes valides</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="items" data-drill="items">
                <div class="cs-kpi-icon cs-kpi-icon-items"><i class="bi bi-basket"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-value">{$section_data.avg_items|number_format:2:',':' '}</div>
                    <div class="cs-kpi-label">Articles / panier</div>
                </div>
                {cs_trend val=$section_data.trends.items}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par nb d'articles</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="basket" data-drill="basket">
                <div class="cs-kpi-icon cs-kpi-icon-basket"><i class="bi bi-basket2"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-value">{$section_data.avg_basket|number_format:2:',':' '}&euro;</div>
                    <div class="cs-kpi-label">Panier moyen</div>
                </div>
                {cs_trend val=$section_data.trends.basket}
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par montant</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-kpi-card" data-stat="returns">
                <div class="cs-kpi-icon cs-kpi-icon-returns"><i class="bi bi-arrow-return-left"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-value">{$section_data.return_rate}%</div>
                    <div class="cs-kpi-label">Taux de retour</div>
                </div>
                <i class="bi bi-box-arrow-up-right text-muted small cs-kpi-link-icon"></i>
            </div>
        </div>
    </div>
    {if $section_data.compare}
    <div class="cs-kpi-compare-note text-secondary small mt-2">
        Comparaison vs {$section_data.compare.from} → {$section_data.compare.to}
        {if $section_data.compare.mode == 'yoy'} (n-1 an){else} (période précédente){/if}
    </div>
    {/if}
</div>
