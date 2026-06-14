{* ── Section Marges brutes ── *}
<div class="cs-section cs-margins-section" data-cs-section="margins">
    <div class="cs-section-header">
        <span><i class="bi bi-graph-up"></i> {$section.title}</span>
        {if $section_data.coverage_pct < 100}
            <span class="badge cs-coverage-badge {if $section_data.coverage_pct < 50}cs-coverage-low{elseif $section_data.coverage_pct < 80}cs-coverage-mid{else}cs-coverage-high{/if}"
                  title="{$section_data.qty_with_cost|number_format:0:',':' '} / {$section_data.qty_total|number_format:0:',':' '} unités avec prix d'achat renseigné">
                <i class="bi bi-info-circle"></i> Couverture {$section_data.coverage_pct}%
            </span>
        {/if}
        {if $section_data.top_margin|@count}<button type="button" class="btn btn-sm btn-outline-secondary cs-export-csv-btn" data-cs-csv title="Exporter en CSV"><i class="bi bi-file-earmark-spreadsheet"></i> CSV</button>{/if}
    </div>

    {if $section_data.ca_products_ht <= 0}
        <div class="cs-margins-empty text-muted small text-center py-3">
            Aucune commande valide sur la période.
        </div>
    {elseif $section_data.coverage_pct == 0}
        <div class="cs-margins-empty py-3 text-center">
            <i class="bi bi-info-circle text-muted"></i>
            <div class="mt-2">
                <strong>Marges indisponibles.</strong>
                <p class="small text-muted mb-0">Le calcul nécessite le prix d'achat (<code>wholesale_price</code>) des produits. Dès qu'il est renseigné — via PrestaShop ou votre outil de gestion (Store Commander, ERP…) — les marges s'affichent ici automatiquement.</p>
            </div>
        </div>
    {else}
        <div class="row g-3">
            <div class="col-xl-4 col-md-6 col-sm-12">
                <div class="cs-margin-stat cs-margin-stat-main">
                    <div class="cs-margin-stat-label">Marge brute</div>
                    <div class="cs-margin-stat-value">{$section_data.margin_ht|number_format:0:',':' '}&euro;</div>
                    <div class="cs-margin-stat-pct">
                        {if $section_data.margin_pct >= 30}<span class="cs-margin-good">{$section_data.margin_pct}% du CA</span>
                        {elseif $section_data.margin_pct >= 15}<span class="cs-margin-mid">{$section_data.margin_pct}% du CA</span>
                        {else}<span class="cs-margin-low">{$section_data.margin_pct}% du CA</span>{/if}
                    </div>
                </div>
            </div>
            <div class="col-xl-4 col-md-6 col-sm-12">
                <div class="cs-margin-stat">
                    <div class="cs-margin-stat-label">CA produits HT</div>
                    <div class="cs-margin-stat-value cs-margin-stat-secondary">{$section_data.ca_products_ht|number_format:0:',':' '}&euro;</div>
                    <div class="cs-margin-stat-pct text-muted small">Hors frais de port</div>
                </div>
            </div>
            <div class="col-xl-4 col-md-12 col-sm-12">
                <div class="cs-margin-stat">
                    <div class="cs-margin-stat-label">Coût d'achat total</div>
                    <div class="cs-margin-stat-value cs-margin-stat-secondary">{$section_data.cost_ht|number_format:0:',':' '}&euro;</div>
                    <div class="cs-margin-stat-pct text-muted small">{$section_data.qty_with_cost|number_format:0:',':' '} unités</div>
                </div>
            </div>
        </div>

        {if $section_data.top_margin|@count}
        <div class="cs-margin-top mt-3">
            <div class="cs-margin-top-title">Top 5 contributeurs de marge</div>
            <table class="table table-sm cs-table mb-0">
                <thead>
                    <tr>
                        <th style="width:42px">#</th>
                        <th>Produit</th>
                        <th class="text-end">Qté</th>
                        <th class="text-end">CA HT</th>
                        <th class="text-end">Marge €</th>
                        <th class="text-end">Marge %</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach from=$section_data.top_margin item=p key=i}
                    <tr>
                        <td><span class="cs-margin-rank">{$i+1}</span></td>
                        <td class="cs-margin-prod-name">{$p.name|escape:'html'}</td>
                        <td class="text-end">{$p.qty|number_format:0:',':' '}</td>
                        <td class="text-end">{$p.ca_ht|number_format:0:',':' '}&euro;</td>
                        <td class="text-end fw-bold">{$p.margin|number_format:0:',':' '}&euro;</td>
                        <td class="text-end">
                            {if $p.margin_pct >= 30}<span class="cs-margin-good">{$p.margin_pct}%</span>
                            {elseif $p.margin_pct >= 15}<span class="cs-margin-mid">{$p.margin_pct}%</span>
                            {else}<span class="cs-margin-low">{$p.margin_pct}%</span>{/if}
                        </td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
        {/if}
    {/if}
</div>
