<div class="cs-section cs-top-products" data-cs-section="top_products">
    <div class="cs-section-header">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <span><i class="bi bi-trophy"></i> {$section.title}</span>
            <div class="cs-top-tabs" role="tablist">
                <button type="button" class="cs-top-tab cs-active" data-cs-top-tab="products"><i class="bi bi-box-seam me-1"></i>Produits</button>
                <button type="button" class="cs-top-tab" data-cs-top-tab="categories"><i class="bi bi-tags me-1"></i>Catégories</button>
            </div>
        </div>
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <div class="dropdown cs-pill-dropdown" data-filter="top_limit" id="cs-top-limit-wrap">
                <button class="cs-pill-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-trophy me-2"></i>
                    <span class="cs-pill-label">Top {$section_data.limit}</span>
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 10} cs-active{/if}" data-value="10">Top 10</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 25} cs-active{/if}" data-value="25">Top 25</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 50} cs-active{/if}" data-value="50">Top 50</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 100} cs-active{/if}" data-value="100">Top 100</button></li>
                </ul>
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="small {if $section_data.sort_mode != 'revenue'}fw-bold{else}text-muted{/if}">Volume</span>
                <div class="form-check form-switch mb-0">
                    <input class="form-check-input cs-filter" data-filter="sort" data-on-value="revenue" data-off-value="qty" type="checkbox" id="cs-top-mode-toggle" {if $section_data.sort_mode == 'revenue'}checked{/if}>
                </div>
                <span class="small {if $section_data.sort_mode == 'revenue'}fw-bold{else}text-muted{/if}">CA &euro;</span>
            </div>
            <button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" id="cs-export-top-products" title="Exporter en CSV">
                <i class="bi bi-file-earmark-spreadsheet"></i> CSV
            </button>
        </div>
    </div>

    <div class="cs-top-products-view">
    {if $section_data.products|@count}
    <div class="table-responsive">
        <table class="table table-sm cs-table mb-0" style="min-width:700px">
            <thead>
                <tr class="cs-top-totals-row">
                    <td colspan="5" class="small">
                        <strong>Total Top {$section_data.limit}</strong>
                        <span class="text-muted ms-2">représente
                            <strong style="color:var(--cs-accent)">{if $section_data.sort_mode == 'revenue'}{$section_data.totals.pct_revenue}{else}{$section_data.totals.pct_qty}{/if}%</strong>
                            du {if $section_data.sort_mode == 'revenue'}CA{else}volume{/if} de la période
                        </span>
                    </td>
                    <td class="text-end fw-bold">{$section_data.totals.top_qty}</td>
                    <td class="text-end fw-bold">{$section_data.totals.top_revenue|number_format:0:',':' '}&euro;</td>
                </tr>
                <tr>
                    <th style="width:30px">#</th>
                    <th style="width:36px"></th>
                    <th>Produit</th>
                    <th class="text-nowrap">Référence</th>
                    <th class="text-nowrap">EAN</th>
                    <th class="text-end text-nowrap">Unités</th>
                    <th class="text-end text-nowrap">CA</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.products item=p name=tploop}
                <tr>
                    <td><span class="cs-rank-number">{$smarty.foreach.tploop.iteration}</span></td>
                    <td>
                        {if $p.image}
                            <img src="{$p.image}" alt="" class="rounded" style="width:32px;height:32px;object-fit:cover">
                        {else}
                            <div class="rounded bg-secondary d-flex align-items-center justify-content-center" style="width:32px;height:32px"><i class="bi bi-image text-muted small"></i></div>
                        {/if}
                    </td>
                    <td class="text-truncate" style="max-width:240px">
                        <a href="{$p.bo_link}" target="_blank" class="small text-decoration-none cs-link" title="{$p.name|escape:'html':'UTF-8'}">{$p.name|escape:'html':'UTF-8'}</a>
                    </td>
                    <td class="small text-muted text-nowrap">{$p.reference|escape:'html':'UTF-8'}</td>
                    <td class="small text-muted text-nowrap">{$p.ean13}</td>
                    <td class="text-end fw-bold small">{$p.total_qty}</td>
                    <td class="text-end fw-bold small">{$p.total_revenue|number_format:0:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {else}
    <div class="p-3 text-center text-muted small"><i class="bi bi-trophy fs-3 d-block mb-2"></i>Aucune donnée sur cette période</div>
    {/if}
    </div>

    {* Vue Top catégories — chargée en AJAX au clic sur l'onglet (action=getTopCategories) *}
    <div class="cs-top-categories-view d-none" id="cs-top-categories">
        <div class="p-3 text-center text-muted small"><div class="spinner-border spinner-border-sm"></div></div>
    </div>
</div>
