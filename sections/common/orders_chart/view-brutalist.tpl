{* ── Courbe des commandes · Variante Brutalist ──
 * Carte rose magenta, titre "📈 COURBE DES COMMANDES", badge noir "CMD · 28J",
 * canvas Chart.js sur fond blanc bordure noire. Switch Commandes / CA conservé.
 *}
<div class="cs-section cs-orders-chart-section cs-orders-chart-brutal" data-cs-section="orders_chart"
     data-chart-labels="{$section_data.labels|@json_encode|escape:'html'}"
     data-chart-orders="{$section_data.orders_data|@json_encode|escape:'html'}"
     data-chart-revenue="{$section_data.revenue_data|@json_encode|escape:'html'}">
    <div class="cs-orders-brutal-header">
        <span class="cs-orders-brutal-title">📈 {l s='Courbe des commandes' mod='coolstats'}</span>
        <div class="cs-orders-brutal-right">
            <div class="cs-orders-brutal-switch">
                <span class="cs-line-mode-label cs-active" data-mode="orders">{l s='Commandes' mod='coolstats'}</span>
                <div class="form-check form-switch mb-0">
                    <input class="form-check-input cs-line-toggle" type="checkbox" id="cs-line-mode-toggle">
                </div>
                <span class="cs-line-mode-label text-muted" data-mode="revenue">{l s='CA' mod='coolstats'} &euro;</span>
            </div>
            <span class="cs-orders-brutal-badge">{l s='CMD' mod='coolstats'} · 28{l s='J' mod='coolstats'}</span>
        </div>
    </div>
    <div class="cs-orders-brutal-chart-wrap">
        <canvas id="cs-chart-line" height="200"></canvas>
    </div>
</div>
