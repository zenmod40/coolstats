{* ── Activité récente · Variante Brutalist ── carte blanche, pill ink + filet *}
<div class="cs-section cs-activity-section cs-activity-brutal" data-cs-section="recent_activity">
    <div class="cs-brutal-titlebar">
        <span class="cs-brutal-tag cs-brutal-tag-dark">⏱ {l s='Activité récente' mod='coolstats'}</span>
        <div class="cs-brutal-rule"></div>
    </div>

    {if $section_data.items|@count}
    <div class="cs-activity-brutal-list">
        {foreach from=$section_data.items item=act name=actloop}
        <a href="{$act.bo_link}" target="_blank" class="cs-activity-brutal-item{if $smarty.foreach.actloop.index >= 5} cs-activity-hidden{/if}">
            <span class="cs-activity-brutal-ref">{$act.reference|escape:'html':'UTF-8'}</span>
            <span class="cs-activity-brutal-id">#{$act.id_order}</span>
            <span class="cs-activity-brutal-customer">{$act.customer|escape:'html':'UTF-8'}</span>
            <span class="cs-activity-brutal-state cs-activity-brutal-state-{$act.kind}">{$act.state_name}</span>
            <span class="cs-activity-brutal-time">{$act.time}</span>
        </a>
        {/foreach}
    </div>
    {if $section_data.items|@count > 5}
    <button type="button" class="cs-activity-brutal-more cs-activity-toggle">▾ <span>{l s='Voir plus' mod='coolstats'}</span></button>
    {/if}
    {else}
    <div class="cs-brutal-empty">{l s='Aucune activité sur cette période' mod='coolstats'}</div>
    {/if}
</div>
