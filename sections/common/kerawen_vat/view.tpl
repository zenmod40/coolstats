{* data-csv : valeur brute exportée (décimales à la virgule, sans séparateur de milliers) *}
<div class="cs-section" data-cs-section="kerawen_vat">
    <div class="cs-section-header"><span><i class="bi bi-percent"></i> {$section.title}</span>{if $section_data.rows|@count}<button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv title="{l s='Exporter en CSV pour le comptable' mod='coolstats'}"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>{/if}</div>
    {if $section_data.rows|@count}
    <div class="table-responsive">
        <table class="table table-sm cs-table mb-0">
            <thead>
                <tr>
                    <th>{l s='Mois' mod='coolstats'}</th>
                    <th class="text-end">{l s='Taux TVA' mod='coolstats'}</th>
                    <th class="text-end">{l s='Total HT' mod='coolstats'}</th>
                    <th class="text-end">{l s='TVA' mod='coolstats'}</th>
                    <th class="text-end">{l s='Total TTC' mod='coolstats'}</th>
                    <th class="text-end">{l s='Magasin' mod='coolstats'} {$section_data.tax_label}</th>
                    <th class="text-end">{l s='Web' mod='coolstats'} {$section_data.tax_label}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.rows item=r}
                <tr>
                    <td data-csv="{$r.month}">{$r.month_label}</td>
                    <td class="text-end" data-csv="{$r.rate|number_format:2:',':''}">{$r.rate|number_format:2:',':' '}%</td>
                    <td class="text-end" data-csv="{$r.ht|number_format:2:',':''}">{$r.ht|number_format:2:',':' '}&euro;</td>
                    <td class="text-end fw-bold" data-csv="{$r.tax|number_format:2:',':''}">{$r.tax|number_format:2:',':' '}&euro;</td>
                    <td class="text-end" data-csv="{$r.ttc|number_format:2:',':''}">{$r.ttc|number_format:2:',':' '}&euro;</td>
                    <td class="text-end" data-csv="{$r.store|number_format:2:',':''}">{$r.store|number_format:2:',':' '}&euro;</td>
                    <td class="text-end" data-csv="{$r.web|number_format:2:',':''}">{$r.web|number_format:2:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
            <tfoot>
                <tr class="fw-bold">
                    <td colspan="2">{l s='Total période' mod='coolstats'}</td>
                    <td class="text-end">{$section_data.total.ht|number_format:2:',':' '}&euro;</td>
                    <td class="text-end">{$section_data.total.tax|number_format:2:',':' '}&euro;</td>
                    <td class="text-end">{$section_data.total.ttc|number_format:2:',':' '}&euro;</td>
                    <td class="text-end">{$section_data.total.store|number_format:2:',':' '}&euro;</td>
                    <td class="text-end">{$section_data.total.web|number_format:2:',':' '}&euro;</td>
                </tr>
            </tfoot>
        </table>
    </div>
    {else}
    <div class="text-muted small">{l s='Aucune vente caisse sur la période.' mod='coolstats'}</div>
    {/if}
</div>
