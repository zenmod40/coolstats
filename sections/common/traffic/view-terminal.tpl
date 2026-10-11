{* ── Trafic & visiteurs · Variante Terminal ──
 * État empty avec 3 providers en panels.
 *}
<div class="cs-section cs-traffic-section cs-traffic-term" data-cs-section="traffic">
    <div class="cs-section-header">
        <span>📡 {l s='Trafic & visiteurs' mod='coolstats'}</span>
        {if $section_data.available && $section_data.provider_label}
        <span>{if $section_data.live}<span class="cs-traffic-term-badge cs-live" title="{l s='Visiteurs sur le site ces 30 dernières minutes' mod='coolstats'}"><span class="cs-live-dot"></span>{$section_data.live.visitors} {if $section_data.live.visitors > 1}{l s='visiteurs' mod='coolstats'}{else}{l s='visiteur' mod='coolstats'}{/if} · 30 min</span> {/if}<span class="cs-traffic-term-badge cs-traffic-term-badge--ok">{$section_data.provider_label|escape:'html':'UTF-8'}</span></span>
        {else}
        <span class="cs-traffic-term-badge">{l s='Setup' mod='coolstats'}</span>
        {/if}
    </div>
{if $section_data.available && $section_data.api_error}<div class="cs-traffic-api-error">{l s='Matomo a renvoyé une erreur, les chiffres ci-dessous peuvent être faux :' mod='coolstats'} {$section_data.api_error|escape:'html':'UTF-8'}</div>{/if}
    {if !$section_data.available}
    <div class="cs-traffic-term-empty">
        <div class="cs-traffic-term-title">{if $section_data.reason == 'provider_unavailable'}{$section_data.provider_label|escape:'html':'UTF-8'} {l s='ne répond pas' mod='coolstats'}{else}{l s='Aucune source de trafic configurée' mod='coolstats'}{/if}</div>
        <div class="cs-traffic-term-desc">{if $section_data.reason == 'provider_unavailable'}{$section_data.error|escape:'html':'UTF-8'}{elseif $section_data.cooltrack}{l s='CoolTrack envoie déjà vos visites à Matomo : il ne manque que le jeton qui permet de les lire.' mod='coolstats'}{else}{l s='Branchez Matomo ou Google Analytics 4 pour activer cette section.' mod='coolstats'}{/if}</div>
        {if $section_data.config_link}<a class="btn btn-sm btn-primary mt-3" href="{$section_data.config_link|escape:'html':'UTF-8'}" target="_top"><i class="bi bi-gear"></i> {l s='Configurer la source de trafic' mod='coolstats'}</a>{/if}
    </div>
    {else}
    <div class="cs-traffic-term-body">
        <div class="cs-traffic-term-grid">
            {if isset($section_data.visitors)}
            <div class="cs-traffic-term-stat">
                <div class="cs-traffic-term-stat-v">{$section_data.visitors|number_format:0:',':' '}</div>
                <div class="cs-traffic-term-stat-l">{l s='Visiteurs uniques' mod='coolstats'}</div>
            </div>
            {/if}
            {if isset($section_data.pageviews)}
            <div class="cs-traffic-term-stat">
                <div class="cs-traffic-term-stat-v">{$section_data.pageviews|number_format:0:',':' '}</div>
                <div class="cs-traffic-term-stat-l">{l s='Pages vues' mod='coolstats'}</div>
            </div>
            {/if}
            {if isset($section_data.avg_session_duration)}
            <div class="cs-traffic-term-stat">
                <div class="cs-traffic-term-stat-v">{$section_data.avg_session_duration}s</div>
                <div class="cs-traffic-term-stat-l">{l s='Durée moyenne' mod='coolstats'}</div>
            </div>
            {/if}
            {if isset($section_data.bounce_rate)}
            <div class="cs-traffic-term-stat">
                <div class="cs-traffic-term-stat-v">{$section_data.bounce_rate}%</div>
                <div class="cs-traffic-term-stat-l">{l s='Taux de rebond' mod='coolstats'}</div>
            </div>
            {/if}
        </div>
    </div>
    {/if}
</div>
