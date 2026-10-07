{* ZM40 Common — panneau d'onglet « Modules ZM40 » (écosystème).
   Réutilisable : alimenté par $zm40_modules (Zm40CommonCst::modulesFeed du module courant,
   module courant exclu, fail-silent). L'onglet est toujours affiché : la liste si le feed
   renvoie des modules, puis l'interrupteur réseau, en bas comme sur tous les modules ZM40.
   S'appuie sur les classes d'onglet existantes (.cs-tab-content) + .cs-panel.
   v1.3 : badge + pitch + CTA dynamiques selon le type (open_source / pro / pro subscription). *}
<div class="cs-tab-content" data-tab-content="modules">
{if isset($zm40_modules) && $zm40_modules|@count}
{* Compte rapide OS vs Pro pour adapter le pitch *}
{assign var=zm40_count_os value=0}
{assign var=zm40_count_pro value=0}
{foreach from=$zm40_modules item=m}
    {if $m.is_os}{assign var=zm40_count_os value=$zm40_count_os+1}
    {elseif $m.is_pro}{assign var=zm40_count_pro value=$zm40_count_pro+1}
    {/if}
{/foreach}
        <div class="cs-panel">
            <h3 class="cs-panel-title">L'écosystème ZM40</h3>
            <p class="cs-panel-desc">
                {if $zm40_count_os > 0 && $zm40_count_pro > 0}D'autres modules PrestaShop ZM40 : open source pour le catalogue de base, version pro pour les modules à infrastructure dédiée. Tous installés sur votre serveur, code propre, support FR &amp; EN.
                {elseif $zm40_count_pro > 0}D'autres modules PrestaShop ZM40 — gamme pro. Installation sur votre serveur, support FR &amp; EN.
                {else}D'autres modules PrestaShop ZM40, gratuits et open source. Installez ce dont vous avez besoin — le code est à vous.
                {/if}
            </p>
            <div class="zm40-eco-grid">
                {foreach from=$zm40_modules item=m}
                    <div class="zm40-eco-card{if $m.is_pro} zm40-eco-card-pro{/if}">
                        <div class="zm40-eco-card-head">
                            {if $m.icon}<img class="zm40-eco-icon" src="{$m.icon|escape:'html':'UTF-8'}" alt="" loading="lazy">{/if}
                            <div class="zm40-eco-titles">
                                <span class="zm40-eco-name">{$m.name|escape:'html':'UTF-8'}</span>
                                {if $m.tagline}<span class="zm40-eco-tagline">{$m.tagline|escape:'html':'UTF-8'}</span>{/if}
                            </div>
                        </div>
                        <div class="zm40-eco-badges">
                            {* Badge type (OS / Pro / Pro · Abonnement) *}
                            {if $m.is_os}<span class="zm40-eco-badge zm40-eco-badge-os">Gratuit &middot; Open source</span>
                            {elseif $m.is_sub}<span class="zm40-eco-badge zm40-eco-badge-sub">Pro &middot; Abonnement</span>
                            {elseif $m.is_pro && $m.price_from_ht}<span class="zm40-eco-badge zm40-eco-badge-pro">Pro &middot; à partir de {$m.price_from_ht|escape:'html':'UTF-8'}&nbsp;€&nbsp;HT</span>
                            {elseif $m.is_pro}<span class="zm40-eco-badge zm40-eco-badge-pro">Pro</span>
                            {/if}
                            {if $m.installed}<span class="zm40-eco-badge zm40-eco-badge-installed">Déjà installé</span>{/if}
                        </div>
                        <div class="zm40-eco-links">
                            {if $m.installed && $m.configure_url}
                                {* Module installé : Configurer (CTA) + Découvrir (ghost). *}
                                <a href="{$m.configure_url|escape:'html':'UTF-8'}" class="zm40-eco-cta">Configurer</a>
                                {if $m.url}<a href="{$m.url|escape:'html':'UTF-8'}" target="_blank" rel="noopener">Découvrir</a>{/if}
                            {elseif $m.is_os}
                                {* Module OS non installé : GitHub (CTA) + Découvrir *}
                                {if $m.github}<a href="{$m.github|escape:'html':'UTF-8'}" target="_blank" rel="noopener" class="zm40-eco-cta">GitHub</a>{/if}
                                {if $m.url}<a href="{$m.url|escape:'html':'UTF-8'}" target="_blank" rel="noopener">Découvrir</a>{/if}
                            {else}
                                {* Module Pro non installé : Acheter/Souscrire (CTA) + Découvrir *}
                                {if $m.purchase_url}<a href="{$m.purchase_url|escape:'html':'UTF-8'}" target="_blank" rel="noopener" class="zm40-eco-cta">{if $m.is_sub}Souscrire{else}Acheter{/if}</a>{/if}
                                {if $m.url}<a href="{$m.url|escape:'html':'UTF-8'}" target="_blank" rel="noopener">Découvrir</a>{/if}
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
{/if}

            <div class="cs-panel">
                <h3 class="cs-panel-title">Mises à jour & autres modules (ZM40)</h3>
                <p class="cs-panel-desc">Vérification une fois par jour au maximum de la disponibilité d'une nouvelle version, via l'API publique de GitHub, et mise à jour de la liste des modules ZM40 depuis zm40.com. Ces requêtes sont <strong>anonymes</strong> : aucune donnée de votre boutique n'est transmise. Décochez pour tout désactiver ; la liste reste affichée telle quelle.</p>
                <div class="cs-form-row cs-form-row--switch">
                    <div class="cs-form-label">Vérifier les mises à jour</div>
                    <div class="cs-form-field">
                        <label class="cs-switch">
                            <input type="hidden" name="ZM40_NET_ENABLED" value="0">
                            <input type="checkbox" name="ZM40_NET_ENABLED" value="1" {if $zm40_net_enabled}checked{/if}>
                            <span class="cs-switch-slider"></span>
                        </label>
                    </div>
                    <div class="cs-form-desc">Activé par défaut. Si désactivé : aucun appel réseau, la liste ci-dessus reste celle du dernier rafraîchissement.</div>
                </div>
            </div>
</div>
