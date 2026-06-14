{* ── Infos transporteurs / Expéditions · Variante Terminal ── *}
<div class="cs-section cs-perf-section cs-perf-term" data-cs-section="performance" role="button" title="{l s='Voir le détail par transporteur' mod='coolstats'}">
    <div class="cs-section-header">
        <span>📦 {l s='Infos transporteurs / Expéditions' mod='coolstats'}</span>
        <a href="#" class="cs-perf-term-detail">▸ {l s='détail' mod='coolstats'}</a>
    </div>
    <div class="cs-perf-term-body">
        <div class="cs-perf-term-row">
            <span class="cs-perf-term-label">{l s='Délai moyen d\'expédition' mod='coolstats'}</span>
            <span class="cs-perf-term-val{if $section_data.avg_delay === null} cs-perf-term-val--dim{elseif $section_data.avg_delay <= 2} cs-perf-term-val--good{elseif $section_data.avg_delay > 4} cs-perf-term-val--bad{/if}">
                {if $section_data.avg_delay !== null}{$section_data.avg_delay}j{else}N/A{/if}
            </span>
        </div>
        <div class="cs-perf-term-row cs-perf-term-row--last">
            <span class="cs-perf-term-label">{l s='Taux de livraison' mod='coolstats'}</span>
            <span class="cs-perf-term-val{if $section_data.delivery_rate >= 90} cs-perf-term-val--good{elseif $section_data.delivery_rate < 70} cs-perf-term-val--bad{/if}">
                {$section_data.delivery_rate}%
            </span>
        </div>
    </div>
</div>
