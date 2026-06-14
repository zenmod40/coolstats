{* ── Trafic & visiteurs · Variante Terminal ──
 * État empty avec 3 providers en panels.
 *}
<div class="cs-section cs-traffic-section cs-traffic-term" data-cs-section="traffic">
    <div class="cs-section-header">
        <span>📡 {l s='Trafic & visiteurs' mod='coolstats'}</span>
        {if $section_data.available && $section_data.provider_label}
        <span class="cs-traffic-term-badge cs-traffic-term-badge--ok">{$section_data.provider_label}</span>
        {else}
        <span class="cs-traffic-term-badge">{l s='Setup' mod='coolstats'}</span>
        {/if}
    </div>
    {if !$section_data.available}
    <div class="cs-traffic-term-empty">
        <div class="cs-traffic-term-icon">📊</div>
        <div class="cs-traffic-term-title">{l s='Aucune source de trafic configurée' mod='coolstats'}</div>
        <div class="cs-traffic-term-desc">{l s='CoolStats préfère ne rien afficher plutôt que de montrer des chiffres trompeurs. Connecte un outil d\'analyse fiable pour activer cette section.' mod='coolstats'}</div>
        <div class="cs-traffic-term-providers">
            <div class="cs-traffic-term-provider">
                <span class="cs-traffic-term-provider-soon">{l s='Bientôt' mod='coolstats'}</span>
                <div class="cs-traffic-term-provider-i">▤</div>
                <div class="cs-traffic-term-provider-n">{l s='Matomo' mod='coolstats'}</div>
                <div class="cs-traffic-term-provider-d">{l s='Open-source, RGPD-friendly' mod='coolstats'}</div>
            </div>
            <div class="cs-traffic-term-provider">
                <span class="cs-traffic-term-provider-soon">{l s='Bientôt' mod='coolstats'}</span>
                <div class="cs-traffic-term-provider-i">G</div>
                <div class="cs-traffic-term-provider-n">{l s='Google Analytics 4' mod='coolstats'}</div>
                <div class="cs-traffic-term-provider-d">{l s='Tracking par défaut Google' mod='coolstats'}</div>
            </div>
            <div class="cs-traffic-term-provider">
                <span class="cs-traffic-term-provider-soon">{l s='Bientôt' mod='coolstats'}</span>
                <div class="cs-traffic-term-provider-i">◊</div>
                <div class="cs-traffic-term-provider-n">{l s='Plausible' mod='coolstats'}</div>
                <div class="cs-traffic-term-provider-d">{l s='Simple, sans cookies' mod='coolstats'}</div>
            </div>
        </div>
        <div class="cs-traffic-term-note">ⓘ {l s='Le tracking natif PrestaShop (statsdata) est incomplet et obsolète : pas de détection mobile fiable, pas de filtrage des bots, OS encodés limités. CoolStats l\'ignore désormais par défaut.' mod='coolstats'}</div>
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
