{function name=cs_format_duration sec=0}
    {if $sec >= 60}
        {assign var=cs_mins_f value=$sec/60}
        {assign var=cs_mins value=$cs_mins_f|intval}
        {assign var=cs_mins_x60 value=$cs_mins*60}
        {assign var=cs_rem value=$sec-$cs_mins_x60}
        {$cs_mins}min {$cs_rem}s
    {else}
        {$sec}s
    {/if}
{/function}

<div class="cs-section cs-traffic-section" data-cs-section="traffic">
    <div class="cs-section-header">
        <span><i class="bi bi-graph-up-arrow"></i> {$section.title}</span>
        {if $section_data.available && $section_data.provider_label}
            <span class="ms-auto d-inline-flex gap-2 align-items-center">
            {if $section_data.live}<span class="cs-live" title="{l s='Visiteurs sur le site ces 30 dernières minutes' mod='coolstats'}"><span class="cs-live-dot"></span>{$section_data.live.visitors} {if $section_data.live.visitors > 1}{l s='visiteurs' mod='coolstats'}{else}{l s='visiteur' mod='coolstats'}{/if} · 30 min</span>{/if}
            <span class="badge cs-badge-accent" title="Source des données"><i class="bi bi-bar-chart-line me-1"></i>{$section_data.provider_label|escape:'html':'UTF-8'}</span>
            </span>
        {/if}
    </div>
    {if $section_data.available && $section_data.api_error}<div class="cs-traffic-api-error">{l s='Matomo a renvoyé une erreur, les chiffres ci-dessous peuvent être faux :' mod='coolstats'} {$section_data.api_error|escape:'html':'UTF-8'}</div>{/if}

    {if !$section_data.available}
        <div class="cs-traffic-empty">
            <i class="bi bi-bar-chart-line"></i>
            <h4 class="mt-3 mb-2">{if $section_data.reason == 'provider_unavailable'}{$section_data.provider_label|escape:'html':'UTF-8'} {l s='ne répond pas' mod='coolstats'}{else}{l s='Aucune source de trafic configurée' mod='coolstats'}{/if}</h4>
            <p class="text-muted small mb-0">{if $section_data.reason == 'provider_unavailable'}{$section_data.error|escape:'html':'UTF-8'}{elseif $section_data.cooltrack}{l s='CoolTrack envoie déjà vos visites à Matomo : il ne manque que le jeton qui permet de les lire.' mod='coolstats'}{else}{l s='Branchez Matomo ou Google Analytics 4 pour activer cette section.' mod='coolstats'}{/if}</p>
            {if $section_data.config_link}<a class="btn btn-sm btn-primary mt-3" href="{$section_data.config_link|escape:'html':'UTF-8'}" target="_top"><i class="bi bi-gear"></i> {l s='Configurer la source de trafic' mod='coolstats'}</a>{/if}
        </div>
    {else}
        {* ── KPI principaux ── *}
        <div class="row g-3 cs-traffic-kpi">
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-people text-primary"></i>
                    <div class="cs-traffic-stat-value">{$section_data.kpi.unique_visitors|number_format:0:',':' '}</div>
                    <div class="cs-traffic-stat-label">Visiteurs uniques</div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-clock-history text-info"></i>
                    <div class="cs-traffic-stat-value">{$section_data.kpi.sessions|number_format:0:',':' '}</div>
                    <div class="cs-traffic-stat-label">Sessions</div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-eye text-success"></i>
                    <div class="cs-traffic-stat-value">{$section_data.kpi.page_views|number_format:0:',':' '}</div>
                    <div class="cs-traffic-stat-label">Pages vues</div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-stack text-warning"></i>
                    <div class="cs-traffic-stat-value">{$section_data.kpi.pages_per_session}</div>
                    <div class="cs-traffic-stat-label">Pages / session</div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-stopwatch text-secondary"></i>
                    <div class="cs-traffic-stat-value">{cs_format_duration sec=$section_data.kpi.avg_duration_sec}</div>
                    <div class="cs-traffic-stat-label">Durée moyenne</div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-traffic-stat">
                    <i class="bi bi-bullseye text-danger"></i>
                    <div class="cs-traffic-stat-value">{$section_data.kpi.conversion_rate}%</div>
                    <div class="cs-traffic-stat-label">Conversion</div>
                </div>
            </div>
        </div>

        {* ── Sous-blocs : top pages, sources, devices ── *}
        <div class="row g-3 mt-2">
            <div class="col-xl-4 col-md-6">
                <div class="cs-traffic-subblock">
                    <div class="cs-traffic-subblock-title"><i class="bi bi-file-earmark-text"></i> Top pages vues</div>
                    {if $section_data.top_pages}
                        <ul class="cs-traffic-list">
                            {foreach from=$section_data.top_pages item=p}
                            <li><span class="cs-traffic-list-label">{$p.label|escape:'html':'UTF-8'}</span><span class="cs-traffic-list-value">{$p.views|number_format:0:',':' '}</span></li>
                            {/foreach}
                        </ul>
                    {else}
                        <div class="text-muted small">Aucune donnée</div>
                    {/if}
                </div>
            </div>
            <div class="col-xl-4 col-md-6">
                <div class="cs-traffic-subblock">
                    <div class="cs-traffic-subblock-title"><i class="bi bi-link-45deg"></i> Top sources de trafic</div>
                    {if $section_data.top_sources}
                        <ul class="cs-traffic-list">
                            {foreach from=$section_data.top_sources item=s}
                            <li><span class="cs-traffic-list-label">{$s.source|escape:'html':'UTF-8'}</span><span class="cs-traffic-list-value">{$s.hits|number_format:0:',':' '}</span></li>
                            {/foreach}
                        </ul>
                    {else}
                        <div class="text-muted small">Aucune donnée</div>
                    {/if}
                </div>
            </div>
            <div class="col-xl-4 col-md-12">
                <div class="cs-traffic-subblock">
                    <div class="cs-traffic-subblock-title"><i class="bi bi-phone"></i> Mobile vs Desktop</div>
                    <div class="cs-device-bars mt-2">
                        <div class="cs-device-row">
                            <span><i class="bi bi-phone"></i> Mobile</span>
                            <span class="fw-bold">{$section_data.devices.mobile_pct}%</span>
                        </div>
                        <div class="progress" style="height:6px"><div class="progress-bar" role="progressbar" style="width:{$section_data.devices.mobile_pct}%; background:var(--cs-accent)"></div></div>
                        <div class="text-muted small">{$section_data.devices.mobile|number_format:0:',':' '} sessions</div>
                        <div class="cs-device-row mt-3">
                            <span><i class="bi bi-laptop"></i> Desktop</span>
                            <span class="fw-bold">{$section_data.devices.desktop_pct}%</span>
                        </div>
                        <div class="progress" style="height:6px"><div class="progress-bar" role="progressbar" style="width:{$section_data.devices.desktop_pct}%; background:var(--cs-accent-2)"></div></div>
                        <div class="text-muted small">{$section_data.devices.desktop|number_format:0:',':' '} sessions</div>
                    </div>
                </div>
            </div>
        </div>
    {/if}
</div>
