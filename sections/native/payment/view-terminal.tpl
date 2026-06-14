{* ── Répartition par moyen de paiement · Variante Terminal ── *}
<div class="cs-section cs-native-payment-term" data-cs-section="native_payment">
    <div class="cs-section-header">
        <span>€ {l s='Répartition par moyen de paiement' mod='coolstats'}</span>
    </div>
    {if $section_data.methods|@count}
    <div class="cs-native-payment-term-body">
        <table class="cs-native-payment-term-table">
            <thead>
                <tr>
                    <th>{l s='Moyen de paiement' mod='coolstats'}</th>
                    <th class="text-end" style="width:120px">{l s='Commandes' mod='coolstats'}</th>
                    <th class="text-end" style="width:120px">{l s='% du total' mod='coolstats'}</th>
                    <th class="text-end" style="width:100px">{l s='CA' mod='coolstats'}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.methods item=m}
                <tr>
                    <td class="cs-native-payment-term-method">{$m.method|escape:'html':'UTF-8'}</td>
                    <td class="text-end cs-native-payment-term-orders">{$m.orders_count}</td>
                    <td class="text-end cs-native-payment-term-pct">{$m.pct}%</td>
                    <td class="text-end cs-native-payment-term-ca">{$m.revenue|number_format:2:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {else}
    <div class="cs-term-empty">{l s='Aucune commande sur la période' mod='coolstats'}</div>
    {/if}
</div>
