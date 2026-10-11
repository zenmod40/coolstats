{* Liste des quatre contrôles, partagée par les trois thèmes. *}
{foreach from=$section_data.checks key=k item=c}
<div class="cs-kerawen-check cs-kerawen--{$c.status}">
    <div class="cs-kerawen-check-head">
        <span class="cs-kerawen-dot"></span>
        <strong>
            {if $k == 'collision'}{l s='Collision d\'identifiants' mod='coolstats'}
            {elseif $k == 'lines'}{l s='Ventes et lignes d\'articles' mod='coolstats'}
            {elseif $k == 'missing'}{l s='Ventes caisse absentes du journal' mod='coolstats'}
            {else}{l s='Trou dans le journal des ventes' mod='coolstats'}{/if}
        </strong>
        {if $c.status == 'ko'}<span class="cs-kerawen-figures">{$c.count|number_format:0:',':' '} {if $k == 'lines'}{l s='mois' mod='coolstats'}{elseif $c.count > 1}{if $k == 'collision'}{l s='lignes' mod='coolstats'}{elseif $k == 'missing'}{l s='commandes' mod='coolstats'}{else}{l s='trous' mod='coolstats'}{/if}{else}{if $k == 'collision'}{l s='ligne' mod='coolstats'}{elseif $k == 'missing'}{l s='commande' mod='coolstats'}{else}{l s='trou' mod='coolstats'}{/if}{/if} · {$c.amount|number_format:2:',':' '}&euro; TTC</span>{/if}
    </div>
    <div class="cs-kerawen-check-text">
        {if $c.status == 'error'}
            {l s='Contrôle impossible : les tables Kerawen n\'ont pas la structure attendue.' mod='coolstats'}
        {elseif $c.status == 'ok'}
            {if $k == 'collision'}{l s='Chaque ligne d\'article appartient à la vente de sa propre commande.' mod='coolstats'}
            {elseif $k == 'lines'}{l s='Chaque mois, le total des ventes égale la somme de leurs lignes d\'articles.' mod='coolstats'}
            {elseif $k == 'missing'}{l s='Toutes les commandes caisse validées dans PrestaShop ont leur écriture Kerawen.' mod='coolstats'}
            {else}{l s='Aucune interruption du journal pendant que PrestaShop recevait des commandes' mod='coolstats'} ({l s='seuil' mod='coolstats'} {$section_data.threshold} {l s='jours' mod='coolstats'}).{/if}
        {else}
            {if $k == 'collision'}{l s='Des lignes d\'articles sont rattachées, par leur commande, à la vente d\'une autre commande : le CA calculé par Kerawen est faux.' mod='coolstats'}
            {elseif $k == 'lines'}{l s='Sur ces mois, le total des ventes diffère de la somme de leurs lignes d\'articles : le CA affiché par Kerawen ne correspond pas aux ventes enregistrées.' mod='coolstats'}
            {elseif $k == 'missing'}{l s='Des commandes caisse validées dans PrestaShop n\'ont aucune écriture dans le journal fiscal Kerawen.' mod='coolstats'}
            {else}{l s='Kerawen n\'a enregistré aucune vente pendant plus de' mod='coolstats'} {$section_data.threshold} {l s='jours alors que PrestaShop recevait des commandes.' mod='coolstats'}{/if}
        {/if}
    </div>
    {if $c.status == 'ko' && $c.details|@count}
    <ul class="cs-kerawen-details">
        {foreach from=$c.details item=d name=dl}{if $smarty.foreach.dl.index < 12}
        <li>
            {if $k == 'lines'}{$d.month} : {l s='ventes' mod='coolstats'} {$d.sales|number_format:2:',':' '}&euro;, {l s='lignes' mod='coolstats'} {$d.lines|number_format:2:',':' '}&euro; ({if $d.diff > 0}+{/if}{$d.diff|number_format:2:',':' '}&euro;)
            {elseif $k == 'missing'}{$d.month} : {$d.count} {l s='commandes' mod='coolstats'}, {$d.amount|number_format:2:',':' '}&euro;
            {else}{$d.from|date_format:'%d/%m/%Y'} → {$d.to|date_format:'%d/%m/%Y'} : {$d.days} {l s='jours' mod='coolstats'}, {$d.orders} {l s='commandes PrestaShop' mod='coolstats'}{/if}
        </li>
        {/if}{/foreach}
        {if $c.details|@count > 12}<li>… {l s='et' mod='coolstats'} {$c.details|@count - 12} {l s='autres' mod='coolstats'}</li>{/if}
    </ul>
    {/if}
</div>
{/foreach}
