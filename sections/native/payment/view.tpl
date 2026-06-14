<div class="cs-section" data-cs-section="native_payment">
    <div class="cs-section-header"><span><i class="bi bi-credit-card"></i> {$section.title}</span>{if $section_data.methods|@count}<button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv title="Exporter en CSV"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>{/if}</div>
    {if $section_data.methods|@count}
    <div class="table-responsive">
        <table class="table table-sm cs-table mb-0">
            <thead>
                <tr>
                    <th>Moyen de paiement</th>
                    <th class="text-end">Commandes</th>
                    <th class="text-end">% du total</th>
                    <th class="text-end">CA</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$section_data.methods item=m}
                <tr>
                    <td>{$m.method|escape:'html':'UTF-8'}</td>
                    <td class="text-end fw-bold">{$m.orders_count}</td>
                    <td class="text-end">{$m.pct}%</td>
                    <td class="text-end">{$m.revenue|number_format:2:',':' '}&euro;</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {else}
    <div class="text-muted small">Aucune commande sur la période.</div>
    {/if}
</div>
