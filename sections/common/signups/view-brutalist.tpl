{* ── Tunnel de conversion · Variante Brutalist ── carte blanche, pill cobalt + filet *}
<div class="cs-section cs-signups-brutal" data-cs-section="signups">
    <div class="cs-brutal-titlebar">
        <span class="cs-brutal-tag cs-brutal-tag-cobalt">▸ {l s='Tunnel de conversion' mod='coolstats'}</span>
        <div class="cs-brutal-rule"></div>
    </div>

    {if $section_data.total_created == 0}
        <div class="cs-brutal-empty">{l s='Aucun compte créé sur la période' mod='coolstats'}</div>
    {else}
    <div class="cs-funnel-brutal">
        <div class="cs-funnel-brutal-step">
            <div class="cs-funnel-brutal-v">{$section_data.total_created|number_format:0:',':' '}</div>
            <div class="cs-funnel-brutal-l">{l s='Comptes créés' mod='coolstats'}</div>
        </div>
        <div class="cs-funnel-brutal-step">
            <div class="cs-funnel-brutal-v">{$section_data.with_order|number_format:0:',':' '}</div>
            <div class="cs-funnel-brutal-l">{l s='Ont commandé' mod='coolstats'}</div>
            <span class="cs-funnel-brutal-pct">{$section_data.conversion_rate}%</span>
        </div>
        <div class="cs-funnel-brutal-step">
            <div class="cs-funnel-brutal-v">{$section_data.without_order|number_format:0:',':' '}</div>
            <div class="cs-funnel-brutal-l">{l s='Fantômes' mod='coolstats'}</div>
            {if $section_data.total_created > 0}
            {assign var=cs_ghost_pct value=($section_data.without_order * 100) / $section_data.total_created}
            <span class="cs-funnel-brutal-pct cs-funnel-brutal-pct-bad">{$cs_ghost_pct|string_format:'%.0f'}%</span>
            {/if}
        </div>
        <div class="cs-funnel-brutal-step">
            <div class="cs-funnel-brutal-v">
                {if $section_data.avg_delay_days === null}—
                {elseif $section_data.avg_delay_days < 1}&lt; 1{l s='j' mod='coolstats'}
                {else}{$section_data.avg_delay_days}{l s='j' mod='coolstats'}{/if}
            </div>
            <div class="cs-funnel-brutal-l">{l s='Délai moyen 1ère cmd' mod='coolstats'}</div>
        </div>
    </div>
    {/if}
</div>
