{* Fenêtre « Contrôle caisse », partagée par les trois thèmes. Déplacée sous <body> par le JS à l'ouverture. *}
<div class="modal fade cs-modal cs-kerawen-modal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title fw-bold mb-0"><i class="bi bi-shield-check me-2"></i>{l s='Contrôle des données caisse' mod='coolstats'}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="cs-kerawen-status cs-kerawen--{$section_data.check_status}">
                    {if $section_data.check_status == 'ko'}{l s='Incohérence détectée dans les données caisse' mod='coolstats'}
                    {elseif $section_data.check_status == 'error'}{l s='Certains contrôles n\'ont pas pu être menés' mod='coolstats'}
                    {else}{l s='Données caisse cohérentes sur tout l\'historique' mod='coolstats'}{/if}
                </div>
                {include file="{$section._dir}_checks.tpl"}
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">{l s='Fermer' mod='coolstats'}</button>
            </div>
        </div>
    </div>
</div>
