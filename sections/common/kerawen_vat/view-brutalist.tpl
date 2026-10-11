{* ── TVA caisse par mois · Variante Brutalist ── (table de la section Commandes) *}
<div class="cs-section cs-customers-brutal" data-cs-section="kerawen_vat">
    <div class="cs-customers-brutal-header">
        <span class="cs-customers-brutal-badge">% {l s='TVA caisse par mois' mod='coolstats'}</span>
        <div class="cs-customers-brutal-rule"></div>
        {if $section_data.rows|@count}<button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv title="{l s='Exporter en CSV pour le comptable' mod='coolstats'}"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>{/if}
    </div>
    {if $section_data.rows|@count}
    <table class="cs-orders-brutal-table">
        <thead>
            <tr>
                <th>{l s='Mois' mod='coolstats'}</th>
                <th>{l s='Taux TVA' mod='coolstats'}</th>
                <th>{l s='Total HT' mod='coolstats'}</th>
                <th>{l s='TVA' mod='coolstats'}</th>
                <th>{l s='Total TTC' mod='coolstats'}</th>
                <th>{l s='Magasin' mod='coolstats'} {$section_data.tax_label}</th>
                <th>{l s='Web' mod='coolstats'} {$section_data.tax_label}</th>
            </tr>
        </thead>
        <tbody>
            {foreach from=$section_data.rows item=r}
            <tr>
                <td data-csv="{$r.month}">{$r.month_label}</td>
                <td data-csv="{$r.rate|number_format:2:',':''}">{$r.rate|number_format:2:',':' '}%</td>
                <td data-csv="{$r.ht|number_format:2:',':''}">{$r.ht|number_format:2:',':' '}&euro;</td>
                <td data-csv="{$r.tax|number_format:2:',':''}">{$r.tax|number_format:2:',':' '}&euro;</td>
                <td data-csv="{$r.ttc|number_format:2:',':''}">{$r.ttc|number_format:2:',':' '}&euro;</td>
                <td data-csv="{$r.store|number_format:2:',':''}">{$r.store|number_format:2:',':' '}&euro;</td>
                <td data-csv="{$r.web|number_format:2:',':''}">{$r.web|number_format:2:',':' '}&euro;</td>
            </tr>
            {/foreach}
        </tbody>
        <tfoot>
            <tr>
                <th colspan="2">{l s='Total période' mod='coolstats'}</th>
                <th>{$section_data.total.ht|number_format:2:',':' '}&euro;</th>
                <th>{$section_data.total.tax|number_format:2:',':' '}&euro;</th>
                <th>{$section_data.total.ttc|number_format:2:',':' '}&euro;</th>
                <th>{$section_data.total.store|number_format:2:',':' '}&euro;</th>
                <th>{$section_data.total.web|number_format:2:',':' '}&euro;</th>
            </tr>
        </tfoot>
    </table>
    {else}
    <div class="cs-customers-brutal-label" style="max-width:none">{l s='Aucune vente caisse sur la période.' mod='coolstats'}</div>
    {/if}
</div>
