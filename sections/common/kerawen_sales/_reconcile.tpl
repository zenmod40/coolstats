{* Rapprochement CA fiscal / CA commandes, partagé par les trois thèmes. Détail au clic (élément natif <details>). *}
{assign var=rc value=$section_data.reconcile}
<details class="cs-kerawen-reconcile">
    <summary>
        {l s='Écart avec le CA commandes :' mod='coolstats'} <strong>{if $rc.gap > 0}+{/if}{$rc.gap|number_format:2:',':' '}&euro;</strong>
        <span class="cs-kerawen-reconcile-hint">· {l s='CA commandes' mod='coolstats'} {$rc.orders_ca|number_format:2:',':' '}&euro;, {l s='CA fiscal' mod='coolstats'} {$section_data.total|number_format:2:',':' '}&euro; · {l s='détail' mod='coolstats'}</span>
    </summary>
    <ul>
        <li>{l s='Avoirs et corrections sur des commandes d\'autres périodes' mod='coolstats'} : {if $rc.a > 0}+{/if}{$rc.a|number_format:2:',':' '}&euro;</li>
        <li>{l s='Commandes non comptées par CoolStats' mod='coolstats'}{if $rc.b_states} ({l s='état :' mod='coolstats'} {$rc.b_states|escape:'html':'UTF-8'}){/if} : {if $rc.b > 0}+{/if}{$rc.b|number_format:2:',':' '}&euro;</li>
        <li>{l s='Commandes sans écriture fiscale sur la période' mod='coolstats'} : {if $rc.c > 0}+{/if}{$rc.c|number_format:2:',':' '}&euro;</li>
        {if $rc.d != 0}<li>{l s='Autres écarts (frais de port exclus, montants différents…)' mod='coolstats'} : {if $rc.d > 0}+{/if}{$rc.d|number_format:2:',':' '}&euro;</li>{/if}
    </ul>
    <p>{l s='Le CA commandes compte les commandes créées sur la période, à leur montant actuel. Le CA fiscal compte les ventes, avoirs et corrections enregistrés par la caisse sur la période : c\'est la référence pour la comptabilité et la TVA.' mod='coolstats'}</p>
</details>
