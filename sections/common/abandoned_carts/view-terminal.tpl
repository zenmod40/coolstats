{* ── Paniers abandonnés · Variante Terminal ──
 * 4 tiles KPI + table top 5 paniers à relancer.
 *}
<div class="cs-section cs-abandoned-section cs-abandoned-term" data-cs-section="abandoned_carts">
    <div class="cs-section-header">
        <span>🛒 {l s='Paniers abandonnés' mod='coolstats'}</span>
        {if $section_data.nb_abandoned > 0}
        <span class="cs-abandoned-term-badge{if $section_data.abandon_rate >= 70} cs-abandoned-term-badge--bad{elseif $section_data.abandon_rate < 40} cs-abandoned-term-badge--ok{/if}">
            {l s='Taux d\'abandon' mod='coolstats'} · {$section_data.abandon_rate}%
        </span>
        {/if}
    </div>

    {if $section_data.nb_abandoned == 0}
    <div class="cs-term-empty">✓ {l s='Aucun panier abandonné sur la période' mod='coolstats'}</div>
    {else}
    <div class="cs-abandoned-term-body">
        <div class="cs-abandoned-term-grid">
            <div class="cs-abandoned-term-tile">
                <span class="cs-abandoned-term-tile-icon">🛒</span>
                <div class="cs-abandoned-term-tile-body">
                    <div class="cs-abandoned-term-tile-v cs-abandoned-term-tile-v--bad">{$section_data.nb_abandoned|number_format:0:',':' '}</div>
                    <div class="cs-abandoned-term-tile-l">{l s='paniers abandonnés' mod='coolstats'}</div>
                </div>
            </div>
            <div class="cs-abandoned-term-tile">
                <span class="cs-abandoned-term-tile-icon cs-abandoned-term-tile-icon--bad">⊘</span>
                <div class="cs-abandoned-term-tile-body">
                    <div class="cs-abandoned-term-tile-v cs-abandoned-term-tile-v--amber">{$section_data.total_value_lost|number_format:0:',':' '}&euro;</div>
                    <div class="cs-abandoned-term-tile-l">{l s='CA potentiel perdu' mod='coolstats'}</div>
                </div>
            </div>
            <div class="cs-abandoned-term-tile">
                <span class="cs-abandoned-term-tile-icon">€</span>
                <div class="cs-abandoned-term-tile-body">
                    <div class="cs-abandoned-term-tile-v cs-abandoned-term-tile-v--amber">{$section_data.avg_cart_value|number_format:0:',':' '}&euro;</div>
                    <div class="cs-abandoned-term-tile-l">{l s='panier moyen abandonné' mod='coolstats'}</div>
                </div>
            </div>
            <div class="cs-abandoned-term-tile">
                <span class="cs-abandoned-term-tile-icon">📦</span>
                <div class="cs-abandoned-term-tile-body">
                    <div class="cs-abandoned-term-tile-v cs-abandoned-term-tile-v--good">{$section_data.total_items_lost|number_format:0:',':' '}</div>
                    <div class="cs-abandoned-term-tile-l">{l s='articles non vendus' mod='coolstats'}</div>
                </div>
            </div>
        </div>

        {if $section_data.top_abandoned|@count}
        <div class="cs-abandoned-term-top-h">{l s='TOP 5 PANIERS À RELANCER' mod='coolstats'} <span class="cs-abandoned-term-top-h-sub">({l s='LES PLUS CHERS' mod='coolstats'})</span></div>
        <table class="cs-abandoned-term-table">
            <thead>
                <tr>
                    <th style="width:30px">#</th>
                    <th>{l s='Client' mod='coolstats'}</th>
                    <th>{l s='Email' mod='coolstats'}</th>
                    <th style="width:120px">{l s='Créé le' mod='coolstats'}</th>
                    <th class="text-end" style="width:70px">{l s='Articles' mod='coolstats'}</th>
                    <th class="text-end" style="width:90px">{l s='Valeur HT' mod='coolstats'}</th>
                    <th style="width:30px"></th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.top_abandoned item=t name=ab}
                <tr>
                    <td class="cs-abandoned-term-rank">{$smarty.foreach.ab.iteration}</td>
                    <td class="cs-abandoned-term-customer{if $t.customer == '—'} cs-abandoned-term-empty-cell{/if}">{$t.customer|escape:'html':'UTF-8'}</td>
                    <td class="cs-abandoned-term-email{if !$t.email} cs-abandoned-term-empty-cell{/if}">{if $t.email}{$t.email|escape:'html':'UTF-8'}{else}—{/if}</td>
                    <td class="cs-abandoned-term-date">{$t.date_add}</td>
                    <td class="text-end cs-abandoned-term-qty">{$t.qty}</td>
                    <td class="text-end cs-abandoned-term-val">{$t.value_ht|number_format:0:',':' '}&euro;</td>
                    <td class="cs-abandoned-term-action">{if $t.bo_link}<a href="{$t.bo_link}" target="_blank" title="{l s='Voir le panier' mod='coolstats'}">✉</a>{else}✉{/if}</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {/if}
    </div>
    {/if}
</div>
