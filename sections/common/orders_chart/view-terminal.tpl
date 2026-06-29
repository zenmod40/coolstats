{* ── Courbe des commandes · Variante Terminal ──
 * Header attaché au panel (pas de marge interne), canvas Chart.js.
 *}
<div class="cs-section cs-orders-chart-section cs-orders-chart-term" data-cs-section="orders_chart"
     data-chart-labels="{$section_data.labels|@json_encode|escape:'html'}"
     data-chart-orders="{$section_data.orders_data|@json_encode|escape:'html'}"
     data-chart-revenue="{$section_data.revenue_data|@json_encode|escape:'html'}"
     data-chart-orders-compare="{if $section_data.orders_compare}{$section_data.orders_compare|@json_encode|escape:'html'}{else}[]{/if}"
     data-chart-revenue-compare="{if $section_data.revenue_compare}{$section_data.revenue_compare|@json_encode|escape:'html'}{else}[]{/if}">
    <div class="cs-section-header">
        <span>↗ {l s='Courbe des commandes' mod='coolstats'}</span>
        <div class="cs-orders-term-sort">
            <span class="cs-orders-term-sort-label cs-line-mode-label cs-active" data-mode="orders">{l s='Commandes' mod='coolstats'}</span>
            <span class="cs-orders-term-sort-label cs-line-mode-label" data-mode="revenue">{l s='CA' mod='coolstats'} &euro;</span>
            <div class="form-check form-switch mb-0">
                <input class="form-check-input cs-line-toggle" type="checkbox" id="cs-line-mode-toggle">
            </div>
        </div>
    </div>
    {if $section_data.orders_compare}
    <div class="cs-chart-legend">
        <span class="cs-chart-legend-item"><span class="cs-chart-legend-line"></span> {l s='Période actuelle' mod='coolstats'}</span>
        <span class="cs-chart-legend-item"><span class="cs-chart-legend-line cs-chart-legend-line--dashed"></span> {if $section_data.compare_mode == 'yoy'}{l s='Année précédente (N-1)' mod='coolstats'}{else}{l s='Période précédente' mod='coolstats'}{/if}</span>
    </div>
    {/if}
    <div class="cs-orders-term-chart">
        <canvas id="cs-chart-line" height="180"></canvas>
    </div>
</div>
