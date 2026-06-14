{* ── Moyens de paiement · Variante Terminal ──
 * Bar chart Chart.js, toggle COMMANDES ● / CA € en mono.
 *}
<div class="cs-section cs-payment-bar-section cs-payment-term" data-cs-section="payment_breakdown"
     data-chart-breakdown="{$section_data.breakdown|@json_encode|escape:'html'}">
    <div class="cs-section-header">
        <span>€ {l s='Répartition par moyen de paiement' mod='coolstats'}</span>
        <div class="cs-payment-term-sort">
            <span class="cs-payment-term-sort-label cs-active" data-mode="orders">{l s='Commandes' mod='coolstats'}</span>
            <span class="cs-payment-term-sort-label" data-mode="revenue">{l s='CA' mod='coolstats'} &euro;</span>
            <div class="form-check form-switch mb-0">
                <input class="form-check-input cs-bar-toggle" type="checkbox" id="cs-bar-mode-toggle">
            </div>
        </div>
    </div>
    <div class="cs-payment-term-chart">
        <canvas id="cs-chart-bar" height="180"></canvas>
    </div>
</div>
