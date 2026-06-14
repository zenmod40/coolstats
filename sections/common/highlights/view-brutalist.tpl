{* ── Highlights · Variante Brutalist ── 3 cartes colorées (jaune/rose/vert) *}
{function name=cs_hl_prod h=null growth_n1=false}
    <div class="cs-hl-brutal-prod">
        <div class="cs-hl-brutal-prod-img">
            {if $h.image}<img src="{$h.image}" alt="">{else}▢{/if}
        </div>
        <div class="cs-hl-brutal-prod-body">
            <div class="cs-hl-brutal-prod-name" title="{$h.name|escape:'html'}">{$h.name}</div>
            <div class="cs-hl-brutal-prod-meta">
                {if $h.reference}{l s='Réf' mod='coolstats'}. {$h.reference|escape:'html':'UTF-8'} · {/if}
                <strong>{$h.qty} {l s='vendus' mod='coolstats'}</strong>
                {if $growth_n1}
                · <span class="cs-hl-brutal-growth{if $h.growth < 0} cs-hl-brutal-growth-bad{/if}">{if $h.growth > 0}+{/if}{$h.growth}% {l s='vs N-1' mod='coolstats'}</span>
                {/if}
            </div>
        </div>
    </div>
{/function}

<div class="cs-highlights-row cs-highlights-brutal" data-cs-section="highlights">
    <div class="cs-hl-brutal-grid">
        {* ── Produit star ── *}
        <div class="cs-section cs-hl-brutal-card cs-brutal-card-colored cs-brutal-card-yellow">
            <div class="cs-hl-brutal-title">
                <span class="cs-hl-brutal-icon">★</span>
                <span class="cs-hl-brutal-label">{l s='Produit star' mod='coolstats'}</span>
            </div>
            {if $section_data.star}
                {call name=cs_hl_prod h=$section_data.star growth_n1=true}
            {else}
                <div class="cs-hl-brutal-empty">{l s='Aucune donnée — pas assez de signal cette période' mod='coolstats'}</div>
            {/if}
        </div>

        {* ── À surveiller ── *}
        <div class="cs-section cs-hl-brutal-card cs-brutal-card-colored cs-brutal-card-pink">
            <div class="cs-hl-brutal-title">
                <span class="cs-hl-brutal-icon">⚠</span>
                <span class="cs-hl-brutal-label">{l s='À surveiller' mod='coolstats'}</span>
            </div>
            {if $section_data.watch}
                <div class="cs-hl-brutal-prod">
                    <div class="cs-hl-brutal-prod-img">
                        {if $section_data.watch.image}<img src="{$section_data.watch.image}" alt="">{else}▢{/if}
                    </div>
                    <div class="cs-hl-brutal-prod-body">
                        <div class="cs-hl-brutal-prod-name" title="{$section_data.watch.name|escape:'html'}">{$section_data.watch.name}</div>
                        <div class="cs-hl-brutal-prod-meta">
                            <strong>{$section_data.watch.qty} {l s='unités' mod='coolstats'}</strong>
                            · <span class="cs-hl-brutal-growth-bad">{$section_data.watch.return_rate}% {l s='retour' mod='coolstats'}</span>
                        </div>
                    </div>
                </div>
            {else}
                <div class="cs-hl-brutal-empty">{l s='Aucune donnée — pas assez de signal cette période' mod='coolstats'}</div>
            {/if}
        </div>

        {* ── Souvent ensemble ── *}
        <div class="cs-section cs-hl-brutal-card cs-brutal-card-colored cs-brutal-card-green">
            <div class="cs-hl-brutal-title">
                <span class="cs-hl-brutal-icon">⇄</span>
                <span class="cs-hl-brutal-label">{l s='Souvent ensemble' mod='coolstats'}</span>
            </div>
            {if $section_data.pairs && $section_data.pairs.count > 0}
                <div class="cs-hl-brutal-prod">
                    <div class="cs-hl-brutal-prod-img">🛒</div>
                    <div class="cs-hl-brutal-prod-body">
                        <div class="cs-hl-brutal-prod-name">{$section_data.pairs.product_a.name} + {$section_data.pairs.product_b.name}</div>
                        <div class="cs-hl-brutal-prod-meta">
                            <strong>{$section_data.pairs.count} {if $section_data.pairs.count > 1}{l s='commandes' mod='coolstats'}{else}{l s='commande' mod='coolstats'}{/if}</strong>
                            · {l s='co-occurrence forte' mod='coolstats'}
                        </div>
                    </div>
                </div>
            {else}
                <div class="cs-hl-brutal-empty">{l s='Pas assez de données' mod='coolstats'}</div>
            {/if}
        </div>
    </div>
</div>
