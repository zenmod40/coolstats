<div class="cs-section cs-payment-bar-section" data-cs-section="payment_breakdown"
     data-chart-breakdown="{$section_data.breakdown|@json_encode|escape:'html'}">
    <div class="cs-section-header">
        <span><i class="bi bi-bar-chart-line"></i> {$section.title}</span>
        <div class="d-flex align-items-center gap-2">
            <span class="small cs-bar-mode-label cs-active" data-mode="orders">Commandes</span>
            <div class="form-check form-switch mb-0">
                <input class="form-check-input cs-bar-toggle" type="checkbox" id="cs-bar-mode-toggle">
            </div>
            <span class="small cs-bar-mode-label text-muted" data-mode="revenue">CA &euro;</span>
        </div>
    </div>
    <div class="cs-chart-wrap">
        <canvas id="cs-chart-bar" height="240"></canvas>
    </div>
</div>
