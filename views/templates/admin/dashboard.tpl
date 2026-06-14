{if isset($cs_lite_display) && $cs_lite_display}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$cs_brand_name} Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    {if $cs_visual_theme == 'cozy'}<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">{/if}
    {if $cs_visual_theme == 'aurora'}<link href="https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&display=swap" rel="stylesheet">{/if}
    {if $cs_visual_theme == 'editorial'}<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;1,400;1,500&display=swap" rel="stylesheet">{/if}
    {if $cs_visual_theme == 'brutalist'}<link href="https://fonts.googleapis.com/css2?family=Archivo+Black&family=Anton&family=JetBrains+Mono:wght@400;500;700&family=Space+Grotesk:wght@400;500;600;700&display=swap" rel="stylesheet">{/if}
    {if $cs_visual_theme == 'terminal'}<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">{/if}
    <link rel="stylesheet" href="{$cs_module_path}views/css/coolstats.css">
    <link rel="stylesheet" href="{$cs_module_path}views/css/themes/_shared.css">
    <link rel="stylesheet" href="{$cs_module_path}views/css/themes/{$cs_visual_theme}.css">
    <script>(function(){ldelim}
        var NATIVE_MODE = {ldelim} aurora:'dark', cozy:'light', editorial:'light', brutalist:'light', terminal:'dark' {rdelim};
        var theme = '{$cs_visual_theme}';
        var savedMode = localStorage.getItem('cs-mode-' + theme);
        var mode = savedMode || NATIVE_MODE[theme] || 'dark';
        document.documentElement.setAttribute('data-bs-theme', mode);
        document.documentElement.setAttribute('data-cs-theme', theme);
    {rdelim})();</script>
</head>
<body>
{/if}

