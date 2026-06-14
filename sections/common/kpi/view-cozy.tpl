{* ── Section KPI · Variante Cozy ── *
 * Hero card revenue full-width avec narratif + sparkline 28j,
 * puis 4 KPI cards en row (Commandes, Articles/Panier, Panier Moyen, Taux retour).
 *}
{function name=cs_trend val=null}
    {if $val === null}<span class="cs-trend cs-trend-neutral">~</span>
    {elseif $val > 0}<span class="cs-trend cs-trend-up"><i class="bi bi-arrow-up-short"></i>+{$val}%</span>
    {elseif $val < 0}<span class="cs-trend cs-trend-down"><i class="bi bi-arrow-down-short"></i>{$val}%</span>
    {else}<span class="cs-trend cs-trend-neutral">~</span>{/if}
{/function}

{* Génère un path SVG sparkline à partir d'un tableau de valeurs *}
{function name=cs_sparkline_path data=[] width=320 height=80 pad=8}
    {if $data|@count > 1}
        {assign var=spark_max value=$data|@max}
        {assign var=spark_min value=$data|@min}
        {assign var=spark_step value=($width-$pad*2)/($data|@count-1)}
        {assign var=spark_range value=$spark_max-$spark_min}
        {if $spark_range == 0}{assign var=spark_range value=1}{/if}
        {assign var=spark_path value=''}
        {foreach from=$data item=v key=i}
            {assign var=spark_x value=$pad+$i*$spark_step}
            {assign var=spark_y_ratio value=($v-$spark_min)/$spark_range}
            {assign var=spark_y value=$pad+($height-$pad*2)*(1-$spark_y_ratio)}
            {if $i == 0}M{else} L{/if}{$spark_x|string_format:"%.1f"},{$spark_y|string_format:"%.1f"}
        {/foreach}
    {/if}
{/function}

<div class="cs-section cs-kpi-row" data-cs-section="kpi">
    {* ─── HERO : Chiffre d'affaires en immense ─── *}
    <div class="cs-kpi-hero cs-kpi-clickable" data-stat="revenue" data-drill="revenue">
        <div class="cs-kpi-hero-content">
            <div class="cs-kpi-hero-kicker">
                CHIFFRE D'AFFAIRES{if $section_data.compare} · {if $section_data.compare.mode == 'yoy'}N-1{else}vs période précédente{/if}{/if}
            </div>
            <div class="cs-kpi-hero-value-row">
                <div class="cs-kpi-hero-value">{$section_data.total_revenue|number_format:0:',':' '} €</div>
                {cs_trend val=$section_data.trends.revenue}
            </div>
            {if $section_data.narrative}
                <div class="cs-kpi-hero-narrative">{$section_data.narrative nofilter}</div>
            {/if}
        </div>
        <div class="cs-kpi-hero-sparkline">
            {if $section_data.sparkline|@count > 1}
                <svg viewBox="0 0 320 80" preserveAspectRatio="none" aria-hidden="true">
                    <defs>
                        <linearGradient id="cs-cozy-spark-fill" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="0%" stop-color="var(--cs-accent)" stop-opacity="0.22"/>
                            <stop offset="100%" stop-color="var(--cs-accent)" stop-opacity="0"/>
                        </linearGradient>
                    </defs>
                    {assign var=spark_path_str value=''}
                    {capture name=spark_d}{cs_sparkline_path data=$section_data.sparkline width=320 height=80 pad=8}{/capture}
                    <path d="{$smarty.capture.spark_d|trim} L 312 72 L 8 72 Z" fill="url(#cs-cozy-spark-fill)"/>
                    <path d="{$smarty.capture.spark_d|trim}" fill="none" stroke="var(--cs-accent)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            {/if}
        </div>
        <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes valides</span></div>
    </div>

    {* ─── 4 KPI cards (Cozy : icon left bubble, label haut, value+trend inline) ─── *}
    <div class="row g-3 mt-3 cs-cozy-kpi-row">
        <div class="col-xl col-md-6 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="orders" data-drill="orders">
                <div class="cs-kpi-icon cs-kpi-icon-orders"><i class="bi bi-bag"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Commandes</div>
                    <div class="cs-kpi-value-row">
                        <div class="cs-kpi-value">{$section_data.total_orders}</div>
                        {cs_trend val=$section_data.trends.orders}
                    </div>
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes</span></div>
            </div>
        </div>
        <div class="col-xl col-md-6 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="items" data-drill="items">
                <div class="cs-kpi-icon cs-kpi-icon-items"><i class="bi bi-cart"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Articles / panier</div>
                    <div class="cs-kpi-value-row">
                        <div class="cs-kpi-value">{$section_data.avg_items|number_format:2:',':' '}</div>
                        {cs_trend val=$section_data.trends.items}
                    </div>
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par nb d'articles</span></div>
            </div>
        </div>
        <div class="col-xl col-md-6 col-sm-6">
            <div class="cs-kpi-card cs-kpi-clickable" data-stat="basket" data-drill="basket">
                <div class="cs-kpi-icon cs-kpi-icon-basket"><i class="bi bi-basket3"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Panier moyen</div>
                    <div class="cs-kpi-value-row">
                        <div class="cs-kpi-value">{$section_data.avg_basket|number_format:2:',':' '}&euro;</div>
                        {cs_trend val=$section_data.trends.basket}
                    </div>
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par montant</span></div>
            </div>
        </div>
        <div class="col-xl col-md-6 col-sm-6">
            <div class="cs-kpi-card" data-stat="returns">
                <div class="cs-kpi-icon cs-kpi-icon-returns"><i class="bi bi-arrow-counterclockwise"></i></div>
                <div class="cs-kpi-body">
                    <div class="cs-kpi-label">Taux de retour</div>
                    <div class="cs-kpi-value-row">
                        <div class="cs-kpi-value">{$section_data.return_rate}%</div>
                        <span class="cs-trend cs-trend-neutral cs-trend-static">retour</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
