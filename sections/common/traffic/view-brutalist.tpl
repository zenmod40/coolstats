{* ── Trafic & visiteurs · Variante Brutalist ── carte cobalt, titre simple + tag jaune *}
<div class="cs-section cs-traffic-brutal cs-brutal-card-colored cs-brutal-card-cobalt" data-cs-section="traffic">
    <div class="cs-brutal-colored-title">
        <div class="cs-brutal-colored-t">📡 {l s='Trafic & visiteurs' mod='coolstats'}</div>
        {if $section_data.available && $section_data.provider_label}
        <span class="cs-brutal-tag cs-brutal-tag-yellow">{$section_data.provider_label}</span>
        {else}
        <span class="cs-brutal-tag cs-brutal-tag-yellow">{l s='Setup' mod='coolstats'}</span>
        {/if}
    </div>

    {if !$section_data.available}
    <div class="cs-traffic-brutal-empty">
        <div class="cs-traffic-brutal-h">{l s='Aucune source configurée' mod='coolstats'}</div>
        <div class="cs-traffic-brutal-s">{l s='Connecte Matomo ou GA4 pour activer cette section' mod='coolstats'}</div>
        <div class="cs-traffic-brutal-providers">
            <div class="cs-traffic-brutal-provider">
                <div class="cs-traffic-brutal-provider-n">{l s='Matomo' mod='coolstats'}</div>
                <div class="cs-traffic-brutal-provider-d">{l s='RGPD-friendly' mod='coolstats'}</div>
            </div>
            <div class="cs-traffic-brutal-provider">
                <div class="cs-traffic-brutal-provider-n">{l s='GA4' mod='coolstats'}</div>
                <div class="cs-traffic-brutal-provider-d">{l s='Google Analytics' mod='coolstats'}</div>
            </div>
        </div>
    </div>
    {else}
    <div class="cs-traffic-brutal-grid">
        {if isset($section_data.visitors)}
        <div class="cs-traffic-brutal-stat">
            <div class="cs-traffic-brutal-v">{$section_data.visitors|number_format:0:',':' '}</div>
            <div class="cs-traffic-brutal-l">{l s='Visiteurs uniques' mod='coolstats'}</div>
        </div>
        {/if}
        {if isset($section_data.pageviews)}
        <div class="cs-traffic-brutal-stat">
            <div class="cs-traffic-brutal-v">{$section_data.pageviews|number_format:0:',':' '}</div>
            <div class="cs-traffic-brutal-l">{l s='Pages vues' mod='coolstats'}</div>
        </div>
        {/if}
        {if isset($section_data.avg_session_duration)}
        <div class="cs-traffic-brutal-stat">
            <div class="cs-traffic-brutal-v">{$section_data.avg_session_duration}s</div>
            <div class="cs-traffic-brutal-l">{l s='Durée moyenne' mod='coolstats'}</div>
        </div>
        {/if}
        {if isset($section_data.bounce_rate)}
        <div class="cs-traffic-brutal-stat">
            <div class="cs-traffic-brutal-v">{$section_data.bounce_rate}%</div>
            <div class="cs-traffic-brutal-l">{l s='Taux de rebond' mod='coolstats'}</div>
        </div>
        {/if}
    </div>
    {/if}
</div>
