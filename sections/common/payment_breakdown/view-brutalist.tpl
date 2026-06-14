{* ── Moyens de paiement · Variante Brutalist ──
 * Carte jaune, titre "€ MOYENS DE PAIEMENT", barres horizontales noires (HTML pur).
 *}
{assign var=cs_pay_total value=0}
{foreach from=$section_data.breakdown item=b}
    {assign var=cs_pay_total value=$cs_pay_total + $b.orders}
{/foreach}
{if $cs_pay_total == 0}{assign var=cs_pay_total value=1}{/if}

<div class="cs-section cs-payment-brutal" data-cs-section="payment_breakdown">
    <div class="cs-payment-brutal-title">&euro; {l s='Moyens de paiement' mod='coolstats'}</div>
    {foreach from=$section_data.breakdown item=b}
        {assign var=cs_pct value=($b.orders * 100) / $cs_pay_total}
        <div class="cs-payment-brutal-row">
            <div class="cs-payment-brutal-line">
                <span class="cs-payment-brutal-label">{$b.label}</span>
                <span class="cs-payment-brutal-right">
                    <span class="cs-payment-brutal-amt">{$b.revenue|number_format:2:',':' '}&euro;</span>
                    <span class="cs-payment-brutal-pct">{$cs_pct|string_format:'%.1f'}%</span>
                </span>
            </div>
            <div class="cs-payment-brutal-bar">
                <div class="cs-payment-brutal-bar-fill" style="width:{$cs_pct|string_format:'%.2f'}%"></div>
            </div>
        </div>
    {/foreach}
</div>
