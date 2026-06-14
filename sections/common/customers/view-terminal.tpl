{* ── Clients · Variante Terminal ──
 * Grid 6 colonnes, valeur 20px, dividers dashed, LTV amber, refund neutral.
 *}
<div class="cs-section cs-customers-section cs-customers-term" data-cs-section="customers">
    <div class="cs-section-header">
        <span>§ {l s='Clients' mod='coolstats'}</span>
        <span class="cs-customers-term-meta">6 {l s='metrics' mod='coolstats'}</span>
    </div>
    <div class="cs-customers-term-grid">
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$section_data.total_customers|number_format:0:',':' '}</div>
            <div class="cs-customers-term-l">{l s='Clients sur' mod='coolstats'}<br>{l s='la période' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat cs-kpi-clickable" data-drill="new_customers">
            <div class="cs-customers-term-v">{$section_data.new_customers|number_format:0:',':' '} <span class="cs-customers-term-pct">({$section_data.new_customers_pct}%)</span></div>
            <div class="cs-customers-term-l">{l s='Nouveaux' mod='coolstats'}<br>{l s='clients' mod='coolstats'}</div>
            <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>{l s='Voir leurs commandes' mod='coolstats'}</span></div>
        </div>
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$section_data.recurring_customers|number_format:0:',':' '}</div>
            <div class="cs-customers-term-l">{l s='Clients' mod='coolstats'}<br>{l s='récurrents' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat">
            <div class="cs-customers-term-v">{$section_data.avg_orders|number_format:2:',':' '}</div>
            <div class="cs-customers-term-l">{l s='Commandes' mod='coolstats'}<br>{l s='/ client' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat cs-customers-term-stat--amber">
            <div class="cs-customers-term-v">{$section_data.avg_ltv|number_format:0:',':' '}&euro;</div>
            <div class="cs-customers-term-l">{l s='LTV' mod='coolstats'}<br>{l s='moyenne' mod='coolstats'}</div>
        </div>
        <div class="cs-customers-term-stat cs-customers-term-stat--neutral">
            <div class="cs-customers-term-v">{$section_data.refund_value|number_format:0:',':' '}&euro;</div>
            <div class="cs-customers-term-l">{l s='Remboursements' mod='coolstats'}<br>· {$section_data.refund_count} {l s='cmd' mod='coolstats'}</div>
        </div>
    </div>
</div>
