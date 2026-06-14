{* ── Top produits · Variante Terminal ──
 * Table dense mono : # | Produit | Ref | U | CA | Vol.
 * Pas d'image, pas d'EAN. CA en amber, REF en cobalt, U/BAR en phosphor.
 *}
<div class="cs-section cs-top-products cs-top-products-term" data-cs-section="top_products">
    <div class="cs-section-header">
        <span>★ {l s='Top' mod='coolstats'} {$section_data.limit} {l s='Produits' mod='coolstats'}</span>
        <div class="cs-top-term-controls">
            <div class="dropdown cs-pill-dropdown cs-top-term-limit" data-filter="top_limit">
                <button class="cs-pill-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                    <span class="cs-pill-label">{l s='Top' mod='coolstats'} {$section_data.limit}</span>
                </button>
                <ul class="dropdown-menu cs-pill-menu">
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 10} cs-active{/if}" data-value="10">{l s='Top' mod='coolstats'} 10</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 25} cs-active{/if}" data-value="25">{l s='Top' mod='coolstats'} 25</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 50} cs-active{/if}" data-value="50">{l s='Top' mod='coolstats'} 50</button></li>
                    <li><button type="button" class="cs-pill-option{if $section_data.limit == 100} cs-active{/if}" data-value="100">{l s='Top' mod='coolstats'} 100</button></li>
                </ul>
            </div>
            <div class="cs-top-term-sort">
                <span class="cs-top-term-sort-label{if $section_data.sort_mode != 'revenue'} cs-active{/if}" data-toggle-target="qty">{l s='Volume' mod='coolstats'}</span>
                <span class="cs-top-term-sort-label{if $section_data.sort_mode == 'revenue'} cs-active{/if}" data-toggle-target="revenue">{l s='CA' mod='coolstats'} &euro;</span>
                <div class="form-check form-switch mb-0">
                    <input class="form-check-input cs-filter" data-filter="sort" data-on-value="revenue" data-off-value="qty" type="checkbox" id="cs-top-mode-toggle" {if $section_data.sort_mode == 'revenue'}checked{/if}>
                </div>
            </div>
            <span class="cs-top-term-totals">·
                <b>{if $section_data.sort_mode == 'revenue'}{$section_data.totals.pct_revenue}{else}{$section_data.totals.pct_qty}{/if}%</b>
                {l s='du volume' mod='coolstats'} · {$section_data.totals.top_qty} {l s='u' mod='coolstats'} ·
                <span class="cs-top-term-totals-ca">{$section_data.totals.top_revenue|number_format:0:',':' '}&euro;</span>
            </span>
        </div>
    </div>

    {if $section_data.products|@count}
    <div class="table-responsive">
        <table class="cs-table cs-top-products-term-table">
            <thead>
                <tr>
                    <th style="width:30px">#</th>
                    <th>{l s='Produit' mod='coolstats'}</th>
                    <th class="text-nowrap" style="width:130px">{l s='Réf' mod='coolstats'}</th>
                    <th class="text-end text-nowrap" style="width:50px">{l s='U' mod='coolstats'}</th>
                    <th class="text-end text-nowrap" style="width:80px">{l s='CA' mod='coolstats'}</th>
                    <th class="text-nowrap" style="width:100px">{l s='Vol' mod='coolstats'}.</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.products item=p name=tploop}
                <tr>
                    <td>{$smarty.foreach.tploop.iteration|string_format:'%02d'}</td>
                    <td class="text-truncate" style="max-width:380px">
                        <a href="{$p.bo_link}" target="_blank" class="cs-top-term-name" title="{$p.name|escape:'html'}">{$p.name}</a>
                    </td>
                    <td class="cs-top-term-ref">{$p.reference|escape:'html':'UTF-8'}</td>
                    <td class="text-end cs-top-term-u">{$p.total_qty}</td>
                    <td class="text-end cs-top-term-ca">{$p.total_revenue|number_format:0:',':' '}&euro;</td>
                    <td class="cs-top-term-bar"></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {else}
    <div class="p-3 text-center cs-term-empty">{l s='Aucune donnée sur cette période' mod='coolstats'}</div>
    {/if}
</div>
