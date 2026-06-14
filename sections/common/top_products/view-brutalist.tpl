{* ── Top produits · Variante Brutalist ──
 * Badge jaune "★ TOP X PRODUITS", totaux JetBrains Mono à droite,
 * grille 2 colonnes, lignes avec rang noir/jaune, barre de progression colorée,
 * prix Archivo Black + quantité JetBrains Mono.
 *}
{assign var=cs_top_max value=0}
{foreach from=$section_data.products item=p}
    {if $section_data.sort_mode == 'revenue'}
        {if $p.total_revenue > $cs_top_max}{assign var=cs_top_max value=$p.total_revenue}{/if}
    {else}
        {if $p.total_qty > $cs_top_max}{assign var=cs_top_max value=$p.total_qty}{/if}
    {/if}
{/foreach}
{if $cs_top_max == 0}{assign var=cs_top_max value=1}{/if}

<div class="cs-section cs-top-products cs-top-products-brutal" data-cs-section="top_products">
    <div class="cs-top-brutal-header">
        <span class="cs-top-brutal-badge">★ {l s='Top' mod='coolstats'} {$section_data.limit} {l s='Produits' mod='coolstats'}</span>
        <div class="cs-top-brutal-controls">
            <div class="dropdown cs-pill-dropdown cs-top-brutal-limit" data-filter="top_limit">
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
            <div class="cs-top-brutal-sort" data-cs-toggle-mode="top">
                <span class="cs-top-brutal-sort-label{if $section_data.sort_mode != 'revenue'} cs-active{/if}" data-toggle-target="qty">{l s='Volume' mod='coolstats'}</span>
                <span class="cs-top-brutal-sort-label{if $section_data.sort_mode == 'revenue'} cs-active{/if}" data-toggle-target="revenue">{l s='CA' mod='coolstats'} &euro;</span>
                <div class="form-check form-switch mb-0">
                    <input class="form-check-input cs-filter" data-filter="sort" data-on-value="revenue" data-off-value="qty" type="checkbox" id="cs-top-mode-toggle" {if $section_data.sort_mode == 'revenue'}checked{/if}>
                </div>
            </div>
            <div class="cs-top-brutal-totals">
                <b>{if $section_data.sort_mode == 'revenue'}{$section_data.totals.pct_revenue}{else}{$section_data.totals.pct_qty}{/if}%</b>
                {l s='du volume' mod='coolstats'} · {$section_data.totals.top_qty} {l s='u' mod='coolstats'} ·
                <b class="cs-top-brutal-totals-amount">{$section_data.totals.top_revenue|number_format:0:',':' '}&euro;</b>
            </div>
        </div>
    </div>

    {if $section_data.products|@count}
    <div class="cs-top-brutal-grid">
        {foreach from=$section_data.products item=p name=tploop}
        {if $section_data.sort_mode == 'revenue'}
            {assign var=cs_bar_pct value=($p.total_revenue * 100) / $cs_top_max}
        {else}
            {assign var=cs_bar_pct value=($p.total_qty * 100) / $cs_top_max}
        {/if}
        <a href="{$p.bo_link}" target="_blank" class="cs-top-brutal-row" title="{$p.name|escape:'html'}">
            <span class="cs-top-brutal-rank">{$smarty.foreach.tploop.iteration}</span>
            <div class="cs-top-brutal-body">
                <div class="cs-top-brutal-name">{$p.name|escape:'html':'UTF-8'}</div>
                <div class="cs-top-brutal-bar">
                    <div class="cs-top-brutal-bar-fill" style="width:{$cs_bar_pct|string_format:'%.2f'}%"></div>
                </div>
            </div>
            <div class="cs-top-brutal-right">
                <div class="cs-top-brutal-price">{$p.total_revenue|number_format:0:',':' '}&euro;</div>
                <div class="cs-top-brutal-qty">{$p.total_qty} {l s='u.' mod='coolstats'}</div>
            </div>
        </a>
        {/foreach}
    </div>
    {else}
    <div class="p-3 text-center text-muted small">{l s='Aucune donnée sur cette période' mod='coolstats'}</div>
    {/if}
</div>
