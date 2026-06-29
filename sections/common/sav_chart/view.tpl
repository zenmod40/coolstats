<div class="cs-section cs-sav-chart-section" data-cs-section="sav_chart"
     data-chart-labels="{$section_data.labels|@json_encode|escape:'html'}"
     data-chart-sav="{$section_data.sav_data|@json_encode|escape:'html'}"
     data-chart-sav-compare="{if $section_data.sav_compare}{$section_data.sav_compare|@json_encode|escape:'html'}{else}[]{/if}">
    <div class="cs-section-header">
        <span><i class="bi bi-headset"></i> {$section.title}</span>
    </div>
    {if $section_data.sav_compare}
    <div class="cs-chart-legend">
        <span class="cs-chart-legend-item"><span class="cs-chart-legend-line"></span> {l s='Période actuelle' mod='coolstats'}</span>
        <span class="cs-chart-legend-item"><span class="cs-chart-legend-line cs-chart-legend-line--dashed"></span> {if $section_data.compare_mode == 'yoy'}{l s='Année précédente (N-1)' mod='coolstats'}{else}{l s='Période précédente' mod='coolstats'}{/if}</span>
    </div>
    {/if}
    <div class="cs-chart-wrap">
        <canvas id="cs-chart-sav" height="200"></canvas>
    </div>
</div>
