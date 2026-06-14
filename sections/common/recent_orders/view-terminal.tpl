{* ── Dernières commandes · Variante Terminal ── *}
<div class="cs-section cs-orders-section cs-collapsible cs-orders-term" data-cs-section="recent_orders">
    <div class="cs-section-header cs-collapse-toggle" role="button">
        <span>🧾 {l s='Dernières commandes' mod='coolstats'} <span class="cs-orders-term-count">{$section_data.pagination.total_orders}</span></span>
        <div class="cs-orders-term-controls" onclick="event.stopPropagation();">
            <div class="dropdown cs-pill-dropdown cs-orders-term-pill" data-filter="orders_sort">
                <button class="cs-pill-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <span class="cs-pill-label">↧ {l s='Tri' mod='coolstats'} : {if $section_data.filters.sort == 'basket'}{l s='montant' mod='coolstats'}{elseif $section_data.filters.sort == 'items'}{l s='articles' mod='coolstats'}{else}{l s='date' mod='coolstats'}{/if} ▾</span>
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == ''} cs-active{/if}" data-value="">{l s='Tri date' mod='coolstats'}</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'basket'} cs-active{/if}" data-value="basket">{l s='Tri montant' mod='coolstats'}</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.filters.sort == 'items'} cs-active{/if}" data-value="items">{l s='Tri articles' mod='coolstats'}</button></li>
                </ul>
            </div>
            <label class="cs-orders-term-newcust{if $section_data.filters.customers == 'new'} cs-active{/if}" title="{l s='1re commande de chaque client' mod='coolstats'}">
                <input type="checkbox" class="cs-filter" data-filter="orders_customers" data-on-value="new" data-off-value="" {if $section_data.filters.customers == 'new'}checked{/if}>
                ⊕ {l s='Nouveaux clients' mod='coolstats'}
            </label>
            <input type="text" class="cs-filter cs-orders-term-search" data-filter="orders_search"
                   data-debounce="450" data-min-length="3"
                   placeholder="{l s='Réf. ou client…' mod='coolstats'}" value="{$section_data.filters.search|escape:'html'}">
        </div>
    </div>

    <div class="cs-collapsible-body">
    <div class="cs-orders-term-filters">
        {foreach from=['all'=>'Toutes', 'preparing'=>'En préparation', 'shipped'=>'Expédiées', 'delivered'=>'Livrées', 'cancelled'=>'Annulées'] key=k item=label}
        <button type="button" class="cs-orders-term-tab cs-filter{if $section_data.filters.status == $k} cs-active{/if}"
                data-filter="orders_status" data-on-value="{$k}" data-toggle-mode="value">{l s=$label mod='coolstats'}</button>
        {/foreach}
    </div>

    {if $section_data.orders|@count}
    <div class="cs-orders-term-tablewrap">
        <table class="cs-orders-term-table">
            <thead>
                <tr>
                    <th>{l s='Référence' mod='coolstats'}</th>
                    <th>{l s='Client' mod='coolstats'}</th>
                    <th>{l s='Paiement' mod='coolstats'}</th>
                    <th style="width:130px">{l s='Date' mod='coolstats'}</th>
                    <th class="text-end" style="width:90px">{l s='Montant' mod='coolstats'}</th>
                    <th style="width:230px">{l s='Statut' mod='coolstats'}</th>
                    <th style="width:50px">{l s='Pays' mod='coolstats'}</th>
                    <th style="width:40px">{l s='Action' mod='coolstats'}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.orders item=o}
                <tr>
                    <td><a href="{$o.bo_link}" target="_blank" class="cs-orders-term-ref">{$o.reference|escape:'html':'UTF-8'}</a></td>
                    <td class="cs-orders-term-customer">{$o.customer|escape:'html':'UTF-8'}</td>
                    <td class="cs-orders-term-payment">{$o.payment|escape:'html':'UTF-8'}</td>
                    <td class="cs-orders-term-date">{$o.date}</td>
                    <td class="text-end cs-orders-term-amount">{$o.total|number_format:2:',':' '}&euro;</td>
                    <td><span class="cs-orders-term-status cs-orders-term-status--{$o.kind}">{$o.status}</span></td>
                    <td class="cs-orders-term-country">{if $o.country_iso}{$o.country_iso}{else}—{/if}</td>
                    <td class="cs-orders-term-action"><a href="{$o.bo_link}" target="_blank" title="{l s='Ouvrir' mod='coolstats'}">↗</a></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>

    {if $section_data.pagination.total_pages > 1}
    <div class="cs-orders-term-pagination">
        <span class="cs-orders-term-page-info">// {l s='page' mod='coolstats'} {$section_data.pagination.page} / {$section_data.pagination.total_pages} · {$section_data.pagination.total_orders} {l s='commandes' mod='coolstats'}</span>
        <div class="cs-orders-term-pages">
            <button type="button" class="cs-orders-term-page cs-filter{if $section_data.pagination.page <= 1} cs-disabled{/if}" data-filter="orders_page" data-on-value="{$section_data.pagination.page - 1}" data-toggle-mode="value"{if $section_data.pagination.page <= 1} disabled{/if}>‹</button>
            <button type="button" class="cs-orders-term-page cs-filter{if $section_data.pagination.page >= $section_data.pagination.total_pages} cs-disabled{/if}" data-filter="orders_page" data-on-value="{$section_data.pagination.page + 1}" data-toggle-mode="value"{if $section_data.pagination.page >= $section_data.pagination.total_pages} disabled{/if}>›</button>
        </div>
    </div>
    {/if}

    {else}
    <div class="cs-term-empty">{l s='Aucune commande pour cette période / ce filtre' mod='coolstats'}</div>
    {/if}
    </div>{* /cs-collapsible-body *}
</div>
