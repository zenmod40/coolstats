{* ── Section KPI · Variante Editorial ──
 * Mise en page éditoriale "rapport trimestriel" :
 * - Colonne gauche : CHIFFRE D'AFFAIRES + valeur géante sérif + narratif italique
 * - Colonne droite : 4 mini-KPI alignés verticalement avec divider, trends en italique
 *}
{function name=cs_ed_trend val=null}
    {if $val === null}<span class="cs-ed-trend cs-ed-trend-neutral">~</span>
    {elseif $val > 0}<span class="cs-ed-trend cs-ed-trend-up">&uarr;+{$val}%</span>
    {elseif $val < 0}<span class="cs-ed-trend cs-ed-trend-down">&darr;{$val}%</span>
    {else}<span class="cs-ed-trend cs-ed-trend-neutral">~</span>{/if}
{/function}

<div class="cs-section cs-kpi-row cs-ed-kpi-row" data-cs-section="kpi">
    <div class="cs-ed-kpi-grid">
        {* ─── Gauche : Hero CA ─── *}
        <div class="cs-ed-hero cs-kpi-clickable" data-stat="revenue" data-drill="revenue">
            <div class="cs-ed-kicker">
                CHIFFRE D'AFFAIRES{if $section_data.compare} · {if $section_data.compare.mode == 'yoy'}N-1{else}T-1{/if}{/if}
            </div>
            <div class="cs-ed-hero-value">
                {$section_data.total_revenue|number_format:0:',':' '}<span class="cs-ed-hero-currency">€</span>
            </div>
            {if $section_data.narrative_editorial}
                <div class="cs-ed-narrative">{$section_data.narrative_editorial nofilter}</div>
            {/if}
            <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les ventes</span></div>
        </div>

        {* ─── Droite : 4 mini-KPI alignés verticalement avec divider ─── *}
        <div class="cs-ed-kpi-side">
            <div class="cs-ed-kpi-row-item cs-kpi-clickable" data-stat="orders" data-drill="orders">
                <div class="cs-ed-kpi-label">Commandes</div>
                <div class="cs-ed-kpi-line">
                    <div class="cs-ed-kpi-val">{$section_data.total_orders|number_format:0:',':' '}</div>
                    {cs_ed_trend val=$section_data.trends.orders}
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes</span></div>
            </div>
            <div class="cs-ed-kpi-row-item cs-kpi-clickable" data-stat="items" data-drill="items">
                <div class="cs-ed-kpi-label">Articles / panier</div>
                <div class="cs-ed-kpi-line">
                    <div class="cs-ed-kpi-val">{$section_data.avg_items|number_format:2:',':' '}</div>
                    {cs_ed_trend val=$section_data.trends.items}
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par articles</span></div>
            </div>
            <div class="cs-ed-kpi-row-item cs-kpi-clickable" data-stat="basket" data-drill="basket">
                <div class="cs-ed-kpi-label">Panier moyen</div>
                <div class="cs-ed-kpi-line">
                    <div class="cs-ed-kpi-val">{$section_data.avg_basket|number_format:2:',':' '}&euro;</div>
                    {cs_ed_trend val=$section_data.trends.basket}
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Trier par montant</span></div>
            </div>
            <div class="cs-ed-kpi-row-item" data-stat="returns">
                <div class="cs-ed-kpi-label">Taux de retour</div>
                <div class="cs-ed-kpi-line">
                    <div class="cs-ed-kpi-val">{$section_data.return_rate}%</div>
                    <span class="cs-ed-trend cs-ed-trend-neutral">retour</span>
                </div>
            </div>
        </div>
    </div>
</div>
