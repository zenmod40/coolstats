{* ── Tunnel de conversion · Variante Terminal ──
 * Step rail (2 cards + arrow), puis ligne secondaire (fantômes + délai).
 *}
<div class="cs-section cs-signups-section cs-signups-term" data-cs-section="signups">
    <div class="cs-section-header">
        <span>▸ {l s='Tunnel de conversion' mod='coolstats'}</span>
    </div>
    {if $section_data.total_created == 0}
        <div class="cs-term-empty">{l s='Aucun compte créé sur la période' mod='coolstats'}</div>
    {else}
    <div class="cs-signups-term-body">
        {* ─── Step rail : comptes créés → ont commandé ─── *}
        <div class="cs-signups-term-rail">
            <div class="cs-signups-term-card">
                <div class="cs-signups-term-v">{$section_data.total_created|number_format:0:',':' '}</div>
                <div class="cs-signups-term-l">{l s='comptes créés' mod='coolstats'}</div>
            </div>
            <div class="cs-signups-term-arrow">
                <div class="cs-signups-term-arrow-icon">→</div>
                <div class="cs-signups-term-arrow-pct">{$section_data.conversion_rate}%</div>
            </div>
            <div class="cs-signups-term-card">
                <div class="cs-signups-term-v">{$section_data.with_order|number_format:0:',':' '}</div>
                <div class="cs-signups-term-l">{l s='ont commandé' mod='coolstats'}</div>
            </div>
        </div>

        {* ─── Ligne secondaire : fantômes + délai moyen ─── *}
        <div class="cs-signups-term-secondary">
            <div class="cs-signups-term-stat cs-signups-term-stat--bad">
                <span class="cs-signups-term-stat-icon">⚠</span>
                <div class="cs-signups-term-stat-body">
                    <div class="cs-signups-term-stat-v">{$section_data.without_order|number_format:0:',':' '}</div>
                    <div class="cs-signups-term-stat-l">{l s='comptes fantômes (jamais commandé)' mod='coolstats'}</div>
                </div>
                {if $section_data.total_created > 0}
                {assign var=cs_ghost_pct value=($section_data.without_order * 100) / $section_data.total_created}
                <span class="cs-signups-term-stat-pct">{$cs_ghost_pct|string_format:'%.0f'}%</span>
                {/if}
            </div>
            <div class="cs-signups-term-stat">
                <span class="cs-signups-term-stat-icon">⏱</span>
                <div class="cs-signups-term-stat-body">
                    <div class="cs-signups-term-stat-v cs-signups-term-stat-v--good">
                        {if $section_data.avg_delay_days === null}—
                        {elseif $section_data.avg_delay_days < 1}&lt; 1 {l s='jour' mod='coolstats'}
                        {else}{$section_data.avg_delay_days} {l s='jours' mod='coolstats'}{/if}
                    </div>
                    <div class="cs-signups-term-stat-l">{l s='délai moyen avant 1ʳᵉ commande' mod='coolstats'}</div>
                </div>
            </div>
        </div>
    </div>
    {/if}
</div>
