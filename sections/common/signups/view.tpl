{* ── Section Tunnel de conversion compte → 1re commande ── *}
<div class="cs-section cs-signups-section" data-cs-section="signups">
    <div class="cs-section-header"><i class="bi bi-person-plus"></i> {$section.title}</div>

    {if $section_data.total_created == 0}
        <div class="text-muted small text-center py-3">Aucun compte créé sur la période.</div>
    {else}
        <div class="cs-signups-funnel">
            <div class="cs-signups-stage cs-signups-stage-1">
                <div class="cs-signups-stage-value">{$section_data.total_created|number_format:0:',':' '}</div>
                <div class="cs-signups-stage-label">Comptes créés</div>
            </div>
            <div class="cs-signups-arrow">
                <i class="bi bi-arrow-right"></i>
                <span class="cs-signups-rate
                    {if $section_data.conversion_rate >= 40}cs-signups-good
                    {elseif $section_data.conversion_rate >= 15}cs-signups-mid
                    {else}cs-signups-low{/if}">{$section_data.conversion_rate}%</span>
            </div>
            <div class="cs-signups-stage cs-signups-stage-2">
                <div class="cs-signups-stage-value">{$section_data.with_order|number_format:0:',':' '}</div>
                <div class="cs-signups-stage-label">Ont commandé</div>
            </div>
        </div>

        <div class="cs-signups-meta row g-2 mt-3">
            <div class="col-md-6">
                <div class="cs-signups-meta-card">
                    <i class="bi bi-person-x"></i>
                    <div>
                        <div class="cs-signups-meta-value">{$section_data.without_order|number_format:0:',':' '}</div>
                        <div class="cs-signups-meta-label">Comptes fantômes (jamais commandé)</div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="cs-signups-meta-card">
                    <i class="bi bi-clock-history"></i>
                    <div>
                        {if $section_data.avg_delay_days !== null}
                            <div class="cs-signups-meta-value">
                                {if $section_data.avg_delay_days < 1}&lt; 1 jour
                                {else}{$section_data.avg_delay_days} jour{if $section_data.avg_delay_days >= 2}s{/if}{/if}
                            </div>
                            <div class="cs-signups-meta-label">Délai moyen avant 1<sup>re</sup> commande</div>
                        {else}
                            <div class="cs-signups-meta-value text-muted">—</div>
                            <div class="cs-signups-meta-label">Pas assez de données</div>
                        {/if}
                    </div>
                </div>
            </div>
        </div>
    {/if}
</div>
