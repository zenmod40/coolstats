{* ── Paniers abandonnés · Variante Brutalist ── carte rose, stamp taux + grille stats + top *}
<div class="cs-section cs-abandoned-brutal cs-brutal-card-colored cs-brutal-card-pink" data-cs-section="abandoned_carts">
    <div class="cs-brutal-colored-title">
        <div class="cs-brutal-colored-t">⚠ {l s='Paniers abandonnés' mod='coolstats'}</div>
        {if $section_data.nb_abandoned > 0}
        <span class="cs-brutal-stamp">{l s='Taux' mod='coolstats'} {$section_data.abandon_rate}%</span>
        {/if}
    </div>

    {if $section_data.nb_abandoned == 0}
        <div class="cs-brutal-empty">✓ {l s='Aucun panier abandonné sur la période' mod='coolstats'}</div>
    {else}
    <div class="cs-abandoned-brutal-grid">
        <div class="cs-abandoned-brutal-stat">
            <div class="cs-abandoned-brutal-v">{$section_data.nb_abandoned|number_format:0:',':' '}</div>
            <div class="cs-abandoned-brutal-l">{l s='Paniers abandonnés' mod='coolstats'}</div>
        </div>
        <div class="cs-abandoned-brutal-stat">
            <div class="cs-abandoned-brutal-v">{$section_data.avg_cart_value|number_format:0:',':' '}&euro;</div>
            <div class="cs-abandoned-brutal-l">{l s='Panier moyen abandonné' mod='coolstats'}</div>
        </div>
        <div class="cs-abandoned-brutal-stat">
            <div class="cs-abandoned-brutal-v">{$section_data.total_items_lost|number_format:0:',':' '}</div>
            <div class="cs-abandoned-brutal-l">{l s='Articles non vendus' mod='coolstats'}</div>
        </div>
        <div class="cs-abandoned-brutal-stat">
            <div class="cs-abandoned-brutal-v">{$section_data.total_value_lost|number_format:0:',':' '}&euro;</div>
            <div class="cs-abandoned-brutal-l">{l s='CA potentiel perdu' mod='coolstats'}</div>
        </div>
    </div>

    {if $section_data.top_abandoned|@count}
    <div class="cs-abandoned-brutal-top">
        <div class="cs-abandoned-brutal-top-h">{l s='Top 5 paniers à relancer' mod='coolstats'}</div>
        {foreach from=$section_data.top_abandoned item=t name=ab}
        {if $t.bo_link}<a href="{$t.bo_link}" target="_blank" class="cs-abandoned-brutal-cart">
        {else}<div class="cs-abandoned-brutal-cart">{/if}
            <span class="cs-abandoned-brutal-r">{$smarty.foreach.ab.iteration|string_format:'%02d'}</span>
            <span class="cs-abandoned-brutal-n">{$t.customer|escape:'html':'UTF-8'}</span>
            <span class="cs-abandoned-brutal-v">{$t.value_ht|number_format:0:',':' '}&euro;</span>
        {if $t.bo_link}</a>{else}</div>{/if}
        {/foreach}
    </div>
    {/if}
    {/if}
</div>
