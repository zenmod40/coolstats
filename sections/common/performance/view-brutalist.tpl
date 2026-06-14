{* ── Transporteurs & Expéditions · Variante Brutalist ── carte jaune *}
<div class="cs-section cs-performance-brutal cs-brutal-card-colored cs-brutal-card-yellow" data-cs-section="performance">
    <div class="cs-brutal-colored-title">
        <div class="cs-brutal-colored-t">📦 {l s='Transporteurs & Expédition' mod='coolstats'}</div>
        <a href="#" class="cs-carriers-brutal-detail">▸ {l s='détail' mod='coolstats'}</a>
    </div>
    <div class="cs-carriers-brutal-grid">
        <div class="cs-carriers-brutal-stat">
            <div class="cs-carriers-brutal-v">{if $section_data.avg_delay !== null}{$section_data.avg_delay}{l s='j' mod='coolstats'}{else}N/A{/if}</div>
            <div class="cs-carriers-brutal-l">{l s='Délai moyen d\'expédition' mod='coolstats'}</div>
            {if $section_data.avg_delay === null}
            <div class="cs-carriers-brutal-sub">{l s='Active le suivi colis pour voir cette donnée' mod='coolstats'}</div>
            {/if}
        </div>
        <div class="cs-carriers-brutal-stat">
            <div class="cs-carriers-brutal-v">{$section_data.delivery_rate}%</div>
            <div class="cs-carriers-brutal-l">{l s='Taux de livraison' mod='coolstats'}</div>
            {if $section_data.delivery_rate == 0}
            <div class="cs-carriers-brutal-sub">{l s='Pas encore de feedback livraison' mod='coolstats'}</div>
            {/if}
        </div>
        <div class="cs-carriers-brutal-stat">
            <div class="cs-carriers-brutal-v">{if !empty($section_data.top_carrier)}{$section_data.top_carrier}{else}—{/if}</div>
            <div class="cs-carriers-brutal-l">{l s='Transporteur favori' mod='coolstats'}</div>
            {if empty($section_data.top_carrier)}
            <div class="cs-carriers-brutal-sub">{l s='Connecte tes tracking IDs' mod='coolstats'}</div>
            {/if}
        </div>
    </div>
</div>
