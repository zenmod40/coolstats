<div class="cs-section cs-marketplace-breakdown" data-cs-section="marketplace_breakdown">
    <div class="cs-section-header">
        <span><i class="bi bi-shop-window"></i> {$section.title}</span>
        <span class="cs-mkp-header-badge">
            <strong>{$section_data.totals.orders|number_format:0:',':' '}</strong> commande{if $section_data.totals.orders > 1}s{/if}
            &middot; <strong>{$section_data.totals.revenue|number_format:0:',':' '}&euro;</strong>
            {if $section_data.totals.orders > 0}
                &middot; panier moyen <strong>{$section_data.totals.aov|number_format:0:',':' '}&euro;</strong>
            {/if}
        </span>
    </div>

    {if !$section_data.source}
        <div class="p-3 text-center text-muted small">
            <i class="bi bi-info-circle fs-4 d-block mb-2"></i>
            Aucune source de données marketplace détectée (ni <code>marketplace_orders</code>, ni <code>shoppingfeed_order</code>).
        </div>
    {elseif $section_data.rows|@count == 0}
        <div class="p-3 text-center text-muted small">
            <i class="bi bi-shop-window fs-4 d-block mb-2"></i>
            Aucune commande sur la période sélectionnée.
        </div>
    {else}
        <div class="row g-3 cs-mkp-grid">
            {foreach from=$section_data.rows item=r}
            <div class="col-xl-4 col-md-6">
                {* Card cliquable : déclenche le filtre global "channels".
                   - data-filter="channels" + data-toggle-mode="multi" → handler JS qui
                     ajoute/retire la clé dans le param ?channels=...
                   - cs-mkp-card--active = état visuel quand cette card est dans le filtre. *}
                <div class="cs-mkp-card cs-filter {if $r.is_direct}cs-mkp-card--direct{elseif $r.is_other}cs-mkp-card--other{else}cs-mkp-card--mkp{/if}{if $r.key|in_array:$section_data.active_channels} cs-mkp-card--active{/if}"
                     data-filter="channels"
                     data-toggle-mode="multi"
                     data-mkp-key="{$r.key|escape:'html':'UTF-8'}"
                     role="button"
                     tabindex="0">
                    <div class="cs-mkp-card-head">
                        <span class="cs-mkp-card-icon" aria-hidden="true">
                            {if $r.is_direct}<i class="bi bi-shop"></i>
                            {elseif $r.is_other}<i class="bi bi-three-dots"></i>
                            {else}<i class="bi bi-globe2"></i>
                            {/if}
                        </span>
                        <div class="cs-mkp-card-title">
                            <strong>{$r.label|escape:'html':'UTF-8'}</strong>
                            <span class="cs-mkp-card-subtitle">{$r.pct_revenue}% du CA</span>
                        </div>
                    </div>

                    <div class="cs-mkp-card-stats">
                        <div class="cs-mkp-stat">
                            <div class="cs-mkp-stat-value">{$r.orders|number_format:0:',':' '}</div>
                            <div class="cs-mkp-stat-label">commande{if $r.orders > 1}s{/if}</div>
                        </div>
                        <div class="cs-mkp-stat">
                            <div class="cs-mkp-stat-value">{$r.revenue|number_format:0:',':' '}&euro;</div>
                            <div class="cs-mkp-stat-label">CA</div>
                        </div>
                        <div class="cs-mkp-stat">
                            <div class="cs-mkp-stat-value">{$r.aov|number_format:0:',':' '}&euro;</div>
                            <div class="cs-mkp-stat-label">panier moy.</div>
                        </div>
                    </div>

                    <div class="cs-mkp-bar-wrap" title="{$r.pct_revenue}% du CA total">
                        <span class="cs-mkp-bar" style="width:{$r.pct_revenue}%"></span>
                    </div>
                </div>
            </div>
            {/foreach}
        </div>
    {/if}
</div>

<style>
/* ─── Styles cs-marketplace-breakdown ─────────────────────────
 * Scoped sous .cs-marketplace-breakdown pour pas fuiter.
 */

/* Badge total dans le header de section — lisible sur tous les thèmes
 * (utilise les variables cs- au lieu de Bootstrap text-bg-light qui était
 * blanc sur blanc en Aurora dark). */
.cs-marketplace-breakdown .cs-mkp-header-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 500;
    background: rgba(127, 127, 127, 0.12);
    color: var(--cs-text);
    border: 1px solid var(--cs-border, rgba(127, 127, 127, 0.25));
    white-space: nowrap;
}
.cs-marketplace-breakdown .cs-mkp-header-badge strong {
    font-weight: 700;
    color: var(--cs-text);
}