<div id="cs-app">

    {if $cs_visual_theme == 'aurora'}
    {* Gradient SVG embarqué une fois pour le logo Aurora (référencé via url(#cs-aurora-grad)) *}
    <svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
        <defs>
            <linearGradient id="cs-aurora-grad" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0%"   stop-color="#7c5cff"/>
                <stop offset="50%"  stop-color="#3ad9ff"/>
                <stop offset="100%" stop-color="#ff6ec4"/>
            </linearGradient>
        </defs>
    </svg>
    {/if}

    {* Header dédié à l'impression PDF — masqué à l'écran *}
    <div class="cs-print-header">
        <div class="cs-print-brand">
            <img src="{$cs_module_path}views/img/logos/{$cs_logo_print_png}" alt="{$cs_brand_name|escape:'html'}">
            <div>
                <div class="cs-print-title">{$cs_brand_name|escape:'html'} <span class="cs-print-ver">v{$cs_version}</span></div>
                <div class="cs-print-shop">{Configuration::get('PS_SHOP_NAME')|escape:'html'}</div>
            </div>
        </div>
        <div class="cs-print-meta">
            <div><strong>Période :</strong> du {$cs_date_from} au {$cs_date_to}</div>
            {if $cs_country}<div><strong>Pays :</strong> {$cs_country|escape:'html'}</div>{/if}
            <div class="cs-print-generated">Édité le {$cs_current_date}</div>
        </div>
    </div>

    <header class="cs-header">
        <div class="cs-header-brand">
            {if $cs_visual_theme == 'brutalist'}
                <div class="cs-logo-brutal" aria-label="{$cs_brand_name|escape:'html'}">★</div>
            {elseif $cs_visual_theme == 'terminal'}
                <span class="cs-logo-term" aria-label="{$cs_brand_name|escape:'html'}">▮▮▮</span>
            {else}
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 44 44" width="44" height="44" class="cs-logo" aria-label="{$cs_brand_name|escape:'html'}">
                    <rect class="cs-logo-bg" x="0" y="0" width="44" height="44" rx="12" ry="12"/>
                    <path class="cs-logo-mark cs-logo-chevron" d="M 13 28 L 18 20 L 23 23 L 32 12" fill="none" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            {/if}
            <div>
                {if $cs_visual_theme == 'editorial'}
                    <span class="cs-ed-masthead-kicker">{l s='Le rapport trimestriel' mod='coolstats'}</span>
                {/if}
                <h1>{$cs_brand_name}{if $cs_visual_theme == 'brutalist'}!{/if}</h1>
                {if $cs_visual_theme == 'cozy' && $cs_employee_firstname}
                    <small class="text-secondary cs-greeting">{l s='Bonjour %s · voici tes stats' sprintf=[$cs_employee_firstname] mod='coolstats'} ☕</small>
                {/if}
            </div>
            {if $cs_visual_theme == 'brutalist' || $cs_visual_theme == 'terminal'}
                <div class="cs-header-version">v{$cs_version}</div>
            {/if}
        </div>
        <div class="d-flex align-items-center gap-2 flex-wrap" id="cs-filters">

            {* ── Recherche produit (filtre global du dashboard) ── *}
            <div class="cs-product-search" id="cs-product-search">
                <i class="bi bi-search cs-product-search-icon"></i>
                <input type="search" id="cs-product-search-input" class="cs-product-search-input" autocomplete="off"
                       placeholder="Rechercher un produit…"
                       value="{if isset($cs_product) && $cs_product}{$cs_product|escape:'html'}{/if}">
                <button type="button" class="cs-product-search-clear{if !isset($cs_product) || !$cs_product} d-none{/if}" id="cs-product-search-clear" title="Effacer la recherche"><i class="bi bi-x-lg"></i></button>
                <div class="cs-suggest" id="cs-product-suggest" style="display:none"></div>
            </div>

            {* ── Date Range Picker ── *}
            {* data-bs-strategy="fixed" force Popper.js à utiliser position:fixed sur le menu
               (relatif au viewport) plutôt que position:absolute (relatif au wrapper). Le menu
               échappe ainsi à tous les stacking contexts ancestraux — sans ça, le transform
               translate3d que Popper applique pour le positionnement crée un sous-contexte qui
               piège le z-index : aucune valeur, même 99999, ne permet de dépasser un parent
               qui a son propre contexte (cas du header sticky ou des sections kpi en z-index 1). *}
            <div class="dropdown" id="cs-daterange-wrapper" data-bs-strategy="fixed">
                <button class="btn btn-sm dropdown-toggle cs-daterange-btn" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-bs-strategy="fixed" aria-expanded="false">
                    <i class="bi bi-calendar3 me-2"></i>
                    <span id="cs-daterange-label">Ce mois</span>
                </button>
                <div class="dropdown-menu dropdown-menu-end cs-daterange-menu p-0">
                    <div class="d-flex">
                        <div class="cs-daterange-presets">
                            <div class="cs-daterange-group-title">Semaine</div>
                            <button class="cs-daterange-preset" data-range="this_week">Cette semaine</button>
                            <button class="cs-daterange-preset" data-range="last_week">Semaine -1</button>
                            <button class="cs-daterange-preset" data-range="week_minus_2">Semaine -2</button>

                            <div class="cs-daterange-group-title mt-2">Mois</div>
                            <button class="cs-daterange-preset active" data-range="this_month">Ce mois</button>
                            <button class="cs-daterange-preset" data-range="last_month">Mois -1</button>
                            <button class="cs-daterange-preset" data-range="month_minus_2">Mois -2</button>

                            <div class="cs-daterange-group-title mt-2">Trimestre</div>
                            <button class="cs-daterange-preset" data-range="this_quarter">Ce trimestre</button>
                            <button class="cs-daterange-preset" data-range="last_quarter">Trimestre -1</button>
                            <button class="cs-daterange-preset" data-range="quarter_minus_2">Trimestre -2</button>

                            <div class="cs-daterange-group-title mt-2">Année</div>
                            <button class="cs-daterange-preset" data-range="this_year">Cette année</button>
                            <button class="cs-daterange-preset" data-range="last_year">Année -1</button>
                            <button class="cs-daterange-preset" data-range="year_minus_2">Année -2</button>
                        </div>
                        <div class="cs-daterange-custom">
                            <div class="cs-daterange-group-title">Période personnalisée</div>
                            <div class="mb-2">
                                <label class="form-label small text-muted mb-1">Début</label>
                                <input type="date" class="form-control form-control-sm cs-date-input" id="cs-date-from" value="{$cs_date_from}">
                            </div>
                            <div class="mb-3">
                                <label class="form-label small text-muted mb-1">Fin</label>
                                <input type="date" class="form-control form-control-sm cs-date-input" id="cs-date-to" value="{$cs_date_to}">
                            </div>
                            <button class="btn btn-sm w-100 cs-btn-accent" id="cs-daterange-apply"><i class="bi bi-check-lg me-1"></i>Appliquer</button>
                            <div class="mt-2 text-center"><small class="text-muted" id="cs-daterange-summary"></small></div>
                        </div>
                    </div>
                </div>
            </div>

            {* Dropdown comparaison — même look que le bouton date range *}
            {* data-bs-strategy="fixed" : voir explication sur le date-range picker plus haut. *}
            <div class="dropdown cs-pill-dropdown" data-filter="compare_with" data-bs-strategy="fixed">
                <button class="cs-pill-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" data-bs-strategy="fixed" aria-expanded="false">
                    <i class="bi bi-arrow-left-right me-2"></i>
                    <span class="cs-pill-label">{if $cs_visual_theme == 'brutalist'}{if $cs_compare_mode == 'yoy'}{l s='VS N-1' mod='coolstats'}{elseif $cs_compare_mode == 'none'}{l s='NO CMP' mod='coolstats'}{else}{l s='VS PREV' mod='coolstats'}{/if}{elseif $cs_visual_theme == 'terminal'}{if $cs_compare_mode == 'yoy'}{l s='vs n-1' mod='coolstats'}{elseif $cs_compare_mode == 'none'}{l s='pas de comparaison' mod='coolstats'}{else}{l s='vs période préc' mod='coolstats'}{/if}{else}{if $cs_compare_mode == 'yoy'}{l s='vs n-1 année' mod='coolstats'}{elseif $cs_compare_mode == 'none'}{l s='Pas de comparaison' mod='coolstats'}{else}{l s='vs période précédente' mod='coolstats'}{/if}{/if}</span>
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $cs_compare_mode == 'prev'} cs-active{/if}" data-value="prev">vs période précédente</button></li>
                    <li><button type="button" class="cs-pill-option{if $cs_compare_mode == 'yoy'} cs-active{/if}" data-value="yoy">vs n-1 année</button></li>
                    <li><button type="button" class="cs-pill-option{if $cs_compare_mode == 'none'} cs-active{/if}" data-value="none">Pas de comparaison</button></li>
                </ul>
            </div>

            <span class="badge cs-country-filter-badge{if !$cs_country} d-none{/if}" id="cs-country-filter-badge" role="button" title="Retirer le filtre pays">
                <i class="bi bi-geo-alt-fill me-1"></i><span id="cs-country-filter-label">{if $cs_country}{$cs_country}{/if}</span><i class="bi bi-x-lg ms-2" style="font-size:11px"></i>
            </span>
            <button class="btn btn-sm btn-outline-secondary" id="cs-customize-btn" title="Personnaliser le dashboard"><i class="bi bi-sliders"></i></button>
            <button class="btn btn-sm btn-outline-secondary" id="cs-fullscreen-btn" title="Mode présentation (plein écran)"><i class="bi bi-display"></i></button>
            <button class="btn btn-sm btn-outline-secondary" id="cs-pdf-btn" title="Exporter en PDF"><i class="bi bi-file-earmark-pdf"></i></button>
            {* ── Sélecteur de thème visuel ── *}
            <div class="dropdown" id="cs-theme-picker" data-bs-strategy="fixed">
                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" data-bs-strategy="fixed" title="Choisir un thème" aria-expanded="false"><i class="bi bi-palette"></i></button>
                <ul class="dropdown-menu dropdown-menu-end cs-theme-menu">
                    {foreach from=[['id'=>'aurora','name'=>'Aurora glass'],['id'=>'cozy','name'=>'Cozy'],['id'=>'editorial','name'=>'Editorial'],['id'=>'brutalist','name'=>'Neo-brutalist'],['id'=>'terminal','name'=>'Terminal']] item=th}
                        <li><button type="button" class="dropdown-item cs-theme-option{if $cs_visual_theme == $th.id} active{/if}" data-theme="{$th.id}">
                            <i class="bi bi-{if $cs_visual_theme == $th.id}check-circle-fill{else}circle{/if} me-2"></i>{$th.name}
                        </button></li>
                    {/foreach}
                </ul>
            </div>
            <button class="btn btn-sm btn-outline-secondary" id="cs-theme-toggle" title="Mode clair / sombre"><i class="bi bi-moon-stars"></i></button>
            <span class="cs-header-date">{if $cs_visual_theme == 'brutalist' || $cs_visual_theme == 'terminal'}{$cs_current_date_numeric}{else}{$cs_current_date}{/if}</span>
            {if !$cs_context.has_marketplaces}
                <span class="cs-header-mode cs-mode-direct"><span class="cs-mode-dot"></span>{l s='Vente directe' mod='coolstats'}</span>
            {else}
                <span class="cs-header-mode cs-mode-mkp" title="Vente directe + canaux marketplaces"><span class="cs-mode-dot"></span>{l s='Multi-canal' mod='coolstats'}</span>
            {/if}
        </div>
        <script>
            window.csDateFrom = '{$cs_date_from|escape:'javascript'}';
            window.csDateTo   = '{$cs_date_to|escape:'javascript'}';
            window.CS_REQUIRED_SECTIONS = {$cs_required_sections nofilter};
            window.CS_SECTIONS_META = {$cs_sections_meta_json nofilter};
            window.CS_MISSING_SECTIONS = {$cs_missing_sections_json nofilter};
            window.CS_AUTO_REFRESH_MIN = {$cs_auto_refresh_min|intval};
            window.CS_DEBUG = {$cs_debug|intval};
            window.CS_PDF_SECTIONS = {$cs_pdf_sections_json nofilter};
        </script>
    </header>

    {* Sections rendues par le dispatcher PHP *}
    {$cs_sections_html nofilter}

    <footer class="cs-footer text-center text-muted small py-3">
        {if $cs_visual_theme == 'terminal'}
            <span class="cs-footer-prompt">$</span> {$cs_brand_name} v{$cs_version} · <a href="{$cs_zm40_url}" target="_blank" rel="noopener" style="color:var(--cs-accent);text-decoration:underline">ZM40</a> · <a href="{$cs_zm40_url}" target="_blank" rel="noopener" style="color:var(--cs-accent);text-decoration:underline">découvrir nos modules</a>
        {else}
            {$cs_brand_name} v{$cs_version} &middot; <a href="{$cs_zm40_url}" target="_blank" rel="noopener" style="color:inherit;font-weight:600;text-decoration:none;border-bottom:1px dotted currentColor">ZM40</a> &middot; <a href="{$cs_zm40_url}" target="_blank" rel="noopener" style="color:inherit;text-decoration:none;border-bottom:1px dotted currentColor">découvrir nos modules</a>
        {/if}
    </footer>

    {if $cs_debug && $cs_perf_timings|@count}
    <div class="cs-perf-recap">
        <div class="cs-perf-recap-header">
            <strong><i class="bi bi-stopwatch"></i> Performance dashboard</strong>
            <span class="cs-perf-total">Total : {$cs_perf_dash_total|string_format:"%.0f"} ms</span>
        </div>
        <table class="cs-perf-table">
            <thead><tr><th>Section</th><th class="text-end">Query</th><th class="text-end">Render</th><th class="text-end">Total</th></tr></thead>
            <tbody>
            {foreach from=$cs_perf_timings key=sid item=t}
                {assign var=cls value="cs-perf-ok"}
                {if $t.total >= 800}{assign var=cls value="cs-perf-bad"}
                {elseif $t.total >= 200}{assign var=cls value="cs-perf-warn"}
                {/if}
                <tr class="{$cls}">
                    <td>{$sid|escape:'html'}</td>
                    <td class="text-end">{$t.query|string_format:"%.0f"} ms</td>
                    <td class="text-end">{$t.render|string_format:"%.0f"} ms</td>
                    <td class="text-end fw-bold">{$t.total|string_format:"%.0f"} ms</td>
                </tr>
            {/foreach}
            </tbody>
        </table>
    </div>
    {/if}

    {* ── Modal Top retours ── *}
    <div class="modal fade cs-modal" id="cs-modal-top-returns" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold mb-0"><i class="bi bi-arrow-return-left me-2"></i>Produits les plus retournés</h5>
                        <small class="text-muted" id="cs-modal-returns-subtitle"></small>
                    </div>
                    <div class="cs-returns-toggle ms-auto me-2">
                        <span class="cs-returns-mode-label cs-active" data-type="refunded" role="button">Remboursées</span>
                        <div class="form-check form-switch mb-0">
                            <input class="form-check-input" type="checkbox" id="cs-returns-type-toggle">
                        </div>
                        <span class="cs-returns-mode-label" data-type="cancelled" role="button">Annulées</span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="cs-modal-returns-body">
                    <div class="text-center py-5"><div class="spinner-border text-secondary"></div></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Fermer</button>
                </div>
            </div>
        </div>
    </div>

    {* ── Modal Transporteurs ── *}
    <div class="modal fade cs-modal" id="cs-modal-carriers" tabindex="-1">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold mb-0"><i class="bi bi-truck me-2"></i>Infos Transporteurs / Expéditions</h5>
                        <small class="text-muted" id="cs-modal-carriers-subtitle"></small>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="cs-modal-toolbar">
                        <label class="small text-secondary mb-0">Transporteurs :</label>
                        <div class="dropdown">
                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" data-bs-auto-close="outside">
                                <span id="cs-carriers-dropdown-label">Tous</span>
                            </button>
                            <ul class="dropdown-menu" id="cs-modal-carriers-dropdown-list" style="max-height:320px;overflow-y:auto;min-width:280px;background:var(--cs-bg-card);border-color:var(--cs-border);"></ul>
                        </div>
                    </div>
                    <div id="cs-modal-carriers-body">
                        <div class="text-center py-5"><div class="spinner-border text-secondary"></div></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Fermer</button>
                </div>
            </div>
        </div>
    </div>

    {* ── Modal confirmation suppression panier abandonné ── *}
    <div class="modal fade cs-modal" id="cs-modal-delete-cart" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold mb-0"><i class="bi bi-trash me-2 text-danger"></i>Supprimer ce panier abandonné&nbsp;?</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="mb-2">Vous êtes sur le point de supprimer définitivement le panier de&nbsp;:</p>
                    <p class="mb-3">
                        <strong id="cs-delete-cart-customer">—</strong>
                        <br>
                        <small class="text-muted">Valeur HT estimée&nbsp;: <strong id="cs-delete-cart-value">—</strong>&nbsp;&euro; · Panier #<span id="cs-delete-cart-id">—</span></small>
                    </p>
                    <div class="alert alert-warning small mb-0">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        Cette action est <strong>irréversible</strong>. Le panier et ses lignes produits seront supprimés de la base. Il ne pourra plus être relancé ni récupéré.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">Annuler</button>
                    <button type="button" class="btn btn-sm btn-danger" id="cs-delete-cart-confirm">
                        <i class="bi bi-trash me-1"></i> Supprimer définitivement
                    </button>
                </div>
            </div>
        </div>
    </div>

    {* ── Action bar mode édition ── *}
    <div id="cs-edit-bar">
        <div class="cs-edit-bar-inner">
            <div class="cs-edit-bar-info"><i class="bi bi-sliders me-2"></i><strong>Mode personnalisation</strong> — cochez/décochez les sections, ou glissez-les via la poignée <i class="bi bi-grip-vertical"></i> pour les réordonner. Sauvegarde automatique.</div>
            <div class="cs-edit-bar-actions">
                <span class="cs-edit-saved-status text-muted small" id="cs-edit-status"></span>
                <button type="button" class="btn btn-sm btn-outline-secondary" id="cs-edit-reset" title="Revenir à l'affichage par défaut"><i class="bi bi-arrow-counterclockwise me-1"></i>Réinitialiser</button>
                <button type="button" class="btn btn-sm cs-btn-accent" id="cs-edit-done">Terminer <kbd>Esc</kbd></button>
            </div>
        </div>
    </div>

</div>

{if isset($cs_lite_display) && $cs_lite_display}
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.7/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"></script>
{/if}
<script src="{$cs_module_path}views/js/coolstats.js"></script>
{if isset($cs_lite_display) && $cs_lite_display}
</body>
</html>
{/if}
