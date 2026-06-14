{* ── Section Paniers abandonnés ── *}
<div class="cs-section cs-abandoned-section" data-cs-section="abandoned_carts">
    <div class="cs-section-header">
        <span><i class="bi bi-cart-x"></i> {$section.title}</span>
        {if $section_data.nb_abandoned > 0}
            <span class="badge cs-abandon-rate-badge
                {if $section_data.abandon_rate >= 70}cs-abandon-bad
                {elseif $section_data.abandon_rate >= 40}cs-abandon-warn
                {else}cs-abandon-ok{/if}">
                Taux d'abandon : {$section_data.abandon_rate}%
            </span>
        {/if}
        {if $section_data.nb_abandoned > 0}<button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv title="Exporter en CSV"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>{/if}
    </div>

    {if $section_data.nb_abandoned == 0}
        <div class="text-center text-muted py-3">
            <i class="bi bi-check-circle fs-3 d-block mb-2"></i>
            Aucun panier abandonné sur la période. 🎉
        </div>
    {else}
        <div class="row g-3">
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-abandon-kpi">
                    <i class="bi bi-cart-x cs-abandon-kpi-icon"></i>
                    <div>
                        <div class="cs-abandon-kpi-value">{$section_data.nb_abandoned|number_format:0:',':' '}</div>
                        <div class="cs-abandon-kpi-label">Paniers abandonnés</div>
                    </div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-abandon-kpi">
                    <i class="bi bi-cash-coin cs-abandon-kpi-icon cs-abandon-loss"></i>
                    <div>
                        <div class="cs-abandon-kpi-value cs-abandon-loss">{$section_data.total_value_lost|number_format:0:',':' '}&euro;</div>
                        <div class="cs-abandon-kpi-label">CA potentiel perdu</div>
                    </div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-abandon-kpi">
                    <i class="bi bi-currency-euro cs-abandon-kpi-icon"></i>
                    <div>
                        <div class="cs-abandon-kpi-value">{$section_data.avg_cart_value|number_format:0:',':' '}&euro;</div>
                        <div class="cs-abandon-kpi-label">Panier moyen abandonné</div>
                    </div>
                </div>
            </div>
            <div class="col-xl col-md-4 col-sm-6">
                <div class="cs-abandon-kpi">
                    <i class="bi bi-bag cs-abandon-kpi-icon"></i>
                    <div>
                        <div class="cs-abandon-kpi-value">{$section_data.total_items_lost|number_format:0:',':' '}</div>
                        <div class="cs-abandon-kpi-label">Articles non vendus</div>
                    </div>
                </div>
            </div>
        </div>

        {if $section_data.top_abandoned|@count}
        <div class="cs-abandon-top mt-3">
            <div class="cs-margin-top-title">Top 5 paniers à relancer (les plus chers)</div>
            <table class="table table-sm cs-table mb-0">
                <thead>
                    <tr>
                        <th style="width:42px">#</th>
                        <th>Client</th>
                        <th>Email</th>
                        <th class="text-nowrap">Créé le</th>
                        <th class="text-end">Articles</th>
                        <th class="text-end">Valeur HT</th>
                        <th style="width:80px"></th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$section_data.top_abandoned item=c key=i}
                    <tr data-cs-cart-row="{$c.id_cart}">
                        <td><span class="cs-margin-rank">{$i+1}</span></td>
                        <td>{$c.customer|escape:'html'}</td>
                        <td class="small text-muted">{$c.email|escape:'html'}</td>
                        <td class="small text-muted">{$c.date_add}</td>
                        <td class="text-end">{$c.qty|number_format:0:',':' '}</td>
                        <td class="text-end fw-bold">{$c.value_ht|number_format:0:',':' '}&euro;</td>
                        <td class="text-nowrap">
                            <a href="{$c.bo_link|escape:'html'}" target="_blank"
                               class="cs-abandon-action" title="Voir le panier dans le BO">
                                <i class="bi bi-eye"></i>
                            </a>
                            <button type="button"
                                    class="cs-abandon-action cs-abandon-delete"
                                    data-cs-delete-cart="{$c.id_cart}"
                                    data-cs-cart-customer="{$c.customer|escape:'html'}"
                                    data-cs-cart-value="{$c.value_ht|number_format:0:',':' '}"
                                    title="Supprimer ce panier abandonné">
                                <i class="bi bi-trash"></i>
                            </button>
                        </td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
        {/if}
    {/if}
</div>
