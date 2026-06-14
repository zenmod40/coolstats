<div class="cs-section cs-customers-section" data-cs-section="customers">
    <div class="cs-section-header"><i class="bi bi-people-fill"></i> {$section.title}</div>
    <div class="row g-3">
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-orders"><i class="bi bi-person"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.total_customers|number_format:0:',':' '}</div>
                    <div class="cs-customer-stat-label">Clients sur la période</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat cs-kpi-clickable" data-drill="new_customers">
                <div class="cs-customer-stat-icon cs-kpi-icon-revenue"><i class="bi bi-person-plus"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.new_customers|number_format:0:',':' '} <small class="text-muted">({$section_data.new_customers_pct}%)</small></div>
                    <div class="cs-customer-stat-label">Nouveaux clients</div>
                </div>
                <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir leurs commandes</span></div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-items"><i class="bi bi-arrow-repeat"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.recurring_customers|number_format:0:',':' '}</div>
                    <div class="cs-customer-stat-label">Clients récurrents</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon cs-kpi-icon-basket"><i class="bi bi-bag-check"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.avg_orders|number_format:2:',':' '}</div>
                    <div class="cs-customer-stat-label">Commandes / client</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(245,158,11,.15);color:var(--cs-warning)"><i class="bi bi-coin"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.avg_ltv|number_format:0:',':' '}&euro;</div>
                    <div class="cs-customer-stat-label" title="CA total cumulé / nb clients">LTV moyenne</div>
                </div>
            </div>
        </div>
        <div class="col-xl col-md-4 col-sm-6">
            <div class="cs-customer-stat">
                <div class="cs-customer-stat-icon" style="background:rgba(239,68,68,.15);color:var(--cs-danger)"><i class="bi bi-arrow-counterclockwise"></i></div>
                <div class="cs-customer-stat-body">
                    <div class="cs-customer-stat-value">{$section_data.refund_value|number_format:0:',':' '}&euro;</div>
                    <div class="cs-customer-stat-label">Remboursements <span class="text-muted">· {$section_data.refund_count} cmd</span></div>
                </div>
            </div>
        </div>
    </div>
</div>
