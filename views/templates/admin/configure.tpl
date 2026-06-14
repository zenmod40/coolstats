{*
 * CoolStats — page de configuration (BO).
 * Design MG : header gradient + tabs custom + panels.
 * Référence : CoolCheck/views/templates/admin/configure.tpl.
 *}
<style>
.coolstats-admin {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
.coolstats-admin * { box-sizing: border-box; }

.cs-config-header {
    background: linear-gradient(135deg, #0F172A 0%, #0F172A 60%, #041233 100%);
    color: #fff;
    padding: 24px 32px;
    border-radius: 8px;
    margin-bottom: 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 16px;
}
.cs-config-header .cs-config-brand { display: flex; align-items: center; gap: 16px; }
.cs-config-header img.cs-logo { height: 44px; width: auto; }
.cs-config-header h2 { margin: 0; font-size: 22px; font-weight: 600; }
.cs-config-header .cs-config-version { opacity: 0.85; font-size: 13px; margin-top: 4px; }
.cs-config-header .cs-config-shop {
    background: rgba(255,255,255,0.2);
    padding: 6px 14px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 500;
}

.cs-config-meta {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    margin-bottom: 18px;
    font-size: 13px;
    color: #6d7175;
}
.cs-config-meta .cs-config-mode {
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
}
.cs-config-mode--direct { background: #e8f5e9; color: #2e7d32; }
.cs-config-mode--mkp { background: #fff3e0; color: #e65100; }
.cs-config-meta .cs-config-link {
    background: #041233;
    color: #fff;
    padding: 8px 16px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
}
.cs-config-meta .cs-config-link:hover { background: #1a2e52; color: #fff; }

.cs-tabs {
    display: flex;
    border-bottom: 2px solid #e3e5e7;
    gap: 0;
    flex-wrap: wrap;
}
.cs-tab {
    padding: 12px 24px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    color: #6d7175;
    border-bottom: 2px solid transparent;
    margin-bottom: -2px;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 8px;
    background: none;
    border-left: none;
    border-right: none;
    border-top: none;
}
.cs-tab:hover { color: #041233; }
.cs-tab.active { color: #041233; border-bottom-color: #041233; }

.cs-tab-content { display: none; padding: 20px 0 0 0; }
.cs-tab-content.active { display: block; }

.cs-panel {
    background: #fff;
    border: 1px solid #e3e5e7;
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 20px;
}
.cs-panel-title {
    font-size: 15px;
    font-weight: 600;
    color: #202223;
    margin: 0 0 16px;
    padding: 0 0 10px;
    border-bottom: 1px solid #f0f0f0;
}
/* Override PrestaShop admin h3 spacing (titres trop collés) */
#content.bootstrap h3:not(.modal-title).cs-panel-title {
    padding: 3px 0px 5px 10px;
}

/* Diagnostic trafic */
.cs-traffic-diag {
    background: #f7f8fb;
    border: 1px solid #e3e5e7;
    border-radius: 8px;
    padding: 4px 14px;
    margin: 8px 0 14px;
}
.cs-traffic-diag-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    border-bottom: 1px solid #e3e5e7;
    font-size: 13px;
    color: #202223;
}
.cs-traffic-diag-row:last-child { border-bottom: none; }
.cs-traffic-diag-row code { background: #fff; padding: 1px 6px; border-radius: 4px; font-size: 12px; }
.cs-diag-ok    { color: #2e7d32; font-weight: 600; }
.cs-diag-warn  { color: #b66f0e; font-weight: 600; }
.cs-diag-ko    { color: #c62828; font-weight: 600; }

.cs-traffic-action {
    background: rgba(var(--cs-accent-rgb), 0.06);
    border: 1px solid rgba(var(--cs-accent-rgb), 0.2);
    border-radius: 8px;
    padding: 12px 14px;
}

.cs-traffic-info {
    list-style: none;
    padding: 0;
    margin: 0;
}
.cs-traffic-info li {
    padding: 8px 0;
    border-bottom: 1px solid #f0f0f0;
    font-size: 13px;
    color: #202223;
}
.cs-traffic-info li:last-child { border-bottom: none; }
.cs-traffic-info li i { color: var(--cs-accent); margin-right: 6px; width: 18px; display: inline-block; text-align: center; }

.cs-info-panel {
    background: rgba(var(--cs-accent-rgb), 0.04);
    border: 1px solid rgba(var(--cs-accent-rgb), 0.2);
}
.cs-perso-steps {
    margin: 4px 0 0;
    padding-left: 22px;
    line-height: 1.8;
    font-size: 13px;
    color: #202223;
}
.cs-perso-steps li { padding: 2px 0; }
.cs-perso-steps i { color: var(--cs-accent); margin: 0 2px; }
.cs-perso-steps code {
    background: #fff;
    border: 1px solid #c9cccf;
    border-radius: 4px;
    padding: 1px 6px;
    font-size: 11px;
}
.cs-perso-reset {
    margin-top: 16px;
    padding-top: 14px;
    border-top: 1px solid rgba(var(--cs-accent-rgb), 0.15);
}

.cs-panel-desc {
    font-size: 13px;
    color: #6d7175;
    margin: -8px 0 16px;
}

.cs-pdf-sections-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 8px 14px;
}
.cs-pdf-section-toggle {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 10px;
    background: #f8f9fc;
    border: 1px solid #e3e6ec;
    border-radius: 6px;
    cursor: pointer;
    font-size: 13px;
    color: #1a1f2c;
    transition: border-color .15s ease, background .15s ease;
    margin: 0;
}
.cs-pdf-section-toggle:hover { border-color: #041233; background: #f1f3f9; }
.cs-pdf-section-toggle input { margin: 0; accent-color: #041233; }

.cs-form-row {
    display: flex;
    align-items: flex-start;
    margin-bottom: 16px;
    gap: 16px;
}
.cs-form-row:last-child { margin-bottom: 0; }
.cs-form-label {
    flex: 0 0 240px;
    font-size: 13px;
    font-weight: 500;
    color: #202223;
    padding-top: 8px;
}
.cs-form-label small {
    display: block;
    font-weight: 400;
    color: #6d7175;
    margin-top: 3px;
    font-size: 12px;
}
.cs-form-field { flex: 1; min-width: 0; }

.cs-input, .cs-select {
    width: 100%;
    max-width: 400px;
    padding: 8px 12px;
    border: 1px solid #c9cccf;
    border-radius: 6px;
    font-size: 14px;
    color: #202223;
    background: #fff;
    transition: border-color 0.2s, box-shadow 0.2s;
}
.cs-input:focus, .cs-select:focus {
    outline: none;
    border-color: var(--cs-accent);
    box-shadow: 0 0 0 2px rgba(var(--cs-accent-rgb),0.15);
}
.cs-input-sm { max-width: 120px; }
.cs-select-multi { min-height: 140px; max-width: 480px; }
.cs-select-multi option { padding: 4px 8px; }

/* Reset générique (reste à enlever si plus utilisé) */
.cs-accent-reset {
    padding: 6px 10px;
    background: #f1f3f9;
    border: 1px solid #c9cccf;
    border-radius: 6px;
    cursor: pointer;
    color: #6d7175;
}
.cs-accent-reset:hover { background: #e3e6ec; color: #041233; }

.cs-multishop-banner {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-size: 13px;
    line-height: 1.5;
}
.cs-multishop-banner i { font-size: 18px; flex-shrink: 0; margin-top: 2px; }
.cs-multishop-banner small { color: #555; }
.cs-multishop-banner-info { background: #e8f0fe; border: 1px solid #c5dafa; color: #1a3d6e; }
.cs-multishop-banner-info i { color: #1a73e8; }
.cs-multishop-banner-warn { background: #fff4e1; border: 1px solid #ffd9a3; color: #7a4d04; }
.cs-multishop-banner-warn i { color: #d97706; }

/* Sélecteur de thème visuel — cards avec mini-mockup représentatif */
.cs-theme-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 12px;
}
.cs-theme-card {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 0;
    background: #fff;
    border: 2px solid #e3e6ec;
    border-radius: 10px;
    cursor: pointer;
    transition: border-color .15s ease, transform .15s ease, box-shadow .15s ease;
    margin: 0;
    overflow: hidden;
}
.cs-theme-card input[type="radio"] { display: none; }
.cs-theme-card:hover { border-color: #041233; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,.08); }
.cs-theme-card.cs-active { border-color: #041233; box-shadow: 0 0 0 3px rgba(4, 18, 51, .25); }
.cs-theme-info { padding: 8px 12px 12px; }
.cs-theme-info strong { display: block; font-size: 13px; color: #041233; font-weight: 700; }
.cs-theme-info small { display: block; font-size: 11.5px; color: #6d7175; margin-top: 2px; line-height: 1.4; }

/* Mini-mockup générique */
.cs-theme-mockup {
    height: 120px;
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    border-bottom: 1px solid #e3e6ec;
}
.cs-mock-header { display: flex; align-items: center; gap: 6px; height: 14px; }
.cs-mock-logo { width: 14px; height: 14px; border-radius: 3px; background: currentColor; opacity: .85; }
.cs-mock-title { flex: 1; height: 6px; border-radius: 2px; background: currentColor; opacity: .4; max-width: 60px; }
.cs-mock-kpis { display: grid; grid-template-columns: repeat(3, 1fr); gap: 4px; height: 28px; }
.cs-mock-kpi { border-radius: 4px; background: currentColor; opacity: .12; }
.cs-mock-kpi-1 { opacity: .25; }
.cs-mock-chart { display: flex; gap: 3px; align-items: flex-end; height: 36px; padding-top: 4px; }
.cs-mock-chart span { flex: 1; background: currentColor; opacity: .6; border-radius: 2px 2px 0 0; }

/* Thème: Default (Sapphire) */
.cs-mockup-default { background: #f0f2f5; color: #2563EB; }
.cs-mockup-default .cs-mock-kpi-2 { background: #10b981; opacity: .25; }
.cs-mockup-default .cs-mock-kpi-3 { background: #0EA5E9; opacity: .25; }

/* Thème: Cozy (papier pêche + coral) */
.cs-mockup-cozy { background: #fbf4ec; color: #d96a5a; }
.cs-mockup-cozy .cs-mock-kpi { box-shadow: 0 2px 4px rgba(74,57,40,.06); }
.cs-mockup-cozy .cs-mock-kpi-2 { background: #5f8a6e; opacity: .25; }
.cs-mockup-cozy .cs-mock-kpi-3 { background: #6d9bc3; opacity: .25; }
.cs-mockup-cozy .cs-mock-chart span { background: #d96a5a; }

/* Thème: Aurora (glass + dégradé violet/cyan/pink) */
.cs-mockup-aurora {
    background: linear-gradient(135deg, #0a0e1f 0%, #1a1245 60%, #0f2d3f 100%);
    color: #c4b5fd;
    position: relative;
    overflow: hidden;
}
.cs-mockup-aurora::before {
    content: '';
    position: absolute;
    inset: -30px;
    background:
        radial-gradient(circle at 20% 30%, rgba(124,92,255,0.55), transparent 40%),
        radial-gradient(circle at 80% 70%, rgba(58,217,255,0.45), transparent 40%),
        radial-gradient(circle at 50% 50%, rgba(255,110,196,0.25), transparent 50%);
    filter: blur(8px);
    z-index: 0;
}
.cs-mockup-aurora > * { position: relative; z-index: 1; }
.cs-mockup-aurora .cs-mock-kpi { background: rgba(255,255,255,0.1); opacity: 1; border-top: 1px solid rgba(255,255,255,0.18); }
.cs-mockup-aurora .cs-mock-chart span { background: linear-gradient(180deg, #ff6ec4, #7c5cff); opacity: 1; }

/* Thème: Editorial (papier crème + sérif rouge + filets) */
.cs-mockup-editorial { background: #f5f0e6; color: #a8341e; padding-top: 6px; }
.cs-mockup-editorial .cs-mock-header { border-bottom: 2px double #1a1612; padding-bottom: 4px; height: auto; }
.cs-mockup-editorial .cs-mock-title { background: #1a1612; opacity: .7; height: 8px; max-width: 80px; }
.cs-mockup-editorial .cs-mock-logo { display: none; }
.cs-mockup-editorial .cs-mock-kpi { border-radius: 0; background: transparent; border: 1px solid #c9bfa8; opacity: 1; }
.cs-mockup-editorial .cs-mock-kpi-1 { background: #1a4d2e; opacity: .15; border-color: #1a4d2e; }
.cs-mockup-editorial .cs-mock-chart span { background: #a8341e; border-radius: 0; }

/* Thème: Brutalist (jaune/cobalt/rose + hard shadow) */
.cs-mockup-brutalist { background: #f3eed8; color: #0d0d0d; padding: 8px; }
.cs-mockup-brutalist .cs-mock-header { gap: 8px; }
.cs-mockup-brutalist .cs-mock-logo { background: #ffd23f; border: 1.5px solid #0d0d0d; border-radius: 0; }
.cs-mockup-brutalist .cs-mock-title { background: #0d0d0d; opacity: .8; max-width: 70px; height: 8px; }
.cs-mockup-brutalist .cs-mock-kpi { border: 1.5px solid #0d0d0d; border-radius: 0; opacity: 1; box-shadow: 2px 2px 0 0 #0d0d0d; }
.cs-mockup-brutalist .cs-mock-kpi-1 { background: #ffd23f; }
.cs-mockup-brutalist .cs-mock-kpi-2 { background: #fff; }
.cs-mockup-brutalist .cs-mock-kpi-3 { background: #ff5fa2; }
.cs-mockup-brutalist .cs-mock-chart span { background: #2a5cff; border-radius: 0; opacity: 1; }

/* Thème: Terminal (phosphor sur near-black + monospace) */
.cs-mockup-terminal { background: #0a0d0a; color: #a8ff60; font-family: monospace; }
.cs-mockup-terminal .cs-mock-logo { background: transparent; border: 1px solid #a8ff60; opacity: 1; }
.cs-mockup-terminal .cs-mock-title { background: #a8ff60; opacity: .5; }
.cs-mockup-terminal .cs-mock-kpi { background: transparent; border: 1px dashed #1f2a1f; border-radius: 0; opacity: 1; }
.cs-mockup-terminal .cs-mock-kpi-2 { border-color: #a8ff60; }
.cs-mockup-terminal .cs-mock-chart span { background: #a8ff60; opacity: .85; border-radius: 0; }

.cs-ga4-setup-guide {
    background: #f8f9fc;
    border: 1px solid #e3e6ec;
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 16px;
    font-size: 13px;
    color: #202223;
}
.cs-ga4-setup-guide ol { margin: 0; }
.cs-ga4-setup-guide a { color: #041233; text-decoration: underline; }

.cs-btn {
    padding: 10px 20px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.cs-btn-primary { background: #041233; color: #fff; }
.cs-btn-primary:hover { background: #1a2e52; }
.cs-btn-save {
    background: #041233;
    color: #fff;
    padding: 12px 32px;
    font-size: 15px;
    border-radius: 8px;
    margin-top: 8px;
}
.cs-btn-save:hover { background: #1a2e52; }
.cs-btn-light { background: #fff; color: #202223; border: 1px solid #c9cccf; }
.cs-btn-light:hover { background: #f5f5f7; }

/* ── Matrice des états ── */
.cs-states-panel { padding: 18px 22px; }
.cs-states-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-bottom: 14px; }
.cs-states-actions { display: flex; gap: 8px; flex-shrink: 0; }
.cs-states-summary { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 14px; }
.cs-stat {
    background: #f7f8fb;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    padding: 10px 14px;
}
.cs-stat strong { display: block; font-size: 22px; font-weight: 600; line-height: 1.1; color: #202223; }
.cs-stat span { font-size: 12px; color: #6d7175; }
.cs-stat-warn { background: rgba(212, 162, 23, 0.12); border-color: rgba(212, 162, 23, 0.3); }
.cs-stat-warn strong { color: #b66f0e; }

.cs-states-search { margin-bottom: 12px; }
.cs-states-search input { max-width: none; }

.cs-states-matrix {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 10px;
    overflow: hidden;
}
.cs-states-row {
    display: grid;
    grid-template-columns: 1fr 100px 100px 100px 100px;
    align-items: center;
    padding: 11px 16px;
    border-top: 1px solid #e5e7eb;
}
.cs-states-row:first-child { border-top: none; }
.cs-states-head-row {
    background: #f7f8fb;
    font-size: 11px;
    color: #6d7175;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    padding: 10px 16px;
}
.cs-states-head-row > div { text-align: center; }
.cs-states-head-row > div:first-child { text-align: left; }
.cs-states-row:not(.cs-states-head-row):hover { background: rgba(var(--cs-accent-rgb), 0.025); }
.cs-state-cell { display: flex; align-items: center; gap: 10px; min-width: 0; }
.cs-dot { width: 10px; height: 10px; border-radius: 3px; flex-shrink: 0; }
.cs-state-id { color: #9ca3af; font-size: 12px; min-width: 28px; font-variant-numeric: tabular-nums; }
.cs-state-name { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex-grow: 1; }
.cs-state-count { font-size: 12px; color: #9ca3af; padding-right: 8px; font-variant-numeric: tabular-nums; }

.cs-cell-col { display: flex; justify-content: center; }
.cs-toggle-cell {
    width: 30px; height: 30px;
    border-radius: 7px;
    border: 1.5px solid #e5e7eb;
    background: #fff;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0;
    transition: all 0.12s;
}
.cs-toggle-cell i { font-size: 14px; color: transparent; }
.cs-toggle-cell:hover { border-color: #7C3AED; background: rgba(124, 58, 237, 0.08); }
.cs-toggle-cell.cs-on { background: #7C3AED; border-color: #7C3AED; }
.cs-toggle-cell.cs-on i { color: #fff; }
.cs-toggle-cell.cs-conflict { border-color: #d4a217; background: rgba(212, 162, 23, 0.12); }
.cs-toggle-cell.cs-conflict i { color: #d4a217; }

.cs-states-legend {
    margin-top: 14px;
    padding: 11px 14px;
    background: #f7f8fb;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    font-size: 12px;
    color: #6d7175;
    line-height: 1.55;
}
.cs-states-legend strong { color: #202223; font-weight: 600; }

/* ── Toggle switch (booléens) ── */
.cs-switch { position: relative; width: 44px; height: 24px; display: inline-block; vertical-align: middle; }
.cs-switch input { opacity: 0; width: 0; height: 0; }
.cs-switch-slider {
    position: absolute; inset: 0;
    background: #c9cccf;
    border-radius: 24px;
    cursor: pointer;
    transition: 0.2s;
}
.cs-switch-slider:before {
    content: '';
    position: absolute;
    width: 18px; height: 18px;
    left: 3px; bottom: 3px;
    background: #fff;
    border-radius: 50%;
    transition: 0.2s;
}
.cs-switch input:checked + .cs-switch-slider { background: #041233; }
.cs-switch input:checked + .cs-switch-slider:before { transform: translateX(20px); }

/* Form row spécial booléen : switch à gauche */
.cs-form-row--switch {
    display: grid;
    grid-template-columns: auto 1fr;
    grid-template-areas: "switch label" "switch desc";
    column-gap: 14px;
    row-gap: 4px;
    align-items: start;
    padding: 14px 0;
    margin-bottom: 0;
}
.cs-form-row--switch + .cs-form-row--switch { border-top: 1px solid #e3e5e7; }
.cs-form-row--switch .cs-form-label { grid-area: label; flex: none; padding: 0; font-weight: 600; }
.cs-form-row--switch .cs-form-field { grid-area: switch; flex: none; align-self: center; }
.cs-form-row--switch .cs-form-desc { grid-area: desc; font-size: 12px; color: #6d7175; line-height: 1.4; }

</style>

<link rel="stylesheet" href="{$cs_module_path}views/css/zm40-common.css">

<div class="coolstats-admin">

    {* === HEADER === *}
    <div class="cs-config-header">
        <div class="cs-config-brand">
            <img src="{$cs_module_path}views/img/logos/logo-default-64.png" alt="CoolStats" class="cs-logo">
            <div>
                <h2>CoolStats</h2>
                <div class="cs-config-version">Dashboard de statistiques v{$cs_module_version}</div>
            </div>
        </div>
        <span class="cs-config-shop">{$cs_shop_name}</span>
    </div>

    {* === META : mode détecté + accès dashboard === *}
    <div class="cs-config-meta">
        <a href="{$cs_dashboard_link}" target="_blank" class="cs-config-link"><i class="icon-external-link"></i> Ouvrir le Dashboard</a>
        {if $cs_mkp_modules|@count}
            <span class="cs-config-mode cs-config-mode--mkp" title="Vente directe + canaux marketplaces">Mode multi-canal</span>
        {else}
            <span class="cs-config-mode cs-config-mode--direct">Vente directe uniquement</span>
        {/if}
        <span>PS {$cs_ps_version}</span>
    </div>

    {* === ZM40 : notice de mise à jour (actionnable, en haut) === *}
    {include file="module:coolstats/views/templates/admin/_partials/zm40_update.tpl"}

    {* === MESSAGES === *}
    {if $cs_confirmation}<div class="alert alert-success">{$cs_confirmation}</div>{/if}

    {* === TABS === *}
    <div class="cs-tabs">
        <button type="button" class="cs-tab active" data-tab="behavior"><i class="icon-cogs"></i> Comportement</button>
        <button type="button" class="cs-tab" data-tab="appearance"><i class="icon-paint-brush"></i> Apparence</button>
        <button type="button" class="cs-tab" data-tab="states"><i class="icon-list-ul"></i> États de commande</button>
        <button type="button" class="cs-tab" data-tab="traffic"><i class="icon-bar-chart"></i> Trafic & visiteurs</button>
        <button type="button" class="cs-tab" data-tab="advanced"><i class="icon-wrench"></i> Avancé</button>
        {if isset($zm40_modules) && $zm40_modules|@count}<button type="button" class="cs-tab" data-tab="modules"><i class="icon-th-large"></i> Modules ZM40</button>{/if}
    </div>

    <form method="post" action="{$cs_form_action}">
        <input type="hidden" name="submitCoolStatsConfig" value="1">

        {* === ONGLET ÉTATS === *}
        <div class="cs-tab-content" data-tab-content="states">
            <div class="cs-panel cs-states-panel">
                <div class="cs-states-head">
                    <div>
                        <h3 class="cs-panel-title" style="border:none;padding:0;margin:0">Mapping des états de commande</h3>
                        <p class="cs-panel-desc" style="margin:4px 0 0">{$cs_states_meta|@count} états Prestashop détectés. Cochez chaque colonne où l'état doit être pris en compte.</p>
                    </div>
                    <div class="cs-states-actions">
                        <button type="button" class="cs-btn cs-btn-light" id="cs-states-reset"><i class="icon-refresh"></i> Réinitialiser</button>
                        <button type="button" class="cs-btn cs-btn-primary" id="cs-states-auto"><i class="icon-magic"></i> Config auto Prestashop</button>
                    </div>
                </div>

                <div class="cs-states-summary">
                    <div class="cs-stat"><strong id="cs-states-mapped">0</strong><span>états mappés</span></div>
                    <div class="cs-stat"><strong id="cs-states-ignored">0</strong><span>états ignorés</span></div>
                    <div class="cs-stat cs-stat-warn"><strong id="cs-states-conflicts">0</strong><span>conflits potentiels</span></div>
                </div>

                <div class="cs-states-search">
                    <input type="text" id="cs-states-search" class="cs-input" placeholder="Rechercher un état (ID ou nom)…">
                </div>

                <div class="cs-states-matrix">
                    <div class="cs-states-row cs-states-head-row">
                        <div>État Prestashop</div>
                        <div class="cs-cell-col">Validé / CA</div>
                        <div class="cs-cell-col">Annulé</div>
                        <div class="cs-cell-col">Expédié</div>
                        <div class="cs-cell-col">Livré</div>
                    </div>
                    {foreach from=$cs_states_meta item=s}
                    <div class="cs-states-row" data-state-id="{$s.id_state}" data-search="{$s.id_state} {$s.name|lower|escape:'html':'UTF-8'}">
                        <div class="cs-state-cell">
                            <span class="cs-dot" style="background:{$s.color}"></span>
                            <span class="cs-state-id">#{$s.id_state}</span>
                            <span class="cs-state-name">{$s.name|escape:'html':'UTF-8'}</span>
                            <span class="cs-state-count">{$s.count}</span>
                        </div>
                        {foreach from=['VALID','CANCELLED','SHIPPED','DELIVERED'] item=cat}
                        <div class="cs-cell-col">
                            <button type="button" class="cs-toggle-cell{if in_array($s.id_state, $cs_states_selected[$cat])} cs-on{/if}"
                                    data-cat="{$cat}" data-state="{$s.id_state}">
                                <i class="icon-check"></i>
                            </button>
                            <input type="checkbox" name="COOLSTATS_{$cat}_STATES[]" value="{$s.id_state}"
                                   {if in_array($s.id_state, $cs_states_selected[$cat])}checked{/if}
                                   style="display:none" class="cs-state-checkbox" data-cat="{$cat}" data-state="{$s.id_state}">
                        </div>
                        {/foreach}
                    </div>
                    {/foreach}
                </div>

                <div class="cs-states-legend">
                    <strong>Validé / CA</strong> : prises en compte dans le CA et les KPI · <strong>Annulé</strong> : exclues · <strong>Expédié</strong> : marchandise sortie · <strong>Livré</strong> : reçue par le client. Un état peut appartenir à plusieurs catégories.
                </div>
            </div>
        </div>

        {* === ONGLET TRAFIC === *}
        <div class="cs-tab-content" data-tab-content="traffic">
            <div class="cs-panel">
                <h3 class="cs-panel-title">Source des données de trafic</h3>
                <p class="cs-panel-desc">CoolStats n'affiche les statistiques de trafic que si vous connectez une <strong>source fiable</strong>. Par défaut, la section trafic du dashboard reste vide — c'est volontaire : nous préférons ne rien montrer plutôt que des chiffres trompeurs.</p>

                <div class="cs-form-row">
                    <div class="cs-form-label">Fournisseur actif</div>
                    <div class="cs-form-field">
                        <select name="COOLSTATS_TRAFFIC_PROVIDER" class="cs-select cs-input-sm" id="cs-traffic-provider-select" style="max-width:320px">
                            {assign var=tp value=$cs_config.COOLSTATS_TRAFFIC_PROVIDER|default:'none'}
                            <option value="none"      {if $tp == 'none' || $tp == ''}selected{/if}>— Aucun (section masquée)</option>
                            <option value="matomo"    {if $tp == 'matomo'}selected{/if}>Matomo (recommandé)</option>
                            <option value="ga4"       {if $tp == 'ga4'}selected{/if}>Google Analytics 4</option>
                            <option value="native_ps" {if $tp == 'native_ps'}selected{/if}>PrestaShop natif (statsdata) — non recommandé</option>
                            <option value="plausible" disabled>Plausible (bientôt)</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="cs-panel" id="cs-matomo-config" {if $tp != 'matomo'}style="display:none"{/if}>
                <h3 class="cs-panel-title">Configuration Matomo</h3>
                <p class="cs-panel-desc">Connectez votre instance Matomo via son API Reporting. Le token doit avoir au minimum les droits "View" sur le site sélectionné.</p>

                {if $cs_multishop_ctx.is_multishop}
                    {if $cs_multishop_ctx.warn_all}
                    <div class="cs-multishop-banner cs-multishop-banner-warn">
                        <i class="icon-exclamation-triangle"></i>
                        <div>
                            <strong>Contexte : {$cs_multishop_ctx.label|escape:'html'}</strong><br>
                            <small>Les valeurs ci-dessous seront appliquées <strong>globalement à toutes les boutiques</strong>. Pour configurer Matomo par boutique avec un site ID différent, sélectionnez une boutique précise dans le sélecteur en haut.</small>
                        </div>
                    </div>
                    {else}
                    <div class="cs-multishop-banner cs-multishop-banner-info">
                        <i class="icon-info-sign"></i>
                        <div>Configuration pour la boutique : <strong>{$cs_multishop_ctx.label|escape:'html'}</strong>. Chaque boutique peut avoir son propre URL/token/site ID Matomo.</div>
                    </div>
                    {/if}
                {/if}
                <div class="cs-form-row">
                    <div class="cs-form-label">URL Matomo<small>Sans slash final, ex: https://analytics.example.com</small></div>
                    <div class="cs-form-field">
                        <input type="url" name="COOLSTATS_MATOMO_URL" value="{$cs_config.COOLSTATS_MATOMO_URL|escape:'html'}" class="cs-input" placeholder="https://analytics.example.com" style="max-width:420px">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Token d'authentification<small>Créé dans Matomo → Préférences personnelles → Tokens de sécurité</small></div>
                    <div class="cs-form-field">
                        <input type="password" name="COOLSTATS_MATOMO_TOKEN" value="{$cs_config.COOLSTATS_MATOMO_TOKEN|escape:'html'}" class="cs-input" autocomplete="off" style="max-width:420px;font-family:monospace">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">ID du site<small>Visible dans Matomo → Administration → Sites</small></div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_MATOMO_SITE_ID" value="{$cs_config.COOLSTATS_MATOMO_SITE_ID|escape:'html'}" class="cs-input cs-input-sm">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Test connexion</div>
                    <div class="cs-form-field">
                        <button type="button" class="cs-btn cs-btn-light" id="cs-matomo-test"><i class="icon-link"></i> Tester la connexion</button>
                        <div id="cs-matomo-test-result" class="small mt-2"></div>
                    </div>
                </div>
            </div>

            <div class="cs-panel" id="cs-ga4-config" {if $tp != 'ga4'}style="display:none"{/if}>
                <h3 class="cs-panel-title">Configuration Google Analytics 4</h3>
                <p class="cs-panel-desc">Connectez votre propriété GA4 via un compte de service Google. Pas de redirection OAuth, pas de refresh token à gérer — robuste et idéal multi-boutiques.</p>

                {if $cs_multishop_ctx.is_multishop}
                    {if $cs_multishop_ctx.warn_all}
                    <div class="cs-multishop-banner cs-multishop-banner-warn">
                        <i class="icon-exclamation-triangle"></i>
                        <div><strong>Contexte : {$cs_multishop_ctx.label|escape:'html'}</strong><br>
                            <small>Sélectionnez une boutique précise dans le sélecteur en haut pour granuler par propriété GA4.</small>
                        </div>
                    </div>
                    {else}
                    <div class="cs-multishop-banner cs-multishop-banner-info">
                        <i class="icon-info-sign"></i>
                        <div>Configuration pour la boutique : <strong>{$cs_multishop_ctx.label|escape:'html'}</strong>.</div>
                    </div>
                    {/if}
                {/if}

                <div class="cs-ga4-setup-guide">
                    <strong><i class="icon-info-sign"></i> Setup à faire une fois côté Google Cloud :</strong>
                    <ol class="small mb-0 mt-2" style="padding-left:20px">
                        <li>Ouvre <a href="https://console.cloud.google.com" target="_blank" rel="noopener">console.cloud.google.com</a> et crée (ou choisis) un projet</li>
                        <li>Active l'API <strong>Google Analytics Data API</strong> (menu APIs & Services → Library)</li>
                        <li>Crée un <strong>Service Account</strong> (IAM &amp; Admin → Service Accounts → Create)</li>
                        <li>Sur ce service account → onglet <strong>Keys</strong> → <strong>Add Key</strong> → JSON → télécharge le fichier</li>
                        <li>Dans GA4 (<a href="https://analytics.google.com" target="_blank" rel="noopener">analytics.google.com</a>) → Admin → <strong>Property access management</strong> → ajoute l'email du service account avec le rôle <strong>Viewer</strong></li>
                        <li>Copie l'<strong>ID de la propriété</strong> GA4 (Admin → Property → Property details, le nombre sous "PROPERTY ID")</li>
                    </ol>
                </div>

                <div class="cs-form-row">
                    <div class="cs-form-label">ID de la propriété GA4<small>Sans "properties/" — uniquement le nombre, ex: 123456789</small></div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_GA4_PROPERTY_ID" value="{$cs_config.COOLSTATS_GA4_PROPERTY_ID|escape:'html'}" class="cs-input" placeholder="123456789">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Clé Service Account (JSON)<small>Contenu complet du fichier .json téléchargé</small></div>
                    <div class="cs-form-field">
                        <textarea name="COOLSTATS_GA4_SERVICE_ACCOUNT_JSON" id="cs-ga4-sa-json" class="cs-input" rows="6" style="font-family:monospace;font-size:11px;white-space:pre" placeholder='{ldelim}"type":"service_account","client_email":"...","private_key":"..."{rdelim}'>{$cs_config.COOLSTATS_GA4_SERVICE_ACCOUNT_JSON|escape:'html'}</textarea>
                        <small class="text-muted">Le JSON est stocké en base — pensez aux droits d'accès admin. La clé privée ne quitte pas ton serveur.</small>
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Test connexion</div>
                    <div class="cs-form-field">
                        <button type="button" class="cs-btn cs-btn-light" id="cs-ga4-test"><i class="icon-link"></i> Tester la connexion</button>
                        <div id="cs-ga4-test-result" class="small mt-2"></div>
                    </div>
                </div>
            </div>

            <div class="cs-panel" id="cs-native-warning" {if $tp != 'native_ps'}style="display:none"{/if}>
                <h3 class="cs-panel-title">⚠️ Limitations du tracking natif PrestaShop</h3>
                <ul class="small mb-0" style="padding-left:18px">
                    <li>Champ <code>mobile_theme</code> déprécié depuis PS 1.7 → détection mobile/desktop cassée</li>
                    <li>Table <code>ps_operating_system</code> obsolète (pas d'iOS moderne, peu d'OS reconnus)</li>
                    <li>Aucun filtrage des bots/crawlers → sessions gonflées artificiellement</li>
                    <li>Pages vues souvent vides (table <code>connections_page</code> peu fiable)</li>
                </ul>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">État technique (diagnostic)</h3>
                <p class="cs-panel-desc">Pour information uniquement — peut servir à un dev pour comprendre l'état de la base.</p>
                <div class="cs-traffic-diag">
                    <div class="cs-traffic-diag-row">
                        <span>Module <code>statsdata</code></span>
                        {if $cs_traffic_status.statsdata_active}
                            <span class="cs-diag-ok"><i class="icon-check"></i> Installé et actif</span>
                        {elseif $cs_traffic_status.statsdata_installed}
                            <span class="cs-diag-warn"><i class="icon-exclamation-triangle"></i> Installé mais inactif</span>
                        {else}
                            <span class="cs-diag-ko"><i class="icon-times"></i> Non installé</span>
                        {/if}
                    </div>
                    <div class="cs-traffic-diag-row">
                        <span>Sessions enregistrées en base</span>
                        <span><strong>{$cs_traffic_status.total_sessions|number_format:0:',':' '}</strong></span>
                    </div>
                    {if $cs_traffic_status.last_session_at}
                    <div class="cs-traffic-diag-row">
                        <span>Dernière session</span>
                        <span class="text-muted small">{$cs_traffic_status.last_session_at}</span>
                    </div>
                    {/if}
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">À propos du tracking</h3>
                <ul class="cs-traffic-info">
                    <li><i class="icon-shield"></i> <strong>Aucun tracking custom</strong> — CoolStats ne pose aucun cookie ni script de tracking sur votre boutique.</li>
                    <li><i class="icon-bolt"></i> <strong>Aucun impact sur la performance front</strong> — pas de JS supplémentaire, pas de requête bloquante.</li>
                    <li><i class="icon-check-circle"></i> <strong>Pas de doublon RGPD</strong> — vous gardez votre solution analytics existante (Matomo, GA4, Plausible…) sans interférence.</li>
                    <li><i class="icon-arrow-right"></i> <strong>V2 prévue</strong> — connecteurs Matomo / Plausible / GA4 pour des données fiables avec filtrage bots, détection device, etc.</li>
                </ul>
            </div>
        </div>

        {* === ONGLET APPARENCE === *}
        <div class="cs-tab-content" data-tab-content="appearance">
            <div class="cs-panel cs-info-panel">
                <h3 class="cs-panel-title"><i class="icon-info-sign"></i> Personnaliser votre dashboard</h3>
                <p class="cs-panel-desc">Le dashboard CoolStats est <strong>personnalisable par chaque administrateur</strong> — vos préférences sont stockées séparément (un comptable et un dirigeant peuvent avoir leur propre vue).</p>
                <ol class="cs-perso-steps">
                    <li>Ouvrez le dashboard puis cliquez sur l'icône <i class="icon-sliders"></i> <strong>Personnaliser</strong> dans le header.</li>
                    <li><strong>Cochez / décochez</strong> les sections que vous voulez afficher ou masquer.</li>
                    <li><strong>Glissez les sections</strong> via la poignée <i class="icon-reorder"></i> pour les réordonner.</li>
                    <li>Les changements sont <strong>sauvegardés automatiquement</strong> (pas de bouton "Enregistrer").</li>
                    <li>Cliquez sur <strong>Terminer</strong> ou pressez <code>Esc</code> pour quitter le mode édition.</li>
                </ol>
                <div class="cs-perso-reset">
                    <button type="button" class="cs-btn cs-btn-light" id="cs-reset-prefs-btn"><i class="icon-refresh"></i> Réinitialiser mes préférences</button>
                    <span class="text-muted small ms-2">Repart de la configuration par défaut (sections visibles + ordre).</span>
                    <div id="cs-reset-prefs-msg" class="text-muted small mt-2" style="display:none"></div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Branding</h3>
                <div class="cs-form-row">
                    <div class="cs-form-label">Nom de marque<small>Affiché dans le header du dashboard</small></div>
                    <div class="cs-form-field">
                        <input type="text" name="COOLSTATS_BRAND_NAME" value="{$cs_config.COOLSTATS_BRAND_NAME|escape:'html'}" class="cs-input">
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Style visuel</h3>
                <p class="cs-panel-desc">Chaque thème définit son ambiance complète (palette, typo, ombres) et son mode natif (dark ou light). L'utilisateur peut ensuite basculer dark/light depuis le dashboard, sa préférence est mémorisée par thème.</p>
                <div class="cs-theme-grid">
                    {assign var=vt value=$cs_config.COOLSTATS_VISUAL_THEME|default:'default'}
                    {foreach from=[
                        ['id'=>'aurora',   'name'=>'Aurora glass',  'desc'=>'Sobre + glass cards, le défaut moderne'],
                        ['id'=>'cozy',     'name'=>'Cozy',          'desc'=>'Clair, chaleureux, friendly SaaS'],
                        ['id'=>'editorial','name'=>'Editorial',     'desc'=>'Sérif, mode rapport trimestriel'],
                        ['id'=>'brutalist','name'=>'Neo-brutalist', 'desc'=>'Blocs, ombres dures, fun'],
                        ['id'=>'terminal', 'name'=>'Terminal',      'desc'=>'Mono, dense, mode pro/trader']
                    ] item=th}
                        <label class="cs-theme-card{if $vt == $th.id} cs-active{/if}">
                            <input type="radio" name="COOLSTATS_VISUAL_THEME" value="{$th.id|escape:'html'}" {if $vt == $th.id}checked{/if}>
                            <div class="cs-theme-mockup cs-mockup-{$th.id|escape:'html'}">
                                <div class="cs-mock-header"><div class="cs-mock-logo"></div><div class="cs-mock-title"></div></div>
                                <div class="cs-mock-kpis">
                                    <div class="cs-mock-kpi cs-mock-kpi-1"></div>
                                    <div class="cs-mock-kpi cs-mock-kpi-2"></div>
                                    <div class="cs-mock-kpi cs-mock-kpi-3"></div>
                                </div>
                                <div class="cs-mock-chart">
                                    <span style="height:30%"></span><span style="height:50%"></span><span style="height:70%"></span><span style="height:45%"></span><span style="height:85%"></span><span style="height:60%"></span><span style="height:75%"></span>
                                </div>
                            </div>
                            <div class="cs-theme-info">
                                <strong>{$th.name}</strong>
                                <small>{$th.desc}</small>
                            </div>
                        </label>
                    {/foreach}
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Export PDF</h3>
                <p class="cs-panel-desc">Sélectionnez les sections à inclure lors de l'export PDF du dashboard. Si aucune n'est cochée, toutes les sections sont exportées.</p>
                <div class="cs-pdf-sections-grid">
                    {foreach from=$cs_all_sections item=s}
                        <label class="cs-pdf-section-toggle">
                            <input type="checkbox" name="COOLSTATS_PDF_SECTIONS[]" value="{$s.id|escape:'html'}"
                                   {if in_array($s.id, $cs_pdf_selected)}checked{/if}>
                            <span>{$s.title|escape:'html'}</span>
                        </label>
                    {/foreach}
                </div>
            </div>
        </div>

        {* === ONGLET COMPORTEMENT === *}
        <div class="cs-tab-content active" data-tab-content="behavior">
            <div class="cs-panel">
                <h3 class="cs-panel-title">Calcul du chiffre d'affaires</h3>

                <div class="cs-form-row cs-form-row--switch">
                    <div class="cs-form-label">Inclure les frais de port dans le CA</div>
                    <div class="cs-form-field">
                        <label class="cs-switch">
                            <input type="hidden" name="COOLSTATS_INCLUDE_SHIPPING_IN_CA" value="0">
                            <input type="checkbox" name="COOLSTATS_INCLUDE_SHIPPING_IN_CA" value="1" {if $cs_config.COOLSTATS_INCLUDE_SHIPPING_IN_CA}checked{/if}>
                            <span class="cs-switch-slider"></span>
                        </label>
                    </div>
                    <div class="cs-form-desc">Si désactivé, le CA des KPI = total payé TTC moins les frais de port. Affecte les indicateurs globaux, la carte des pays et la répartition par paiement (pas le top produits, qui n'inclut jamais le shipping).</div>
                </div>

                <div class="cs-form-row cs-form-row--switch">
                    <div class="cs-form-label">Exclure les commandes à 0€</div>
                    <div class="cs-form-field">
                        <label class="cs-switch">
                            <input type="hidden" name="COOLSTATS_EXCLUDE_FREE_ORDERS" value="0">
                            <input type="checkbox" name="COOLSTATS_EXCLUDE_FREE_ORDERS" value="1" {if $cs_config.COOLSTATS_EXCLUDE_FREE_ORDERS}checked{/if}>
                            <span class="cs-switch-slider"></span>
                        </label>
                    </div>
                    <div class="cs-form-desc">Utile pour exclure les bons cadeaux, échantillons gratuits ou commandes de test. Les commandes à 0€ ne sont alors pas comptées dans les KPI valides.</div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Affichage & comparaison</h3>
                <div class="cs-form-row">
                    <div class="cs-form-label">Comparaison par défaut</div>
                    <div class="cs-form-field">
                        <select name="COOLSTATS_COMPARE_DEFAULT" class="cs-select cs-input-sm">
                            <option value="prev" {if $cs_config.COOLSTATS_COMPARE_DEFAULT == 'prev'}selected{/if}>Période précédente</option>
                            <option value="yoy"  {if $cs_config.COOLSTATS_COMPARE_DEFAULT == 'yoy'}selected{/if}>N-1 année</option>
                            <option value="none" {if $cs_config.COOLSTATS_COMPARE_DEFAULT == 'none'}selected{/if}>Aucune</option>
                        </select>
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Commandes par page</div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_ORDERS_PER_PAGE" value="{$cs_config.COOLSTATS_ORDERS_PER_PAGE|escape:'html'}" class="cs-input cs-input-sm" min="10" max="200">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Séparateur CSV</div>
                    <div class="cs-form-field">
                        <input type="text" name="COOLSTATS_EXPORT_SEPARATOR" value="{$cs_config.COOLSTATS_EXPORT_SEPARATOR|escape:'html'}" class="cs-input cs-input-sm" maxlength="3">
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Objectifs mensuels</h3>
                <p class="cs-panel-desc">Affiche une section avec barres de progression sur le dashboard. Laisser à 0 pour désactiver.</p>
                <div class="cs-form-row">
                    <div class="cs-form-label">CA cible mensuel <small>(devise boutique)</small></div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_GOAL_REVENUE" value="{$cs_config.COOLSTATS_GOAL_REVENUE|escape:'html'}" class="cs-input cs-input-sm" min="0" step="100">
                    </div>
                </div>
                <div class="cs-form-row">
                    <div class="cs-form-label">Commandes cibles mensuelles</div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_GOAL_ORDERS" value="{$cs_config.COOLSTATS_GOAL_ORDERS|escape:'html'}" class="cs-input cs-input-sm" min="0" step="1">
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Segmentation clients</h3>
                <p class="cs-panel-desc">Réservé pour les futurs segments clients (« nouveaux » vs « inactifs »). N'affecte rien pour l'instant.</p>
                <div class="cs-form-row">
                    <div class="cs-form-label">Seuil d'inactivité client <small>en jours</small></div>
                    <div class="cs-form-field">
                        <input type="number" name="COOLSTATS_INACTIVITY_DAYS" value="{$cs_config.COOLSTATS_INACTIVITY_DAYS|escape:'html'}" class="cs-input cs-input-sm" min="1" max="3650">
                    </div>
                </div>
            </div>

        </div>

        {* === ONGLET AVANCÉ === *}
        <div class="cs-tab-content" data-tab-content="advanced">
            <div class="cs-panel">
                <h3 class="cs-panel-title">Auto-refresh du dashboard</h3>
                <p class="cs-panel-desc">Recharge automatiquement les données à intervalle régulier (utile pour les magasins en activité). 0 = désactivé.</p>
                <div class="cs-form-row">
                    <div class="cs-form-label">Intervalle <small>en minutes</small></div>
                    <div class="cs-form-field">
                        <select name="COOLSTATS_AUTO_REFRESH_INTERVAL" class="cs-select cs-input-sm" style="max-width:160px">
                            <option value="0"  {if $cs_config.COOLSTATS_AUTO_REFRESH_INTERVAL == 0}selected{/if}>Désactivé</option>
                            <option value="1"  {if $cs_config.COOLSTATS_AUTO_REFRESH_INTERVAL == 1}selected{/if}>1 minute</option>
                            <option value="5"  {if $cs_config.COOLSTATS_AUTO_REFRESH_INTERVAL == 5}selected{/if}>5 minutes</option>
                            <option value="15" {if $cs_config.COOLSTATS_AUTO_REFRESH_INTERVAL == 15}selected{/if}>15 minutes</option>
                            <option value="30" {if $cs_config.COOLSTATS_AUTO_REFRESH_INTERVAL == 30}selected{/if}>30 minutes</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Export CSV avancé</h3>
                <div class="cs-form-row">
                    <div class="cs-form-label">Encodage</div>
                    <div class="cs-form-field">
                        <select name="COOLSTATS_CSV_ENCODING" class="cs-select cs-input-sm" style="max-width:200px">
                            <option value="utf-8"     {if $cs_config.COOLSTATS_CSV_ENCODING == 'utf-8'}selected{/if}>UTF-8</option>
                            <option value="utf-8-bom" {if $cs_config.COOLSTATS_CSV_ENCODING == 'utf-8-bom'}selected{/if}>UTF-8 avec BOM (Excel)</option>
                            <option value="latin1"    {if $cs_config.COOLSTATS_CSV_ENCODING == 'latin1'}selected{/if}>ISO-8859-1 (legacy)</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Optimisation base de données</h3>
                <p class="cs-panel-desc">Crée un index sur <code>ps_connections.date_add</code> pour accélérer la section trafic. Sur un gros historique de visites, l'opération peut prendre plusieurs minutes — c'est normal, ne ferme pas l'onglet.</p>
                <div class="cs-form-row">
                    <div class="cs-form-label">Index trafic</div>
                    <div class="cs-form-field">
                        <button type="submit" name="submitCoolStatsCreateIndex" value="1" class="cs-btn cs-btn-light">
                            <i class="icon-bolt"></i> Créer/vérifier l'index
                        </button>
                        <span class="text-muted small ms-2">Idempotent : ne fait rien si déjà créé.</span>
                    </div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Mode debug</h3>
                <p class="cs-panel-desc">Active les logs PHP et la console JS verbose. À désactiver en production.</p>
                <div class="cs-form-row cs-form-row--switch">
                    <div class="cs-form-label">Mode debug</div>
                    <div class="cs-form-field">
                        <label class="cs-switch">
                            <input type="hidden" name="COOLSTATS_DEBUG" value="0">
                            <input type="checkbox" name="COOLSTATS_DEBUG" value="1" {if $cs_config.COOLSTATS_DEBUG}checked{/if}>
                            <span class="cs-switch-slider"></span>
                        </label>
                    </div>
                    <div class="cs-form-desc">Activez uniquement pour diagnostiquer un problème. Désactivez après.</div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Mises à jour & autres modules (ZM40)</h3>
                <p class="cs-panel-desc">Vérifie au maximum 1×/jour si une nouvelle version est disponible via l'API publique de GitHub, et affiche les autres modules ZM40 depuis zm40.com. Ces requêtes sont <strong>anonymes</strong> : aucune donnée de votre boutique n'est transmise. Décochez pour tout désactiver.</p>
                <div class="cs-form-row cs-form-row--switch">
                    <div class="cs-form-label">Vérifier les mises à jour</div>
                    <div class="cs-form-field">
                        <label class="cs-switch">
                            <input type="hidden" name="ZM40_NET_ENABLED" value="0">
                            <input type="checkbox" name="ZM40_NET_ENABLED" value="1" {if $zm40_net_enabled}checked{/if}>
                            <span class="cs-switch-slider"></span>
                        </label>
                    </div>
                    <div class="cs-form-desc">Activé par défaut. Si désactivé : aucun appel réseau (le footer d'attribution reste, il n'appelle rien).</div>
                </div>
            </div>

            <div class="cs-panel">
                <h3 class="cs-panel-title">Wizard de configuration</h3>
                <p class="cs-panel-desc">Le wizard de premier lancement guide la configuration initiale (états, profil business, branding). À venir en V2.</p>
                <div class="cs-form-row">
                    <div class="cs-form-label">Refaire le wizard</div>
                    <div class="cs-form-field">
                        <button type="button" class="cs-btn cs-btn-light" disabled title="Disponible en V2"><i class="icon-magic"></i> Lancer le wizard (V2)</button>
                    </div>
                </div>
            </div>
        </div>

        {* === ZM40 : onglet « Modules ZM40 » (écosystème) === *}
        {include file="module:coolstats/views/templates/admin/_partials/zm40_modules_tab.tpl"}

        <div style="text-align:right;">
            <button type="submit" class="cs-btn cs-btn-save"><i class="icon-save"></i> Sauvegarder la configuration</button>
        </div>
    </form>

    {* ── ZM40 Common : notice MAJ + autres modules + footer d'attribution ── *}
    {* === ZM40 : bloc « libre & open source » + autres modules (discret, en bas) === *}
    {include file="module:coolstats/views/templates/admin/_partials/zm40_panel.tpl"}
</div>

<script>
(function () {
    // ── Tabs ──
    var tabs = document.querySelectorAll('.coolstats-admin .cs-tab');
    var panels = document.querySelectorAll('.coolstats-admin .cs-tab-content');
    tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
            tabs.forEach(function (t) { t.classList.remove('active'); });
            panels.forEach(function (p) { p.classList.remove('active'); });
            tab.classList.add('active');
            var key = tab.getAttribute('data-tab');
            var panel = document.querySelector('[data-tab-content="' + key + '"]');
            if (panel) panel.classList.add('active');
        });
    });

    // ── Cards de thème visuel : mise à jour de la classe cs-active au clic ──
    document.querySelectorAll('.cs-theme-card input[type="radio"]').forEach(function (input) {
        input.addEventListener('change', function () {
            document.querySelectorAll('.cs-theme-card').forEach(function (c) {
                c.classList.toggle('cs-active', c.contains(input));
            });
        });
    });

    // ── Provider trafic : toggle panneaux + test connexion Matomo/GA4 ──
    var providerSelect = document.getElementById('cs-traffic-provider-select');
    var matomoPanel = document.getElementById('cs-matomo-config');
    var ga4Panel    = document.getElementById('cs-ga4-config');
    var nativeWarning = document.getElementById('cs-native-warning');
    if (providerSelect) {
        providerSelect.addEventListener('change', function () {
            var v = providerSelect.value;
            if (matomoPanel)   matomoPanel.style.display   = (v === 'matomo')   ? '' : 'none';
            if (ga4Panel)      ga4Panel.style.display      = (v === 'ga4')      ? '' : 'none';
            if (nativeWarning) nativeWarning.style.display = (v === 'native_ps') ? '' : 'none';
        });
    }
    // Test GA4 — utilise la config sauvée en base (le JSON est trop gros pour passer en URL).
    var ga4TestBtn = document.getElementById('cs-ga4-test');
    if (ga4TestBtn) {
        ga4TestBtn.addEventListener('click', function () {
            var resultEl = document.getElementById('cs-ga4-test-result');
            resultEl.innerHTML = '<span class="text-muted"><i class="icon-refresh"></i> Test en cours…</span>';
            ga4TestBtn.disabled = true;
            var url = '{$cs_ajax_link nofilter}&action=testGA4';
            fetch(url, { method: 'GET', credentials: 'same-origin' })
                .then(function (r) { return r.text().then(function (t) { return { status: r.status, body: t }; }); })
                .then(function (res) {
                    ga4TestBtn.disabled = false;
                    var data = null;
                    try { data = JSON.parse(res.body); } catch (e) {}
                    if (data && data.ok) {
                        var detail = data.property_id ? ' (Property ID : ' + data.property_id + ')' : '';
                        resultEl.innerHTML = '<span class="cs-diag-ok"><i class="icon-check"></i> Connexion réussie' + detail + '</span>';
                    } else if (data && data.error) {
                        resultEl.innerHTML = '<span class="text-danger"><i class="icon-times"></i> ' + data.error + '</span>';
                    } else {
                        resultEl.innerHTML = '<span class="text-danger">HTTP ' + res.status + ' — réponse non JSON. F12 console pour détails.</span>';
                        console.error('[CoolStats] GA4 test response:', res);
                    }
                })
                .catch(function (err) {
                    ga4TestBtn.disabled = false;
                    resultEl.innerHTML = '<span class="text-danger">Erreur réseau : ' + (err && err.message ? err.message : 'inconnue') + '</span>';
                });
        });
    }

    var matomoTestBtn = document.getElementById('cs-matomo-test');
    if (matomoTestBtn) {
        matomoTestBtn.addEventListener('click', function () {
            var resultEl = document.getElementById('cs-matomo-test-result');
            var urlInput   = document.querySelector('input[name="COOLSTATS_MATOMO_URL"]');
            var tokenInput = document.querySelector('input[name="COOLSTATS_MATOMO_TOKEN"]');
            var siteInput  = document.querySelector('input[name="COOLSTATS_MATOMO_SITE_ID"]');
            if (!urlInput.value || !tokenInput.value || !siteInput.value) {
                resultEl.innerHTML = '<span class="text-danger">Renseigne URL + token + site ID avant de tester.</span>';
                return;
            }
            resultEl.innerHTML = '<span class="text-muted"><i class="icon-refresh"></i> Test en cours…</span>';
            matomoTestBtn.disabled = true;
            var params = new URLSearchParams({
                action:       'testMatomo',
                matomo_url:   urlInput.value,
                matomo_token: tokenInput.value,
                matomo_site:  siteInput.value
            });
            var url = '{$cs_ajax_link nofilter}&' + params.toString();
            console.log('[CoolStats] Test Matomo URL:', url);
            fetch(url, { method: 'GET', credentials: 'same-origin' })
                .then(function (r) {
                    console.log('[CoolStats] HTTP status:', r.status, r.statusText);
                    return r.text().then(function (txt) {
                        return { status: r.status, body: txt };
                    });
                })
                .then(function (res) {
                    matomoTestBtn.disabled = false;
                    console.log('[CoolStats] Réponse brute:', res);
                    var data = null;
                    try { data = JSON.parse(res.body); } catch (e) {}
                    if (data && data.ok) {
                        var details = data.matomo_version ? ' (Matomo v' + data.matomo_version + (data.site_name ? ', site "' + data.site_name + '"' : '') + ')' : '';
                        resultEl.innerHTML = '<span class="cs-diag-ok"><i class="icon-check"></i> Connexion réussie' + details + '</span>';
                    } else if (data && data.error) {
                        resultEl.innerHTML = '<span class="text-danger"><i class="icon-times"></i> ' + data.error + '</span>';
                    } else {
                        var preview = (res.body || '').substring(0, 200).replace(/</g, '&lt;');
                        resultEl.innerHTML = '<span class="text-danger">HTTP ' + res.status + ' — réponse non JSON. F12 console pour détails.</span><pre style="background:#fff;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:11px;margin-top:6px;overflow:auto;max-height:200px">' + preview + '</pre>';
                    }
                })
                .catch(function (err) {
                    matomoTestBtn.disabled = false;
                    console.error('[CoolStats] fetch failed:', err);
                    resultEl.innerHTML = '<span class="text-danger">Erreur réseau : ' + (err && err.message ? err.message : 'inconnue') + ' (F12 → Network pour détails)</span>';
                });
        });
    }

    // ── Reset des préférences utilisateur ──
    var resetBtn = document.getElementById('cs-reset-prefs-btn');
    if (resetBtn) {
        resetBtn.addEventListener('click', function () {
            if (!confirm('Réinitialiser vos préférences ? Toutes les sections reviendront aux valeurs par défaut.')) return;
            resetBtn.disabled = true;
            var url = '{$cs_dashboard_link nofilter}';
            url = url.replace('lite_display=1', 'ajax=1&action=resetSections');
            fetch(url, { method: 'POST' })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    var msg = document.getElementById('cs-reset-prefs-msg');
                    if (msg) {
                        msg.style.display = 'block';
                        msg.textContent = data && data.ok ? 'Préférences réinitialisées.' : 'Erreur lors du reset.';
                        msg.style.color = data && data.ok ? '#2e7d32' : '#c62828';
                    }
                    resetBtn.disabled = false;
                })
                .catch(function () {
                    resetBtn.disabled = false;
                });
        });
    }

    // ── Matrice états : toggles, recherche, summary, config auto ──
    var matrix = document.querySelector('.cs-states-matrix');
    if (matrix) {
        // Click cell → toggle on + sync hidden checkbox
        matrix.addEventListener('click', function (e) {
            var btn = e.target.closest('.cs-toggle-cell');
            if (!btn) return;
            btn.classList.toggle('cs-on');
            btn.classList.remove('cs-conflict');
            var cb = btn.parentNode.querySelector('input.cs-state-checkbox');
            if (cb) cb.checked = btn.classList.contains('cs-on');
            updateSummary();
        });

        // Recherche
        var search = document.getElementById('cs-states-search');
        if (search) {
            search.addEventListener('input', function () {
                var q = (search.value || '').toLowerCase().trim();
                matrix.querySelectorAll('.cs-states-row[data-search]').forEach(function (row) {
                    if (!q) { row.style.display = ''; return; }
                    row.style.display = row.getAttribute('data-search').indexOf(q) > -1 ? '' : 'none';
                });
            });
        }

        // Config auto Prestashop standard
        var btnAuto = document.getElementById('cs-states-auto');
        if (btnAuto) {
            btnAuto.addEventListener('click', function () {
                // Mapping standard PrestaShop : 2 paid, 4 shipped, 5 delivered, 6 cancelled, 7 refunded, 17 paid_completed
                var preset = {
                    VALID:     ['2', '4', '5', '17'],
                    CANCELLED: ['6', '7'],
                    SHIPPED:   ['4', '17'],
                    DELIVERED: ['5']
                };
                applyPreset(preset);
            });
        }

        // Reset
        var btnReset = document.getElementById('cs-states-reset');
        if (btnReset) {
            btnReset.addEventListener('click', function () {
                if (!confirm('Décocher toutes les cases ?')) return;
                matrix.querySelectorAll('.cs-toggle-cell').forEach(function (b) {
                    b.classList.remove('cs-on', 'cs-conflict');
                });
                matrix.querySelectorAll('input.cs-state-checkbox').forEach(function (cb) { cb.checked = false; });
                updateSummary();
            });
        }

        function applyPreset(preset) {
            matrix.querySelectorAll('.cs-toggle-cell').forEach(function (btn) {
                var cat = btn.dataset.cat;
                var sid = btn.dataset.state;
                var on = preset[cat] && preset[cat].indexOf(sid) > -1;
                btn.classList.toggle('cs-on', on);
                btn.classList.remove('cs-conflict');
                var cb = btn.parentNode.querySelector('input.cs-state-checkbox');
                if (cb) cb.checked = on;
            });
            updateSummary();
        }

        function updateSummary() {
            var allRows = matrix.querySelectorAll('.cs-states-row[data-state-id]');
            var mapped = 0, ignored = 0, conflicts = 0;
            allRows.forEach(function (row) {
                var on = row.querySelectorAll('.cs-toggle-cell.cs-on');
                if (on.length === 0) {
                    ignored++;
                } else {
                    mapped++;
                    // Conflit : annulé + (validé OU expédié OU livré) → incohérent
                    var cancelled = row.querySelector('.cs-toggle-cell.cs-on[data-cat="CANCELLED"]');
                    var others = row.querySelector('.cs-toggle-cell.cs-on[data-cat="VALID"], .cs-toggle-cell.cs-on[data-cat="SHIPPED"], .cs-toggle-cell.cs-on[data-cat="DELIVERED"]');
                    if (cancelled && others) {
                        conflicts++;
                        on.forEach(function (b) {
                            if (b !== cancelled && b !== others) return;
                            b.classList.add('cs-conflict');
                        });
                    }
                }
            });
            var elM = document.getElementById('cs-states-mapped');
            var elI = document.getElementById('cs-states-ignored');
            var elC = document.getElementById('cs-states-conflicts');
            if (elM) elM.textContent = mapped;
            if (elI) elI.textContent = ignored;
            if (elC) elC.textContent = conflicts;
        }

        updateSummary();
    }
})();
</script>
