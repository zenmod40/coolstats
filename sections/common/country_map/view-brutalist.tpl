{* ── Pays · Variante Brutalist ──
 * Carte cobalt, header "◉ Où l'on vend" + badge jaune "X PAYS",
 * 2 colonnes : SVG map + liste classée à droite.
 *}
<div class="cs-section cs-country-section cs-country-brutal" data-cs-section="country_map" data-country-data="{$section_data.by_iso_attr nofilter}">
    <script type="application/json" class="cs-country-data-json">{$section_data.by_iso_json nofilter}</script>
    <div class="cs-country-brutal-header">
        <span class="cs-country-brutal-title">◉ {l s='Où l\'on vend' mod='coolstats'}</span>
        <span class="cs-country-brutal-badge"><span id="cs-country-count">{$section_data.ranked|@count}</span> {l s='pays' mod='coolstats'}</span>
    </div>
    <div class="cs-country-brutal-body">
        <div class="cs-country-brutal-map">
            {if $section_data.svg}
                <div id="cs-europe-map" class="cs-map-container position-relative">
                    {$section_data.svg nofilter}
                    <div id="cs-map-tooltip" class="cs-map-tooltip" style="display:none"></div>
                </div>
            {else}
                <div class="text-muted small">{l s='Carte indisponible' mod='coolstats'}</div>
            {/if}
        </div>
        <div class="cs-country-brutal-list" id="cs-country-rank-list">
            {if $section_data.ranked|@count}
                {foreach from=$section_data.ranked item=c name=cl}
                <div class="cs-country-brutal-row cs-country-rank-item{if $section_data.selected_iso == $c.iso} cs-country-selected{/if}" data-iso="{$c.iso}">
                    <div class="cs-country-brutal-row-l">
                        <span class="cs-country-brutal-rank">{$smarty.foreach.cl.iteration|string_format:'%02d'}</span>
                        <span class="cs-country-brutal-name">{$c.name|escape:'html':'UTF-8'}</span>
                    </div>
                    <span class="cs-country-brutal-right">
                        <span class="cs-country-brutal-amount">{$c.revenue|number_format:0:',':' '}&euro;</span>
                        <span class="cs-country-brutal-pct">{$c.pct_revenue}%</span>
                    </span>
                </div>
                {/foreach}
            {else}
                <div class="p-3 text-center small">{l s='Aucune donnée' mod='coolstats'}</div>
            {/if}
        </div>
    </div>
</div>