.cs-marketplace-breakdown .cs-mkp-grid {
    margin-top: 4px;
}

.cs-marketplace-breakdown .cs-mkp-card {
    background: var(--cs-bg-card);
    border: 1px solid var(--cs-border, rgba(127, 127, 127, 0.18));
    border-radius: 12px;
    padding: 14px 16px;
    height: 100%;
    display: flex;
    flex-direction: column;
    gap: 12px;
    transition: border-color 0.15s ease, transform 0.15s ease;
}
.cs-marketplace-breakdown .cs-mkp-card:hover {
    border-color: var(--cs-accent, #2D3DFF);
    transform: translateY(-1px);
}
.cs-marketplace-breakdown .cs-mkp-card.cs-filter {
    cursor: pointer;
    user-select: none;
}
.cs-marketplace-breakdown .cs-mkp-card--active {
    border-color: var(--cs-accent, #2D3DFF);
    box-shadow: 0 0 0 2px rgba(45, 61, 255, 0.18);
    background: linear-gradient(180deg,
        rgba(45, 61, 255, 0.08) 0%,
        var(--cs-bg-card) 100%);
}
.cs-marketplace-breakdown .cs-mkp-card--active::after {
    content: "✓";
    position: absolute;
    top: 8px; right: 12px;
    font-size: 14px; font-weight: 700;
    color: var(--cs-accent, #2D3DFF);
}
.cs-marketplace-breakdown .cs-mkp-card { position: relative; }

.cs-marketplace-breakdown .cs-mkp-card-head {
    display: flex;
    align-items: center;
    gap: 12px;
}
.cs-marketplace-breakdown .cs-mkp-card-icon {
    width: 36px; height: 36px;
    border-radius: 8px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    background: rgba(45, 61, 255, 0.12);
    color: var(--cs-accent, #2D3DFF);
    flex-shrink: 0;
}
.cs-marketplace-breakdown .cs-mkp-card--direct .cs-mkp-card-icon {
    background: rgba(17, 212, 154, 0.14);
    color: var(--cs-accent-2, #11D49A);
}
.cs-marketplace-breakdown .cs-mkp-card--other .cs-mkp-card-icon {
    background: rgba(127, 127, 127, 0.14);
    color: var(--cs-text-muted, #888);
}
.cs-marketplace-breakdown .cs-mkp-card-title {
    display: flex;
    flex-direction: column;
    gap: 2px;
    min-width: 0;
    flex: 1;
}
.cs-marketplace-breakdown .cs-mkp-card-title strong {
    font-size: 15px;
    line-height: 1.2;
    color: var(--cs-text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.cs-marketplace-breakdown .cs-mkp-card-subtitle {
    font-size: 11px;
    color: var(--cs-text-muted, #888);
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

.cs-marketplace-breakdown .cs-mkp-card-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
}
.cs-marketplace-breakdown .cs-mkp-stat {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}
.cs-marketplace-breakdown .cs-mkp-stat-value {
    font-size: 15px;
    font-weight: 700;
    color: var(--cs-text);
    line-height: 1.1;
    font-variant-numeric: tabular-nums;
}
.cs-marketplace-breakdown .cs-mkp-stat-label {
    font-size: 10px;
    color: var(--cs-text-muted, #888);
    text-transform: uppercase;
    letter-spacing: 0.4px;
    margin-top: 2px;
}

.cs-marketplace-breakdown .cs-mkp-bar-wrap {
    height: 6px;
    border-radius: 3px;
    background: rgba(127, 127, 127, 0.15);
    overflow: hidden;
}
.cs-marketplace-breakdown .cs-mkp-bar {
    display: block;
    height: 100%;
    background: linear-gradient(90deg, var(--cs-accent, #2D3DFF), var(--cs-accent-2, #11D49A));
    border-radius: 3px;
    transition: width 0.3s ease;
}
.cs-marketplace-breakdown .cs-mkp-card--direct .cs-mkp-bar {
    background: linear-gradient(90deg, var(--cs-accent-2, #11D49A), var(--cs-accent, #2D3DFF));
}

/* Aurora override pour le badge — variant adapté au glass effect */
[data-cs-theme="aurora"] .cs-marketplace-breakdown .cs-mkp-header-badge {
    background: rgba(124, 92, 255, 0.15);
    border-color: rgba(124, 92, 255, 0.25);
    color: var(--cs-text);
}
</style>
