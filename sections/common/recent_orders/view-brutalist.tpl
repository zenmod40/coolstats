{* ── Dernières commandes · Variante Brutalist ── carte blanche, pill verte + filet + table *}
<div class="cs-section cs-orders-section cs-collapsible cs-orders-brutal" data-cs-section="recent_orders">
    <div class="cs-brutal-titlebar cs-collapse-toggle" role="button">
        <span class="cs-brutal-tag cs-brutal-tag-green">🧾 {l s='Dernières commandes' mod='coolstats'}</span>
        <div class="cs-brutal-rule"></div>

        <div class="cs-orders-brutal-controls" onclick="event.stopPropagation();">
            <div class="dropdown cs-pill-dropdown" data-filter="orders_sort">
                <button class="cs-brutal-tag cs-brutal-tag-white dropdown-toggle cs-orders-brutal-sortbtn" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    {if $section_data.filters.sort == 'basket'}{l s='Tri montant' mod='coolstats'}
                    {elseif $section_data.filters.sort == 'items'}{l s='Tri articles' mod='coolstats'}
                    {else}{l s='Tri date' mod='coolstats'}{/if} ▾
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == ''} cs-active{/if}" data-value="">{l s='Tri date' mod='coolstats'}</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'basket'} cs-active{/if}" data-value="basket">{l s='Tri montant' mod='coolstats'}</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'items'} cs-active{/if}" data-value="items">{l s='Tri articles' mod='coolstats'}</button></li>
                </ul>
            </div>
            <label class="cs-orders-brutal-newcust{if $section_data.filters.customers == 'new'} cs-active{/if}" title="{l s='1re commande de chaque client' mod='coolstats'}">
                <input type="checkbox" class="cs-filter" data-filter="orders_customers" data-on-value="new" data-off-value="" {if $section_data.filters.customers == 'new'}checked{/if}>
                {l s='Nouveaux clients' mod='coolstats'}
            </label>
            <input type="text" class="cs-filter cs-orders-brutal-search" data-filter="orders_search"
                   data-debounce="450" data-min-length="3"
                   placeholder="{l s='Réf. ou client…' mod='coolstats'}" value="{$section_data.filters.search|escape:'html'}">
            <span class="cs-brutal-tag cs-brutal-tag-dark">{$section_data.pagination.total_orders}</span>
        </div>
    </div>

    <div class="cs-collapsible-body">

    <div class="cs-orders-brutal-filters">
        {foreach from=['all'=>'Toutes', 'preparing'=>'En préparation', 'shipped'=>'Expédiées', 'delivered'=>'Livrées', 'cancelled'=>'Annulées'] key=k item=label}
        <button type="button" class="cs-orders-brutal-status-btn cs-filter{if $section_data.filters.status == $k} cs-active{/if}"
                data-filter="orders_status" data-on-value="{$k}" data-toggle-mode="value">{l s=$label mod='coolstats'}</button>
        {/foreach}
    </div>

    {if $section_data.orders|@count}
    <div class="table-responsive">
        <table class="cs-orders-brutal-table">
            <thead>
                <tr>
                    <th>{l s='Réf.' mod='coolstats'}</th>
                    <th>{l s='Client' mod='coolstats'}</th>
                    <th>{l s='Date' mod='coolstats'}</th>
                    <th>{l s='Paiement' mod='coolstats'}</th>
                    <th>{l s='Statut' mod='coolstats'}</th>
                    <th>{l s='Pays' mod='coolstats'}</th>
                    <th>{l s='Total' mod='coolstats'}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.orders item=o}
                <tr>
                    <td><a href="{$o.bo_link}" target="_blank" class="cs-orders-brutal-ref">{$o.reference|escape:'html':'UTF-8'}</a></td>
                    <td>{$o.customer|escape:'html':'UTF-8'}</td>
                    <td class="cs-orders-brutal-date">{$o.date}</td>
                    <td>{$o.payment|escape:'html':'UTF-8'}</td>
                    <td><span class="cs-activity-brutal-state cs-activity-brutal-state-{$o.kind}">{$o.status}</span></td>
                    <td class="cs-orders-brutal-country">{if $o.country_iso}{$o.country_iso}{else}—{/if}</td>
                    <td><span class="cs-orders-brutal-total">{$o.total|number_format:2:',':' '}&euro;</span></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>

    {if $section_data.pagination.total_pages > 1}
    <div class="cs-orders-brutal-pagination">
        <span class="cs-brutal-meta">{l s='Page' mod='coolstats'} {$section_data.pagination.page} / {$section_data.pagination.total_pages} · {$section_data.pagination.total_orders} {l s='commandes' mod='coolstats'}</span>
        <div class="cs-orders-brutal-pages">
            {if $section_data.pagination.page > 1}
            <button type="button" class="cs-orders-brutal-page cs-filter" data-filter="orders_page" data-on-value="{$section_data.pagination.page - 1}" data-toggle-mode="value">‹</button>
            {/if}
            {if $section_data.pagination.page < $section_data.pagination.total_pages}
            <button type="button" class="cs-orders-brutal-page cs-filter" data-filter="orders_page" data-on-value="{$section_data.pagination.page + 1}" data-toggle-mode="value">›</button>
            {/if}
        </div>
    </div>
    {/if}

    {else}
    <div class="cs-brutal-empty">{l s='Aucune commande pour cette période / ce filtre' mod='coolstats'}</div>
    {/if}

    </div>{* /cs-collapsible-body *}
</div>
