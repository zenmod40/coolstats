<div class="cs-section cs-perf-section" data-cs-section="performance" role="button" title="Voir le détail par transporteur">
    <div class="cs-section-header">
        <span><i class="bi bi-truck"></i> {$section.title}</span>
        <i class="bi bi-box-arrow-up-right text-muted small"></i>
    </div>
    <ul class="cs-perf-list">
        <li>
            <span class="text-secondary">Délai moyen d'expédition</span>
            {if $section_data.avg_delay !== null}
                <strong class="{if $section_data.avg_delay <= 2}text-success{elseif $section_data.avg_delay <= 4}text-warning{else}text-danger{/if}">{$section_data.avg_delay}j</strong>
            {else}
                <strong class="text-muted">N/A</strong>
            {/if}
        </li>
        <li>
            <span class="text-secondary">Taux de livraison</span>
            <strong class="{if $section_data.delivery_rate >= 90}text-success{elseif $section_data.delivery_rate >= 70}text-warning{else}text-danger{/if}">{$section_data.delivery_rate}%</strong>
        </li>
    </ul>
</div>
