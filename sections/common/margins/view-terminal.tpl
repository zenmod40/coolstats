{* ── Marges brutes · Variante Terminal ──
 * Header + état empty avec CTA si pas de couverture, sinon stats.
 *}
<div class="cs-section cs-margins-section cs-margins-term" data-cs-section="margins">
    <div class="cs-section-header">
        <span>% {l s='Marges brutes' mod='coolstats'}</span>
        {if $section_data.coverage_pct < 100}
        <span class="cs-margins-term-cov{if $section_data.coverage_pct < 50} cs-margins-term-cov--bad{elseif $section_data.coverage_pct < 80} cs-margins-term-cov--warn{/if}">
            ⊘ {l s='Couverture' mod='coolstats'} {$section_data.coverage_pct}%
        </span>
        {/if}
    </div>

    {if $section_data.ca_products_ht <= 0}
    <div class="cs-margins-term-empty">
        <div class="cs-margins-term-h">{l s='Aucune commande valide sur la période' mod='coolstats'}</div>
    </div>
    {elseif $section_data.coverage_pct == 0}
    <div class="cs-margins-term-empty">
        <div class="cs-margins-term-warn">⚠</div>
        <div class="cs-margins-term-title">{l s='Marges indisponibles' mod='coolstats'}</div>
        <div class="cs-margins-term-desc">
            {l s='Le calcul nécessite le prix d\'achat' mod='coolstats'}
            (<span class="cs-margins-term-code">wholesale_price</span>)
            {l s='des produits. Dès qu\'il est renseigné — via PrestaShop ou votre outil de gestion — les marges s\'affichent ici automatiquement.' mod='coolstats'}
        </div>
    </div>
    {else}
    <div class="cs-margins-term-body">
        <div class="cs-margins-term-grid">
            <div class="cs-margins-term-stat cs-margins-term-stat--main">
                <div class="cs-margins-term-stat-l">{l s='Marge brute' mod='coolstats'}</div>
                <div class="cs-margins-term-stat-v">{$section_data.margin_ht|number_format:0:',':' '}&euro;</div>
                <div class="cs-margins-term-stat-sub">{$section_data.margin_pct}% {l s='du CA' mod='coolstats'}</div>
            </div>
            <div class="cs-margins-term-stat">
                <div class="cs-margins-term-stat-l">{l s='CA produits HT' mod='coolstats'}</div>
                <div class="cs-margins-term-stat-v">{$section_data.ca_products_ht|number_format:0:',':' '}&euro;</div>
            </div>
            <div class="cs-margins-term-stat">
                <div class="cs-margins-term-stat-l">{l s='Coût d\'achat' mod='coolstats'}</div>
                <div class="cs-margins-term-stat-v">{$section_data.cost_ht|number_format:0:',':' '}&euro;</div>
                <div class="cs-margins-term-stat-sub">{$section_data.qty_with_cost|number_format:0:',':' '} {l s='unités' mod='coolstats'}</div>
            </div>
        </div>
        {if $section_data.top_margin|@count}
        <div class="cs-margins-term-top">
            <div class="cs-margins-term-top-h">// {l s='top contributeurs marge' mod='coolstats'}</div>
            {foreach from=$section_data.top_margin item=c name=mc}
            <div class="cs-margins-term-row">
                <span class="cs-margins-term-row-r">{$smarty.foreach.mc.iteration|string_format:'%02d'}</span>
                <span class="cs-margins-term-row-n">{$c.name|escape:'html':'UTF-8'}</span>
                <span class="cs-margins-term-row-v">{$c.margin|number_format:0:',':' '}&euro;</span>
            </div>
            {/foreach}
        </div>
        {/if}
    </div>
    {/if}
</div>
