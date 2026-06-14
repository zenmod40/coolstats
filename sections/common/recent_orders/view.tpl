<div class="cs-section cs-orders-section cs-collapsible" data-cs-section="recent_orders">
    <div class="cs-section-header cs-collapse-toggle" role="button">
        <span><i class="bi bi-list-columns-reverse"></i> {$section.title}
            <span class="badge cs-badge-accent ms-2">{$section_data.pagination.total_orders}</span>
        </span>
        <div class="d-flex gap-2 align-items-center flex-wrap">
            <button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv onclick="event.stopPropagation();" title="Exporter la page affichée en CSV"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>
            <div class="dropdown cs-pill-dropdown" data-filter="orders_sort" onclick="event.stopPropagation();">
                <button class="cs-pill-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-sort-down me-2"></i>
                    <span class="cs-pill-label">{if $section_data.filters.sort == 'basket'}Tri : montant ↓{elseif $section_data.filters.sort == 'items'}Tri : articles ↓{else}Tri : date{/if}</span>
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == ''} cs-active{/if}" data-value="">Tri : date</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'basket'} cs-active{/if}" data-value="basket">Tri : montant ↓</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'items'} cs-active{/if}" data-value="items">Tri : articles ↓</button></li>
                </ul>
            </div>
            <label class="cs-orders-newcust-toggle{if $section_data.filters.customers == 'new'} cs-active{/if}" onclick="event.stopPropagation();" title="Afficher uniquement la 1re commande de chaque client">
                <input type="checkbox" class="cs-filter" data-filter="orders_customers" data-on-value="new" data-off-value="" {if $section_data.filters.customers == 'new'}checked{/if}>
                <i class="bi bi-person-plus"></i> Nouveaux clients
            </label>
            <input type="text" class="cs-filter cs-search-input cs-orders-search" data-filter="orders_search"
                   data-debounce="450" data-min-length="3"
                   placeholder="Réf. ou client…" value="{$section_data.filters.search|escape:'html'}"
                   onclick="event.stopPropagation();">
            <i class="bi bi-chevron-down cs-collapse-chevron"></i>
        </div>
    </div>

    <div class="cs-collapsible-body">

    <div class="d-flex gap-2 mb-2 flex-wrap align-items-center">
        {foreach from=['all'=>'Toutes', 'preparing'=>'En préparation', 'shipped'=>'Expédiées', 'delivered'=>'Livrées', 'cancelled'=>'Annulées'] key=k item=label}
        <button type="button" class="cs-orders-filter-btn cs-filter{if $section_data.filters.status == $k} cs-active{/if}"
                data-filter="orders_status" data-on-value="{$k}" data-toggle-mode="value">{$label}</button>
        {/foreach}
        {if $section_data.filters.sort == 'basket'}
            <span class="cs-drill-chip"><i class="bi bi-sort-numeric-down"></i> Tri : montant <button type="button" class="cs-drill-chip-clear" data-clear-drill="1" title="Retirer le tri">×</button></span>
        {elseif $section_data.filters.sort == 'items'}
            <span class="cs-drill-chip"><i class="bi bi-sort-numeric-down"></i> Tri : articles <button type="button" class="cs-drill-chip-clear" data-clear-drill="1" title="Retirer le tri">×</button></span>
        {/if}
        {if $section_data.filters.customers == 'new'}
            <span class="cs-drill-chip"><i class="bi bi-person-plus"></i> Nouveaux clients uniquement <button type="button" class="cs-drill-chip-clear" data-clear-drill="1" title="Retirer le filtre">×</button></span>
        {/if}
    </div>

    {if $section_data.orders|@count}
    <div class="table-responsive">
        <table class="table table-sm cs-table mb-0">
            <thead>
                <tr>
                    <th>Référence</th>
                    <th>Client</th>
                    <th>Paiement</th>
                    <th>Date</th>
                    <th class="text-end">Montant</th>
                    <th>Statut</th>
                    <th>Pays</th>
                    <th class="text-end">Action</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.orders item=o}
                <tr>
                    <td><code class="cs-ref">{$o.reference|escape:'html':'UTF-8'}</code></td>
                    <td class="fw-semibold">{$o.customer|escape:'html':'UTF-8'}</td>
                    <td class="small">{$o.payment|escape:'html':'UTF-8'}</td>
                    <td class="text-secondary small">{$o.date}</td>
                    <td class="text-end fw-bold">{$o.total|number_format:2:',':' '}&euro;</td>
                    <td><span class="cs-status-badge" style="background:{$o.status_color}20;color:{$o.status_color};border:1px solid {$o.status_color}40">{$o.status}</span></td>
                    <td class="small">{if $o.country_iso}<span class="text-muted">{$o.country_iso}</span>{else}—{/if}</td>
                    <td class="text-end"><a href="{$o.bo_link}" target="_blank" class="cs-link" title="Voir la commande"><i class="bi bi-box-arrow-up-right"></i></a></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>

    {if $section_data.pagination.total_pages > 1}
    <div class="cs-orders-pagination">
        <span class="small text-muted">Page {$section_data.pagination.page} / {$section_data.pagination.total_pages} · {$section_data.pagination.total_orders} commandes</span>
        <div class="d-flex gap-1">
            {if $section_data.pagination.page > 1}
            <button type="button" class="cs-page-btn cs-filter" data-filter="orders_page" data-on-value="{$section_data.pagination.page - 1}" data-toggle-mode="value"><i class="bi bi-chevron-left"></i></button>
            {/if}
            {if $section_data.pagination.page < $section_data.pagination.total_pages}
            <button type="button" class="cs-page-btn cs-filter" data-filter="orders_page" data-on-value="{$section_data.pagination.page + 1}" data-toggle-mode="value"><i class="bi bi-chevron-right"></i></button>
            {/if}
        </div>
    </div>
    {/if}

    {else}
    <div class="p-3 text-center text-muted small"><i class="bi bi-inbox fs-3 d-block mb-2"></i>Aucune commande pour cette période / ce filtre</div>
    {/if}

    </div>{* /cs-collapsible-body *}
</div>
