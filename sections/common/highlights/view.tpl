{function name=cs_highlight_prod h=null type=null}
    <a href="{$h.bo_link}" target="_blank" class="d-flex align-items-center gap-3 text-decoration-none cs-highlight-prod">
        {if $h.image}
            <img src="{$h.image}" alt="" class="rounded" style="width:48px;height:48px;object-fit:cover">
        {else}
            <div class="rounded bg-secondary d-flex align-items-center justify-content-center" style="width:48px;height:48px"><i class="bi bi-image text-muted"></i></div>
        {/if}
        <div class="flex-grow-1 min-width-0">
            <div class="fw-bold small text-truncate" title="{$h.name|escape:'html':'UTF-8'}">{$h.name|escape:'html':'UTF-8'}</div>
            <div class="text-muted" style="font-size:11px">{if $h.reference}Réf. {$h.reference|escape:'html':'UTF-8'}{/if}</div>
        </div>
    </a>
    <div class="d-flex gap-3 mt-2 small">
        <div>
            <div class="fw-bold">{$h.qty}</div>
            <div class="text-muted" style="font-size:10px">{if $type == 'watch'}unités{else}vendus{/if}</div>
        </div>
        {if $type == 'watch'}
        <div>
            <div class="fw-bold text-danger">{$h.return_rate}%</div>
            <div class="text-muted" style="font-size:10px">retour</div>
        </div>
        {/if}
        <div>
            <div class="fw-bold {if $h.growth > 0}text-success{elseif $h.growth < 0}text-danger{else}text-muted{/if}">{if $h.growth > 0}+{/if}{$h.growth}%</div>
            <div class="text-muted" style="font-size:10px">vs n-1</div>
        </div>
    </div>
{/function}

<div class="cs-highlights-row" data-cs-section="highlights">
    <div class="row g-3">
        <div class="col-xl-4 col-md-6">
            <div class="cs-highlight-card cs-highlight-star">
                <div class="cs-highlight-header">
                    <span class="cs-highlight-icon"><i class="bi bi-star-fill"></i></span>
                    <span class="cs-highlight-title">Produit star</span>
                </div>
                <div class="cs-highlight-body">
                    {if $section_data.star}
                        {call name=cs_highlight_prod h=$section_data.star type='star'}
                    {else}
                        <div class="text-muted small">Aucune donnée</div>
                    {/if}
                </div>
            </div>
        </div>
        <div class="col-xl-4 col-md-6">
            <div class="cs-highlight-card cs-highlight-watch">
                <div class="cs-highlight-header">
                    <span class="cs-highlight-icon"><i class="bi bi-exclamation-triangle-fill"></i></span>
                    <span class="cs-highlight-title">Produit à surveiller</span>
                </div>
                <div class="cs-highlight-body">
                    {if $section_data.watch}
                        {call name=cs_highlight_prod h=$section_data.watch type='watch'}
                    {else}
                        <div class="text-muted small">Aucun produit signalé</div>
                    {/if}
                </div>
            </div>
        </div>
        <div class="col-xl-4 col-md-12">
            <div class="cs-highlight-card cs-highlight-pairs">
                <div class="cs-highlight-header">
                    <span class="cs-highlight-icon"><i class="bi bi-link-45deg"></i></span>
                    <span class="cs-highlight-title">Souvent vendus ensemble</span>
                </div>
                <div class="cs-highlight-body">
                    {if $section_data.pairs}
                        <div class="d-flex align-items-center gap-2 small flex-wrap">
                            <a href="{$section_data.pairs.product_a.bo_link}" target="_blank" class="d-flex align-items-center gap-2 text-decoration-none cs-highlight-prod">
                                {if $section_data.pairs.product_a.image}
                                    <img src="{$section_data.pairs.product_a.image}" alt="" class="rounded" style="width:32px;height:32px;object-fit:cover">
                                {else}
                                    <div class="rounded bg-secondary d-flex align-items-center justify-content-center" style="width:32px;height:32px"><i class="bi bi-image text-muted small"></i></div>
                                {/if}
                                <span class="text-truncate" style="max-width:100px" title="{$section_data.pairs.product_a.name}">{$section_data.pairs.product_a.name}</span>
                            </a>
                            <i class="bi bi-plus-lg text-muted"></i>
                            <a href="{$section_data.pairs.product_b.bo_link}" target="_blank" class="d-flex align-items-center gap-2 text-decoration-none cs-highlight-prod">
                                {if $section_data.pairs.product_b.image}
                                    <img src="{$section_data.pairs.product_b.image}" alt="" class="rounded" style="width:32px;height:32px;object-fit:cover">
                                {else}
                                    <div class="rounded bg-secondary d-flex align-items-center justify-content-center" style="width:32px;height:32px"><i class="bi bi-image text-muted small"></i></div>
                                {/if}
                                <span class="text-truncate" style="max-width:100px" title="{$section_data.pairs.product_b.name}">{$section_data.pairs.product_b.name}</span>
                            </a>
                            <span class="badge cs-badge-accent ms-auto"><strong>{$section_data.pairs.count}</strong> cmd</span>
                        </div>
                    {else}
                        <div class="text-muted small">Pas de paire significative</div>
                    {/if}
                </div>
            </div>
        </div>
    </div>
</div>
