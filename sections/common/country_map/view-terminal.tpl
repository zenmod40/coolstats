{* ── Pays · Variante Terminal ──
 * Header unique "◉ Répartition géographique" + badge "N PAYS",
 * grid 1fr/1.2fr : SVG map left + classement right.
 *}
<div class="cs-section cs-country-section cs-country-term" data-cs-section="country_map" data-country-data="{$section_data.by_iso_attr nofilter}">
    <script type="application/json" class="cs-country-data-json">{$section_data.by_iso_json nofilter}</script>
    <div class="cs-section-header">
        <span>◉ {l s='Répartition géographique' mod='coolstats'}</span>
        <span class="cs-country-term-badge"><span id="cs-country-count">{$section_data.ranked|@count}</span> {l s='pays' mod='coolstats'}</span>
    </div>
    <div class="cs-country-term-body">
        <div class="cs-country-term-map">
            {if $section_data.svg}
                <div id="cs-europe-map" class="cs-map-container position-relative">
                    {$section_data.svg nofilter}
                    <div id="cs-map-tooltip" class="cs-map-tooltip" style="display:none"></div>
                </div>
            {else}
                <div class="cs-term-empty">{l s='Carte indisponible' mod='coolstats'}</div>
            {/if}
        </div>
        <div class="cs-country-term-list" id="cs-country-rank-list">
            <div class="cs-country-term-list-h">// {l s='classement par pays' mod='coolstats'}</div>
            {if $section_data.ranked|@count}
                {foreach from=$section_data.ranked item=c name=cl}
                <div class="cs-country-term-row cs-country-rank-item{if $section_data.selected_iso == $c.iso} cs-country-selected{/if}" data-iso="{$c.iso}">
                    <span class="cs-country-term-rank">{$smarty.foreach.cl.iteration|string_format:'%02d'}</span>
                    <span class="cs-country-term-name">{$c.name|escape:'html':'UTF-8'} <span class="cs-country-term-iso">[{$c.iso|escape:'html':'UTF-8'}]</span></span>
                    <span class="cs-country-term-amt">{$c.revenue|number_format:0:',':' '}&euro;</span>
                    <span class="cs-country-term-meta">{$c.orders} {l s='cmd' mod='coolstats'} · {$c.pct_orders}%</span>
                </div>
                {/foreach}
            {else}
                <div class="cs-term-empty">{l s='Aucune donnée' mod='coolstats'}</div>
            {/if}
        </div>
    </div>
</div>
