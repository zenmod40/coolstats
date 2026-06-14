{* ── Highlights · Variante Terminal ── 3 panels (star / watch / pairs) *}
<div class="cs-highlights-row cs-highlights-term" data-cs-section="highlights">
    <div class="cs-highlights-term-grid">
        {* ── Produit star ── *}
        <div class="cs-section cs-hl-term-card">
            <div class="cs-section-header">
                <span><span class="cs-hl-term-icon cs-hl-term-icon--green">★</span> {l s='Produit star' mod='coolstats'}</span>
            </div>
            <div class="cs-hl-term-body">
                {if $section_data.star}
                    <div class="cs-hl-term-thumb cs-hl-term-thumb--green">
                        {if $section_data.star.image}<img src="{$section_data.star.image}" alt="">{else}★{/if}
                    </div>
                    <div class="cs-hl-term-info">
                        <div class="cs-hl-term-name">{$section_data.star.name}</div>
                        <div class="cs-hl-term-meta">
                            {if $section_data.star.reference}{l s='REF' mod='coolstats'}: <span class="cs-hl-term-ref">{$section_data.star.reference}</span> · {/if}
                            <span class="cs-hl-term-emph">{$section_data.star.qty} {l s='vendus' mod='coolstats'}</span>
                            {if $section_data.star.growth != 0}
                            · <span class="cs-hl-term-growth{if $section_data.star.growth < 0} cs-hl-term-growth--bad{/if}">{if $section_data.star.growth > 0}▲ +{else}▼ {/if}{$section_data.star.growth}% {l s='vs N-1' mod='coolstats'}</span>
                            {/if}
                        </div>
                    </div>
                {else}
                    <div class="cs-hl-term-empty">
                        <div class="cs-hl-term-nosignal">// no_signal</div>
                        {l s='Aucune donnée' mod='coolstats'}
                    </div>
                {/if}
            </div>
        </div>

        {* ── À surveiller ── *}
        <div class="cs-section cs-hl-term-card">
            <div class="cs-section-header">
                <span><span class="cs-hl-term-icon cs-hl-term-icon--amber">⚠</span> {l s='Produit à surveiller' mod='coolstats'}</span>
            </div>
            <div class="cs-hl-term-body">
                {if $section_data.watch}
                    <div class="cs-hl-term-thumb cs-hl-term-thumb--amber">
                        {if $section_data.watch.image}<img src="{$section_data.watch.image}" alt="">{else}⚠{/if}
                    </div>
                    <div class="cs-hl-term-info">
                        <div class="cs-hl-term-name">{$section_data.watch.name}</div>
                        <div class="cs-hl-term-meta">
                            <span class="cs-hl-term-emph">{$section_data.watch.qty} {l s='unités' mod='coolstats'}</span>
                            · <span class="cs-hl-term-growth--bad">{$section_data.watch.return_rate}% {l s='retour' mod='coolstats'}</span>
                        </div>
                    </div>
                {else}
                    <div class="cs-hl-term-empty">
                        <div class="cs-hl-term-nosignal cs-hl-term-nosignal--amber">// no_signal</div>
                        {l s='Aucun produit signalé' mod='coolstats'}
                    </div>
                {/if}
            </div>
        </div>

        {* ── Souvent ensemble ── *}
        <div class="cs-section cs-hl-term-card">
            <div class="cs-section-header">
                <span><span class="cs-hl-term-icon cs-hl-term-icon--blue">⇄</span> {l s='Souvent vendus ensemble' mod='coolstats'}</span>
            </div>
            <div class="cs-hl-term-body cs-hl-term-pairs">
                {if $section_data.pairs && $section_data.pairs.count > 0}
                    <div class="cs-hl-term-thumb">
                        {if $section_data.pairs.product_a.image}<img src="{$section_data.pairs.product_a.image}" alt="">{else}▢{/if}
                    </div>
                    <span class="cs-hl-term-pair-name" title="{$section_data.pairs.product_a.name|escape:'html'}">{$section_data.pairs.product_a.name}</span>
                    <span class="cs-hl-term-pair-plus">+</span>
                    <div class="cs-hl-term-thumb">
                        {if $section_data.pairs.product_b.image}<img src="{$section_data.pairs.product_b.image}" alt="">{else}▢{/if}
                    </div>
                    <span class="cs-hl-term-pair-name" title="{$section_data.pairs.product_b.name|escape:'html'}">{$section_data.pairs.product_b.name}</span>
                    <span class="cs-hl-term-pair-count">{$section_data.pairs.count} {l s='cmd' mod='coolstats'}</span>
                {else}
                    <div class="cs-hl-term-empty">
                        <div class="cs-hl-term-nosignal cs-hl-term-nosignal--blue">// no_signal</div>
                        {l s='Pas assez de données' mod='coolstats'}
                    </div>
                {/if}
            </div>
        </div>
    </div>
</div>
