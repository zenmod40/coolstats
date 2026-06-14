<div class="cs-section cs-country-section" data-cs-section="country_map" data-country-data="{$section_data.by_iso_attr nofilter}">
    <script type="application/json" class="cs-country-data-json">{$section_data.by_iso_json nofilter}</script>
    <div class="row g-3">
        {* ── Carte Europe ── *}
        <div class="col-xl-8">
            <div class="cs-section-header">
                <span><i class="bi bi-geo-alt"></i> {$section.title}</span>
                <span class="badge cs-badge-accent"><span id="cs-country-count">{$section_data.ranked|@count}</span> pays</span>
            </div>
            {if $section_data.svg}
                <div id="cs-europe-map" class="cs-map-container position-relative">
                    {$section_data.svg nofilter}
                    <div id="cs-map-tooltip" class="cs-map-tooltip" style="display:none"></div>
                </div>
            {else}
                <div class="text-muted small">Carte indisponible.</div>
            {/if}
        </div>

        {* ── Classement par pays ── *}
        <div class="col-xl-4">
            <div class="cs-section-header"><i class="bi bi-bar-chart-steps"></i> Classement par pays</div>
            <div class="cs-country-rank-list" id="cs-country-rank-list">
                {if $section_data.ranked|@count}
                    {foreach from=$section_data.ranked item=c name=cl}
                    <div class="cs-country-rank-item d-flex align-items-center gap-3 py-2 px-2 border-bottom{if $section_data.selected_iso == $c.iso} cs-country-selected{/if}" data-iso="{$c.iso}">
                        <span class="cs-rank-number">{$smarty.foreach.cl.iteration}</span>
                        <div class="flex-grow-1 min-width-0">
                            <div class="d-flex align-items-center gap-2">
                                <strong class="small">{$c.name|escape:'html':'UTF-8'}</strong>
                                <small class="text-muted">({$c.iso})</small>
                            </div>
                            <div class="progress mt-1" style="height:3px;background:var(--cs-bg-card-hover)">
                                <div class="progress-bar" style="background:var(--cs-accent); width:{$c.pct_revenue}%"></div>
                            </div>
                        </div>
                        <div class="text-end flex-shrink-0">
                            <div class="fw-bold small">{$c.revenue|number_format:0:',':' '}&euro;</div>
                            <small class="text-muted">{$c.orders} cmd · {$c.pct_orders}%</small>
                        </div>
                    </div>
                    {/foreach}
                {else}
                    <div class="p-3 text-center text-muted small"><i class="bi bi-geo-alt fs-3 d-block mb-2"></i>Aucune donnée</div>
                {/if}
            </div>
        </div>
    </div>
</div>
