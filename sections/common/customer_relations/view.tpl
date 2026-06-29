{function name=cs_trend val=null}
    {if $val === null}{else}
        {if $val > 0}<span class="cs-trend cs-trend-up"><i class="bi bi-arrow-up-short"></i>+{$val}%</span>
        {elseif $val < 0}<span class="cs-trend cs-trend-down"><i class="bi bi-arrow-down-short"></i>{$val}%</span>
        {else}<span class="cs-trend cs-trend-neutral">~</span>{/if}
    {/if}
{/function}
<div class="cs-section cs-customer-relations-section" data-cs-section="customer_relations">
    <div class="cs-section-header"><i class="bi bi-headset"></i> {$section.title}</div>
    <div class="row g-3">
        <div class="col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-orders"><i class="bi bi-bag"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.orders|number_format:0:',':' '} {cs_trend val=$section_data.trends.orders}</div>
                    <div class="cs-customer-stat-label">Commandes sur la période</div>
                </div>
            </div>
        </div>
        {if $section_data.has_retract}
        <div class="col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(245,158,11,.15);color:var(--cs-warning)"><i class="bi bi-arrow-return-left"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.retract|number_format:0:',':' '} <small class="text-muted">({$section_data.retract_rate}%)</small> {cs_trend val=$section_data.trends.retract}</div>
                    <div class="cs-customer-stat-label">Rétractations</div>
                </div>
            </div>
        </div>
        {/if}
        <div class="col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(99,102,241,.15);color:var(--cs-accent)"><i class="bi bi-chat-left-dots"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.sav|number_format:0:',':' '} <small class="text-muted">({$section_data.sav_rate}%)</small> {cs_trend val=$section_data.trends.sav}</div>
                    <div class="cs-customer-stat-label">Demandes SAV <span class="text-muted">· service client</span></div>
                </div>
            </div>
        </div>
    </div>
</div>
