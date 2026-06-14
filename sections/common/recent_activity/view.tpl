<div class="cs-section cs-activity-section" data-cs-section="recent_activity">
    <div class="cs-section-header"><i class="bi bi-bell"></i> {$section.title}</div>
    {if $section_data.items|@count}
    <div class="cs-activity-list">
        {foreach from=$section_data.items item=act name=actloop}
        <div class="cs-activity-item{if $smarty.foreach.actloop.index >= 5} cs-activity-hidden{/if}">
            <div class="cs-activity-dot" style="background:{$act.state_color}"></div>
            <a href="{$act.bo_link}" target="_blank" class="cs-activity-ref">{$act.reference|escape:'html':'UTF-8'}</a>
            <small class="text-muted cs-activity-id">#{$act.id_order}</small>
            <span class="cs-activity-customer">{$act.customer|escape:'html':'UTF-8'}</span>
            <span class="cs-activity-state" style="background:{$act.state_color}20;color:{$act.state_color};border:1px solid {$act.state_color}40">{$act.state_name}</span>
            <small class="text-muted cs-activity-time">{$act.time}</small>
        </div>
        {/foreach}
    </div>
    {if $section_data.items|@count > 5}
    <div class="text-center pt-2">
        <button type="button" class="cs-link small cs-activity-toggle" style="background:none;border:none">
            <i class="bi bi-chevron-down me-1"></i><span>Voir plus</span>
        </button>
    </div>
    {/if}
    {else}
    <div class="text-center text-muted small p-3"><i class="bi bi-inbox d-block mb-2"></i>Aucune activité sur cette période</div>
    {/if}
</div>
