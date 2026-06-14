{* ── Clients · Variante Brutalist ──
 * Carte blanche, header "§ CLIENTS" badge bleu + barre horizontale noire,
 * grille 6 colonnes avec border-left 4px noir et label JetBrains Mono.
 *}
<div class="cs-section cs-customers-section cs-customers-brutal" data-cs-section="customers">
    <div class="cs-customers-brutal-header">
        <span class="cs-customers-brutal-badge">§ {l s='Clients' mod='coolstats'}</span>
        <div class="cs-customers-brutal-rule"></div>
    </div>
    <div class="cs-customers-brutal-grid">
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$section_data.total_customers|number_format:0:',':' '}</div>
            <div class="cs-customers-brutal-label">{l s='Clients sur la période' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat cs-kpi-clickable" data-drill="new_customers">
            <div class="cs-customers-brutal-value">{$section_data.new_customers|number_format:0:',':' '} <span class="cs-customers-brutal-pct">({$section_data.new_customers_pct}%)</span></div>
            <div class="cs-customers-brutal-label">{l s='Nouveaux clients' mod='coolstats'}</div>
            <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Voir leurs commandes' mod='coolstats'}</span></div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$section_data.recurring_customers|number_format:0:',':' '}</div>
            <div class="cs-customers-brutal-label">{l s='Clients récurrents' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$section_data.avg_orders|number_format:2:',':' '}</div>
            <div class="cs-customers-brutal-label">{l s='Commandes / client' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$section_data.avg_ltv|number_format:0:',':' '}&euro;</div>
            <div class="cs-customers-brutal-label">{l s='LTV moyenne' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-brutal-stat">
            <div class="cs-customers-brutal-value">{$section_data.refund_value|number_format:0:',':' '}&euro;</div>
            <div class="cs-customers-brutal-label">{l s='Remboursements' mod='coolstats'} · {$section_data.refund_count} {l s='cmd' mod='coolstats'}</div>
        </div>
    </div>
</div>
