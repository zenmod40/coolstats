{* ── Activité récente · Variante Terminal ── *}
<div class="cs-section cs-activity-section cs-activity-term" data-cs-section="recent_activity">
    <div class="cs-section-header">
        <span>⏱ {l s='Activité récente' mod='coolstats'}</span>
    </div>
    {if $section_data.items|@count}
    <div class="cs-activity-term-body">
        {foreach from=$section_data.items item=act name=actloop}
        <a href="{$act.bo_link}" target="_blank" class="cs-activity-term-row cs-activity-term-row--{$act.kind}{if $smarty.foreach.actloop.index >= 5} cs-activity-hidden{/if}">
            <span class="cs-activity-term-dot">●</span>
            <span class="cs-activity-term-ref">{$act.reference|escape:'html':'UTF-8'}</span>
            <span class="cs-activity-term-id">#{$act.id_order}</span>
            <span class="cs-activity-term-customer">{$act.customer|escape:'html':'UTF-8'}</span>
            <span class="cs-activity-term-state">{$act.state_name}</span>
            <span class="cs-activity-term-time">{$act.time}</span>
        </a>
        {/foreach}
        {if $section_data.items|@count > 5}
        <div class="cs-activity-term-more-wrap">
            <button type="button" class="cs-activity-term-more cs-activity-toggle">▾ <span>{l s='voir plus' mod='coolstats'}</span></button>
        </div>
        {/if}
    </div>
    {else}
    <div class="cs-term-empty">{l s='Aucune activité sur cette période' mod='coolstats'}</div>
    {/if}
</div>
