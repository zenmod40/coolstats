{* ── Section Goals : barres de progression CA + commandes ── *}
{if !$section_data.enabled}
    {* Section masquée quand aucun objectif n'est défini *}
{else}
<div class="cs-section cs-goals-section" data-cs-section="goals">
    <div class="cs-goals-header">
        <div class="cs-goals-title">
            <i class="bi bi-flag-fill"></i> Objectifs — {$section_data.month_label|escape:'html'}
        </div>
        <div class="cs-goals-meta">
            Jour {$section_data.today} / {$section_data.days_in_month}
            {if $section_data.days_remaining > 0}
                · <strong>{$section_data.days_remaining}</strong> jour{if $section_data.days_remaining > 1}s{/if} restant{if $section_data.days_remaining > 1}s{/if}
            {else}
                · dernier jour du mois
            {/if}
        </div>
    </div>

    <div class="cs-goals-grid">
        {if $section_data.revenue}
        <div class="cs-goal-card cs-kpi-clickable cs-goal-{$section_data.revenue.status|escape:'html'}" data-drill="revenue">
            <div class="cs-goal-head">
                <div class="cs-goal-label"><i class="bi bi-currency-euro"></i> Chiffre d'affaires</div>
                <div class="cs-goal-pct">{$section_data.revenue.progress_pct}%</div>
            </div>
            <div class="cs-goal-values">
                <span class="cs-goal-current">{$section_data.revenue.current|number_format:0:',':' '}&euro;</span>
                <span class="cs-goal-sep">/</span>
                <span class="cs-goal-target">{$section_data.revenue.goal|number_format:0:',':' '}&euro;</span>
            </div>
            <div class="cs-goal-bar">
                <div class="cs-goal-bar-fill" style="width:{if $section_data.revenue.progress_pct > 100}100{else}{$section_data.revenue.progress_pct}{/if}%"></div>
                <div class="cs-goal-bar-marker" style="left:{$section_data.revenue.expected_pct}%" title="Trajectoire attendue : {$section_data.revenue.expected_pct}%"></div>
            </div>
            <div class="cs-goal-footer">
                <span class="cs-goal-status">
                    {if $section_data.revenue.status == 'ahead'}<i class="bi bi-arrow-up-circle-fill"></i> En avance
                    {elseif $section_data.revenue.status == 'on_track'}<i class="bi bi-arrow-right-circle-fill"></i> Sur trajectoire
                    {else}<i class="bi bi-arrow-down-circle-fill"></i> En retard{/if}
                </span>
                <span class="cs-goal-projection">
                    Projection fin de mois&nbsp;: <strong>{$section_data.revenue.projection|number_format:0:',':' '}&euro;</strong>
                </span>
            </div>
            <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les ventes du mois</span></div>
        </div>
        {/if}

        {if $section_data.orders}
        <div class="cs-goal-card cs-kpi-clickable cs-goal-{$section_data.orders.status|escape:'html'}" data-drill="orders">
            <div class="cs-goal-head">
                <div class="cs-goal-label"><i class="bi bi-bag-check"></i> Commandes</div>
                <div class="cs-goal-pct">{$section_data.orders.progress_pct}%</div>
            </div>
            <div class="cs-goal-values">
                <span class="cs-goal-current">{$section_data.orders.current|number_format:0:',':' '}</span>
                <span class="cs-goal-sep">/</span>
                <span class="cs-goal-target">{$section_data.orders.goal|number_format:0:',':' '}</span>
            </div>
            <div class="cs-goal-bar">
                <div class="cs-goal-bar-fill" style="width:{if $section_data.orders.progress_pct > 100}100{else}{$section_data.orders.progress_pct}{/if}%"></div>
                <div class="cs-goal-bar-marker" style="left:{$section_data.orders.expected_pct}%" title="Trajectoire attendue : {$section_data.orders.expected_pct}%"></div>
            </div>
            <div class="cs-goal-footer">
                <span class="cs-goal-status">
                    {if $section_data.orders.status == 'ahead'}<i class="bi bi-arrow-up-circle-fill"></i> En avance
                    {elseif $section_data.orders.status == 'on_track'}<i class="bi bi-arrow-right-circle-fill"></i> Sur trajectoire
                    {else}<i class="bi bi-arrow-down-circle-fill"></i> En retard{/if}
                </span>
                <span class="cs-goal-projection">
                    Projection fin de mois&nbsp;: <strong>{$section_data.orders.projection|number_format:0:',':' '}</strong>
                </span>
            </div>
            <div class="cs-drill-overlay"><i class="bi bi-arrow-down-circle"></i><span>Voir les commandes du mois</span></div>
        </div>
        {/if}
    </div>
</div>
{/if}
