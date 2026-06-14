{* ── Marges brutes · Variante Brutalist ── carte verte, titre simple + tag selon couverture *}
<div class="cs-section cs-margins-brutal cs-brutal-card-colored cs-brutal-card-green" data-cs-section="margins">
    <div class="cs-brutal-colored-title">
        <div class="cs-brutal-colored-t">% {l s='Marges brutes' mod='coolstats'}</div>
        {if $section_data.coverage_pct < 100}
        <span class="cs-brutal-tag {if $section_data.coverage_pct < 50}cs-brutal-tag-red{elseif $section_data.coverage_pct < 80}cs-brutal-tag-pink{else}cs-brutal-tag-dark{/if}">
            {l s='Couverture' mod='coolstats'} {$section_data.coverage_pct}%
        </span>
        {/if}
    </div>

    {if $section_data.ca_products_ht <= 0}
    <div class="cs-margins-brutal-empty">
        <div class="cs-margins-brutal-h">{l s='Aucune commande valide sur la période' mod='coolstats'}</div>
    </div>
    {elseif $section_data.coverage_pct == 0}
    <div class="cs-margins-brutal-empty">
        <div class="cs-margins-brutal-h">⚠ {l s='Prix d\'achat non renseignés' mod='coolstats'}</div>
        <div class="cs-margins-brutal-path">
            {l s='CATALOGUE' mod='coolstats'} › <strong>{l s='PRODUIT' mod='coolstats'}</strong> › {l s='PRIX' mod='coolstats'} › <strong>WHOLESALE_PRICE</strong>
        </div>
    </div>
    {else}
    <div class="cs-margins-brutal-grid">
        <div class="cs-margins-brutal-stat cs-margins-brutal-stat-main">
            <div class="cs-margins-brutal-l">{l s='Marge brute' mod='coolstats'}</div>
            <div class="cs-margins-brutal-v">{$section_data.margin_ht|number_format:0:',':' '}&euro;</div>
            <div class="cs-margins-brutal-sub">{$section_data.margin_pct}% {l s='du CA' mod='coolstats'}</div>
        </div>
        <div class="cs-margins-brutal-stat">
            <div class="cs-margins-brutal-l">{l s='CA produits HT' mod='coolstats'}</div>
            <div class="cs-margins-brutal-v">{$section_data.ca_products_ht|number_format:0:',':' '}&euro;</div>
        </div>
        <div class="cs-margins-brutal-stat">
            <div class="cs-margins-brutal-l">{l s='Coût d\'achat' mod='coolstats'}</div>
            <div class="cs-margins-brutal-v">{$section_data.cost_ht|number_format:0:',':' '}&euro;</div>
            <div class="cs-margins-brutal-sub">{$section_data.qty_with_cost|number_format:0:',':' '} {l s='unités' mod='coolstats'}</div>
        </div>
    </div>

    {if $section_data.top_margin|@count}
    <div class="cs-margins-brutal-top">
        <div class="cs-margins-brutal-top-h">{l s='Top contributeurs marge' mod='coolstats'}</div>
        {foreach from=$section_data.top_margin item=c name=mc}
        <div class="cs-margins-brutal-row">
            <span class="cs-margins-brutal-row-r">{$smarty.foreach.mc.iteration|string_format:'%02d'}</span>
            <span class="cs-margins-brutal-row-n">{$c.name|escape:'html':'UTF-8'}</span>
            <span class="cs-margins-brutal-row-v">{$c.margin|number_format:0:',':' '}&euro;</span>
        </div>
        {/foreach}
    </div>
    {/if}
    {/if}
</div>
