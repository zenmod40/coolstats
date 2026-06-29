/**
 * CoolStats Dashboard — front JS (filtres URL + refresh AJAX par section).
 *
 * @author ZM40 (2026)
 */
(function () {
    'use strict';

    document.addEventListener('DOMContentLoaded', function () {
        initThemeToggle();
        initFilters();
        initDateRange();
        initCountryMap();
        initCountryFilterBadge();
        initLineChart();
        initSavChart();
        initBarChart();
        initCustomize();
        initCollapsibles();
        initReturnsModal();
        initCarriersModal();
        initAutoRefresh();
        initFullscreen();
        initPdfExport();
        initCsvExport();
        initSectionCsvExport();
        initTerminalAsciiBars();
        initScrollIndicator();
        initPillDropdowns();
        initBrutalistPairs();
        initDeleteAbandonedCart();
        initProductSearch();
        initTopTabs();
        initThemePicker();
        // Re-init après chaque refresh AJAX (event delegation gère l'event mais les init internes besoin de re-bind)
        document.addEventListener('cs:section-refreshed', function (e) {
            if (!e.detail) return;
            if (e.detail.id === 'country_map')        initCountryMap();
            if (e.detail.id === 'orders_chart')       initLineChart();
            if (e.detail.id === 'sav_chart')          initSavChart();
            if (e.detail.id === 'payment_breakdown')  initBarChart();
            if (e.detail.id === 'country_map' || e.detail.id === 'payment_breakdown') initBrutalistPairs();
            // top_products re-rendu (ex: changement tri/limit) → restaure l'onglet actif.
            if (e.detail.id === 'top_products') applyTopTab(csTopActiveTab, true);
        });
    });

    // ── Suppression d'un panier abandonné depuis la section "Paniers abandonnés" ──
    // Le bouton trash dans chaque ligne ouvre une modal Bootstrap de confirmation
    // (#cs-modal-delete-cart). Le bouton "Supprimer définitivement" POST l'action
    // `deleteAbandonedCart` avec id_cart. Garde-fous côté serveur :
    //   - méthode POST uniquement
    //   - le panier ne doit avoir AUCUNE commande associée
    //   - le panier doit avoir + de 2h (cohérent avec la définition section)
    // Listener en event delegation pour survivre aux refresh AJAX de la section.
    function initDeleteAbandonedCart() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest('[data-cs-delete-cart]');
            if (!btn) return;
            e.preventDefault();
            var idCart   = btn.getAttribute('data-cs-delete-cart');
            var customer = btn.getAttribute('data-cs-cart-customer') || '—';
            var value    = btn.getAttribute('data-cs-cart-value')    || '—';

            // Hydrate la modal avec les détails du panier ciblé
            var elId   = document.getElementById('cs-delete-cart-id');
            var elCus  = document.getElementById('cs-delete-cart-customer');
            var elVal  = document.getElementById('cs-delete-cart-value');
            var elBtn  = document.getElementById('cs-delete-cart-confirm');
            var modalEl = document.getElementById('cs-modal-delete-cart');
            if (!modalEl || !elBtn) return;

            if (elId)  elId.textContent  = idCart;
            if (elCus) elCus.textContent = customer;
            if (elVal) elVal.textContent = value;
            elBtn.dataset.csDeleteCartId = idCart;

            // Ouverture
            var BsModal = window.bootstrap && window.bootstrap.Modal;
            var modalInstance = BsModal ? BsModal.getOrCreateInstance(modalEl) : null;
            if (modalInstance) modalInstance.show();
        });

        // Click sur "Supprimer définitivement" → AJAX
        document.addEventListener('click', function (e) {
            var btn = e.target.closest('#cs-delete-cart-confirm');
            if (!btn) return;
            var idCart = btn.dataset.csDeleteCartId;
            if (!idCart) return;

            btn.disabled = true;
            var originalHtml = btn.innerHTML;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Suppression…';

            var url = new URL(window.location.href);
            url.searchParams.set('ajax', '1');
            url.searchParams.set('action', 'deleteAbandonedCart');
            url.searchParams.set('id_cart', idCart);

            fetch(url.toString(), { method: 'POST' })
                .then(function (r) { return r.json().then(function (data) { return { ok: r.ok, data: data }; }); })
                .then(function (res) {
                    btn.disabled = false;
                    btn.innerHTML = originalHtml;

                    var modalEl = document.getElementById('cs-modal-delete-cart');
                    var BsModal = window.bootstrap && window.bootstrap.Modal;
                    var modalInstance = BsModal && modalEl ? BsModal.getOrCreateInstance(modalEl) : null;
                    if (modalInstance) modalInstance.hide();

                    if (!res.ok || !res.data || !res.data.success) {
                        var msg = res.data && res.data.message ? res.data.message : 'Erreur lors de la suppression';
                        if (typeof showToast === 'function') {
                            showToast(msg, 'error');
                        } else {
                            alert('⚠ ' + msg);
                        }
                        return;
                    }

                    // Succès : retirer la ligne du DOM + refresh de la section
                    // (pour mettre à jour les KPIs agrégés).
                    var row = document.querySelector('[data-cs-cart-row="' + idCart + '"]');
                    if (row && row.parentNode) {
                        row.style.transition = 'opacity 0.2s';
                        row.style.opacity = '0';
                        setTimeout(function () { if (row.parentNode) row.parentNode.removeChild(row); }, 200);
                    }
                    if (typeof refreshSection === 'function') {
                        setTimeout(function () { refreshSection('abandoned_carts'); }, 350);
                    }
                    if (typeof showToast === 'function') {
                        showToast('Panier #' + idCart + ' supprimé', 'success');
                    }
                })
                .catch(function () {
                    btn.disabled = false;
                    btn.innerHTML = originalHtml;
                    if (typeof showToast === 'function') {
                        showToast('Erreur réseau lors de la suppression', 'error');
                    } else {
                        alert('⚠ Erreur réseau');
                    }
                });
        });
    }

    // ── Clic sur labels Volume/CA pour basculer le filtre sort (brutalist + terminal) ──
    document.addEventListener('click', function (e) {
        var lbl = e.target.closest('[data-toggle-target]');
        if (!lbl) return;
        var wrap = lbl.closest('.cs-top-brutal-sort, .cs-top-term-sort');
        var input = wrap && wrap.querySelector('input[type="checkbox"]');
        if (!input) return;
        var want = lbl.getAttribute('data-toggle-target') === 'revenue';
        if (input.checked !== want) {
            input.checked = want;
            input.dispatchEvent(new Event('change', { bubbles: true }));
        }
    });

    // ── Regroupe les sections par paires dans un wrapper (brutalist + terminal) ──
    function initBrutalistPairs() {
        var theme = document.documentElement.getAttribute('data-cs-theme');
        var pairs = [];
        if (theme === 'brutalist') {
            pairs = [
                ['country_map', 'payment_breakdown', 'cs-brutal-pair'],     // 1.3fr / 1fr
                ['signups',     'margins',          'cs-brutal-pair-r2'],   // 1fr / 1fr
                ['traffic',     'abandoned_carts',  'cs-brutal-pair-r2']
            ];
        } else if (theme === 'terminal') {
            pairs = [
                ['country_map', 'payment_breakdown', 'cs-term-pair']        // 1.4fr / 1fr
            ];
        } else {
            return;
        }
        pairs.forEach(function (cfg) {
            var a = document.querySelector('[data-cs-section="' + cfg[0] + '"]');
            var b = document.querySelector('[data-cs-section="' + cfg[1] + '"]');
            if (!a || !b) return;
            var p = a.parentElement;
            if (p && (p.classList.contains('cs-brutal-pair') || p.classList.contains('cs-brutal-pair-r2') || p.classList.contains('cs-term-pair'))) return;
            var wrap = document.createElement('div');
            wrap.className = cfg[2];
            a.parentNode.insertBefore(wrap, a);
            wrap.appendChild(a);
            wrap.appendChild(b);
        });
    }

    // ── Theme dark/light (avec persistance par visual theme) ──
    function initThemeToggle() {
        var btn = document.getElementById('cs-theme-toggle');
        if (!btn) return;
        btn.addEventListener('click', function () {
            var current = document.documentElement.getAttribute('data-bs-theme') || 'dark';
            var next = current === 'dark' ? 'light' : 'dark';
            var visualTheme = document.documentElement.getAttribute('data-cs-theme') || 'default';
            document.documentElement.setAttribute('data-bs-theme', next);
            try {
                localStorage.setItem('cs-mode-' + visualTheme, next);
                localStorage.setItem('cs-theme', next); // legacy fallback
            } catch (e) {}
            var icon = btn.querySelector('i');
            if (icon) icon.className = next === 'dark' ? 'bi bi-moon-stars' : 'bi bi-sun-fill';
        });
    }

    // ── Filtres globaux (event delegation pour survivre aux re-renders AJAX) ──
    function initFilters() {
        document.addEventListener('change', handleFilterEvent);
        document.addEventListener('input', handleFilterEvent);
    }

    var csFilterDebounceTimers = {};

    function handleFilterEvent(e) {
        var el = e.target;
        if (!el.classList || !el.classList.contains('cs-filter')) return;
        if (!el.dataset || !el.dataset.filter) return;
        // Click sur bouton type "value" (filtre statut, pagination) → on traite l'event 'click' ailleurs
        if (el.dataset.toggleMode === 'value' && e.type !== 'click') return;
        if (e.type === 'input' && (el.tagName === 'SELECT' || el.type === 'checkbox' || el.type === 'date')) return;
        if (el.tagName === 'BUTTON') return;

        var value;
        if (el.type === 'checkbox') {
            value = el.checked ? (el.dataset.onValue || '1') : (el.dataset.offValue || '');
        } else {
            value = el.value;
        }

        var name = el.dataset.filter;

        // Min-length : pour les recherches text, ne déclenche qu'à partir de N caractères.
        // Vide → on déclenche pour clear le filtre.
        var minLength = parseInt(el.dataset.minLength || '0', 10);
        if (minLength > 0 && value.length > 0 && value.length < minLength) {
            // Annule un debounce en attente : pas de filtre tant qu'on n'a pas atteint le min.
            if (csFilterDebounceTimers[name]) {
                clearTimeout(csFilterDebounceTimers[name]);
                csFilterDebounceTimers[name] = null;
            }
            return;
        }

        // Debounce : retarde l'appel pour ne pas refresh à chaque frappe.
        var debounceMs = parseInt(el.dataset.debounce || '0', 10);
        if (debounceMs > 0) {
            if (csFilterDebounceTimers[name]) clearTimeout(csFilterDebounceTimers[name]);
            csFilterDebounceTimers[name] = setTimeout(function () {
                applyFilter(name, value);
            }, debounceMs);
            return;
        }

        applyFilter(name, value);
    }

    // Buttons "value-mode" : click → applique la valeur (ex: filtre statut, pagination)
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.cs-filter[data-toggle-mode="value"]');
        if (!btn) return;
        e.preventDefault();
        applyFilter(btn.dataset.filter, btn.dataset.onValue || '');
    });

    // Buttons "multi-mode" : click → toggle d'une valeur dans une liste comma-separated.
    // Utilisé par les cards MKP du breakdown :
    //   data-filter="channels" + data-toggle-mode="multi" + data-mkp-key="amazon_fbm"
    // L'URL passe à ?channels=amazon_fbm,cdiscount. Clic sur une card déjà active = la retire.
    // Refresh AJAX de TOUTES les sections (event delegation déjà en place dans refreshAllSections).
    document.addEventListener('click', function (e) {
        var card = e.target.closest('.cs-filter[data-toggle-mode="multi"]');
        if (!card) return;
        e.preventDefault();
        var name = card.dataset.filter;
        var key  = card.dataset.mkpKey;
        if (!name || !key) return;

        var url = new URL(window.location.href);
        var current = (url.searchParams.get(name) || '').split(',').filter(Boolean);
        var idx = current.indexOf(key);
        if (idx > -1) current.splice(idx, 1);
        else current.push(key);

        if (current.length === 0) url.searchParams.delete(name);
        else                      url.searchParams.set(name, current.join(','));

        window.history.replaceState({}, '', url.toString());
        refreshAllSections();
    });

    // Support clavier (Enter / Espace) pour l'accessibilité des cards
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ') return;
        var card = e.target.closest('.cs-filter[data-toggle-mode="multi"]');
        if (!card) return;
        e.preventDefault();
        card.click();
    });

    function applyFilter(name, value) {
        var url = new URL(window.location.href);
        if (value === '' || value == null) {
            url.searchParams.delete(name);
        } else {
            url.searchParams.set(name, value);
        }
        window.history.replaceState({}, '', url.toString());
        refreshAllSections();
    }

    // ── Refresh des sections via AJAX ──
    function refreshAllSections() {
        var wrappers = document.querySelectorAll('[data-cs-section]');
        wrappers.forEach(function (w) {
            refreshSection(w.dataset.csSection);
        });
    }

    function refreshSection(id) {
        var wrapper = document.querySelector('[data-cs-section="' + id + '"]');
        if (!wrapper) return;
        wrapper.style.opacity = '0.5';

        // Sauvegarde du focus + position curseur de l'input actif (s'il est dans cette section).
        var focusInfo = captureFocusedFilter(wrapper);

        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'section');
        url.searchParams.set('id', id);

        fetch(url.toString())
            .then(function (r) {
                if (csIsAuthRedirect(r)) { csRedirectToLogin(r.url); throw new Error('auth'); }
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.text();
            })
            .then(function (html) {
                // Le serveur renvoie le bloc complet incluant `<div data-cs-section="...">`.
                // On remplace le wrapper actuel par le nouveau HTML.
                var tmp = document.createElement('div');
                tmp.innerHTML = html.trim();
                var fresh = tmp.querySelector('[data-cs-section="' + id + '"]');
                if (fresh) {
                    wrapper.replaceWith(fresh);
                    restoreFocusedFilter(fresh, focusInfo);
                } else {
                    wrapper.innerHTML = html;
                    wrapper.style.opacity = '';
                    restoreFocusedFilter(wrapper, focusInfo);
                }
                document.dispatchEvent(new CustomEvent('cs:section-refreshed', { detail: { id: id } }));
            })
            .catch(function () {
                wrapper.style.opacity = '';
            });
    }

    function captureFocusedFilter(wrapper) {
        var active = document.activeElement;
        if (!active || !wrapper.contains(active)) return null;
        if (!active.classList || !active.classList.contains('cs-filter')) return null;
        if (!active.dataset || !active.dataset.filter) return null;
        var pos = null;
        try {
            if (typeof active.selectionStart === 'number') pos = active.selectionStart;
        } catch (e) {}
        return { filter: active.dataset.filter, pos: pos };
    }

    function restoreFocusedFilter(scope, info) {
        if (!info || !scope) return;
        var el = scope.querySelector('.cs-filter[data-filter="' + info.filter + '"]');
        if (!el || typeof el.focus !== 'function') return;
        // setTimeout pour laisser le navigateur finir le re-render avant le focus.
        setTimeout(function () {
            try {
                el.focus();
                if (info.pos !== null && typeof el.setSelectionRange === 'function') {
                    el.setSelectionRange(info.pos, info.pos);
                }
            } catch (e) {}
        }, 0);
    }

    // ── Date Range Picker (presets + custom) ──
    function initDateRange() {
        var presets = document.querySelectorAll('.cs-daterange-preset');
        var label = document.getElementById('cs-daterange-label');
        var fromInput = document.getElementById('cs-date-from');
        var toInput = document.getElementById('cs-date-to');
        var applyBtn = document.getElementById('cs-daterange-apply');
        var summary = document.getElementById('cs-daterange-summary');
        if (!presets.length || !label) return;

        var today = new Date();
        var currentFrom = window.csDateFrom || '';
        var currentTo = window.csDateTo || '';

        // Activer le preset correspondant aux dates courantes
        var matched = false;
        presets.forEach(function (btn) {
            var r = computeRange(btn.dataset.range, today);
            if (formatDateISO(r.from) === currentFrom && formatDateISO(r.to) === currentTo) {
                btn.classList.add('active');
                label.textContent = btn.textContent.trim();
                matched = true;
            } else {
                btn.classList.remove('active');
            }
        });
        if (!matched && currentFrom && currentTo) {
            label.textContent = formatDateFR(new Date(currentFrom)) + ' - ' + formatDateFR(new Date(currentTo));
        }
        updateSummary(summary, currentFrom, currentTo);

        presets.forEach(function (btn) {
            btn.addEventListener('click', function () {
                var r = computeRange(this.dataset.range, today);
                applyDateRange(r.from, r.to);
            });
        });

        if (applyBtn) {
            applyBtn.addEventListener('click', function () {
                if (!fromInput.value || !toInput.value) return;
                var f = new Date(fromInput.value);
                var t = new Date(toInput.value);
                if (f > t) return;
                applyDateRange(f, t);
            });
        }
    }

    function applyDateRange(from, to) {
        var fIso = formatDateISO(from);
        var tIso = formatDateISO(to);
        var url = new URL(window.location.href);
        url.searchParams.set('date_from', fIso);
        url.searchParams.set('date_to', tIso);
        window.history.replaceState({}, '', url.toString());
        window.csDateFrom = fIso;
        window.csDateTo = tIso;

        // Met à jour le label + summary localement
        var label = document.getElementById('cs-daterange-label');
        var presets = document.querySelectorAll('.cs-daterange-preset');
        var matched = null;
        presets.forEach(function (btn) {
            var r = computeRange(btn.dataset.range, new Date());
            var ok = formatDateISO(r.from) === fIso && formatDateISO(r.to) === tIso;
            btn.classList.toggle('active', ok);
            if (ok) matched = btn;
        });
        if (label) {
            label.textContent = matched ? matched.textContent.trim() : (formatDateFR(from) + ' - ' + formatDateFR(to));
        }
        updateSummary(document.getElementById('cs-daterange-summary'), fIso, tIso);

        // Ferme le dropdown si Bootstrap est dispo
        var btnToggle = document.querySelector('.cs-daterange-btn');
        if (btnToggle && window.bootstrap) {
            var dd = window.bootstrap.Dropdown.getInstance(btnToggle);
            if (dd) dd.hide();
        }

        refreshAllSections();
    }

    function updateSummary(el, fromIso, toIso) {
        if (!el || !fromIso || !toIso) return;
        var f = new Date(fromIso), t = new Date(toIso);
        var days = Math.round((t - f) / 86400000) + 1;
        el.textContent = days + ' jour' + (days > 1 ? 's' : '') + ' sélectionné' + (days > 1 ? 's' : '');
    }

    function computeRange(key, ref) {
        var from, to;
        var y = ref.getFullYear(), m = ref.getMonth(), d = ref.getDay();
        switch (key) {
            case 'this_week':
                var monday = new Date(ref);
                monday.setDate(ref.getDate() - ((d + 6) % 7));
                from = startOfDay(monday);
                to = new Date(from); to.setDate(to.getDate() + 6); to = endOfDay(to);
                break;
            case 'last_week':
                var rw = computeRange('this_week', ref);
                from = new Date(rw.from); from.setDate(from.getDate() - 7);
                to = new Date(rw.to); to.setDate(to.getDate() - 7);
                break;
            case 'week_minus_2':
                var rw2 = computeRange('this_week', ref);
                from = new Date(rw2.from); from.setDate(from.getDate() - 14);
                to = new Date(rw2.to); to.setDate(to.getDate() - 14);
                break;
            case 'this_month':       from = new Date(y, m, 1);     to = endOfDay(new Date(y, m + 1, 0)); break;
            case 'last_month':       from = new Date(y, m - 1, 1); to = endOfDay(new Date(y, m, 0));     break;
            case 'month_minus_2':    from = new Date(y, m - 2, 1); to = endOfDay(new Date(y, m - 1, 0)); break;
            case 'this_quarter':
                var q = Math.floor(m / 3);
                from = new Date(y, q * 3, 1); to = endOfDay(new Date(y, q * 3 + 3, 0)); break;
            case 'last_quarter':
                var q1 = Math.floor(m / 3) - 1, y1 = y;
                if (q1 < 0) { q1 = 3; y1--; }
                from = new Date(y1, q1 * 3, 1); to = endOfDay(new Date(y1, q1 * 3 + 3, 0)); break;
            case 'quarter_minus_2':
                var q2 = Math.floor(m / 3) - 2, y2 = y;
                while (q2 < 0) { q2 += 4; y2--; }
                from = new Date(y2, q2 * 3, 1); to = endOfDay(new Date(y2, q2 * 3 + 3, 0)); break;
            case 'this_year':        from = new Date(y, 0, 1);     to = endOfDay(new Date(y, 11, 31)); break;
            case 'last_year':        from = new Date(y - 1, 0, 1); to = endOfDay(new Date(y - 1, 11, 31)); break;
            case 'year_minus_2':     from = new Date(y - 2, 0, 1); to = endOfDay(new Date(y - 2, 11, 31)); break;
            default:
                from = new Date(y, m, 1); to = endOfDay(new Date(y, m + 1, 0));
        }
        return { from: from, to: to };
    }

    function startOfDay(d) { var n = new Date(d); n.setHours(0, 0, 0, 0); return n; }
    function endOfDay(d)   { var n = new Date(d); n.setHours(23, 59, 59, 999); return n; }
    function formatDateISO(d) {
        if (typeof d === 'string') return d;
        var mm = ('0' + (d.getMonth() + 1)).slice(-2);
        var dd = ('0' + d.getDate()).slice(-2);
        return d.getFullYear() + '-' + mm + '-' + dd;
    }
    function formatDateFR(d) {
        var dd = ('0' + d.getDate()).slice(-2);
        var mm = ('0' + (d.getMonth() + 1)).slice(-2);
        return dd + '/' + mm + '/' + d.getFullYear();
    }

    // ── Carte Europe : tooltip + click → filtre pays global ──
    function initCountryMap() {
        var section = document.querySelector('[data-cs-section="country_map"]');
        if (!section) return;
        var container = section.querySelector('#cs-europe-map');
        var tooltip = section.querySelector('#cs-map-tooltip');
        if (!container) return;
        var byIso = {};
        // 1. Source prioritaire : <script type="application/json">
        var jsonNode = section.querySelector('.cs-country-data-json');
        if (jsonNode && jsonNode.textContent) {
            try { byIso = JSON.parse(jsonNode.textContent) || {}; } catch (e) {}
        }
        // 2. Fallback : data-country-data
        if (!byIso || !Object.keys(byIso).length) {
            try {
                byIso = JSON.parse(section.getAttribute('data-country-data') || '{}') || {};
            } catch (e) {}
        }

        var paths = container.querySelectorAll('.cs-map-path');
        if (!paths.length) return;

        var maxOrders = 0;
        for (var iso in byIso) {
            if (byIso[iso].orders > maxOrders) maxOrders = byIso[iso].orders;
        }
        var isDark = (document.documentElement.getAttribute('data-bs-theme') || 'dark') === 'dark';

        var selectedIso = (window.csCountryFilter || null);

        paths.forEach(function (path) {
            var iso = (path.id || '').toUpperCase();
            var data = byIso[iso];

            path.classList.remove('cs-map-no-data', 'cs-map-selected');
            path.style.fill = '';
            if (data && data.orders > 0) {
                path.style.fill = mapColor(data.orders, maxOrders, isDark);
            } else {
                path.classList.add('cs-map-no-data');
            }
            if (iso === selectedIso) path.classList.add('cs-map-selected');

            path.addEventListener('mouseenter', function (e) {
                var d = byIso[iso];
                if (!d || !d.orders) return;
                showMapTooltip(tooltip, d);
                highlightRank(iso, true);
            });
            path.addEventListener('mousemove', function (e) {
                if (!byIso[iso] || !byIso[iso].orders) return;
                positionTooltip(tooltip, e, container);
            });
            path.addEventListener('mouseleave', function () {
                if (tooltip) tooltip.style.display = 'none';
                highlightRank(iso, false);
            });
            path.addEventListener('click', function () {
                var d = byIso[iso];
                if (!d || !d.orders) return;
                var nextIso = (iso === selectedIso) ? null : iso;
                applyCountryFilter(nextIso);
            });
        });

        // Classement → click + hover
        var rankList = section.querySelector('#cs-country-rank-list');
        if (rankList) {
            rankList.addEventListener('mouseover', function (e) {
                var item = e.target.closest('.cs-country-rank-item[data-iso]');
                if (!item) return;
                var p = container.querySelector('#' + item.dataset.iso);
                if (p) p.classList.add('cs-map-highlight');
            });
            rankList.addEventListener('mouseout', function (e) {
                var item = e.target.closest('.cs-country-rank-item[data-iso]');
                if (!item) return;
                var p = container.querySelector('#' + item.dataset.iso);
                if (p) p.classList.remove('cs-map-highlight');
            });
            rankList.addEventListener('click', function (e) {
                var item = e.target.closest('.cs-country-rank-item[data-iso]');
                if (!item) return;
                var iso = item.dataset.iso;
                applyCountryFilter(iso === selectedIso ? null : iso);
            });
        }
    }

    // Lit la couleur d'accent configurée (CSS var --cs-accent / --cs-accent-rgb).
    function getAccentColor() {
        var v = getComputedStyle(document.documentElement).getPropertyValue('--cs-accent');
        return (v || '#4F46E5').trim();
    }
    function getAccentRgb() {
        var v = getComputedStyle(document.documentElement).getPropertyValue('--cs-accent-rgb');
        return (v || '79, 70, 229').trim();
    }

    function mapColor(value, maxValue, isDark) {
        if (!value || !maxValue) return null;
        var ratio = Math.min(value / maxValue, 1);
        var op = (0.2 + ratio * 0.75).toFixed(2);
        // En light on assombrit un peu pour garder du contraste.
        if (isDark) return 'rgba(' + getAccentRgb() + ', ' + op + ')';
        return 'rgba(' + getAccentRgb() + ', ' + op + ')';
    }

    function showMapTooltip(tooltip, data) {
        if (!tooltip) return;
        var html = '<div class="cs-tt-country">' + escapeHtml(data.name) + ' (' + data.iso + ')</div>'
            + '<div class="cs-tt-row"><span>Commandes</span><span class="cs-tt-val">' + data.orders + '</span></div>'
            + '<div class="cs-tt-row"><span>CA</span><span class="cs-tt-val">' + (Math.round(data.revenue * 100) / 100).toLocaleString('fr-FR') + '\u20ac</span></div>'
            + '<div class="cs-tt-row"><span>% commandes</span><span class="cs-tt-val">' + data.pct_orders + '%</span></div>';
        tooltip.innerHTML = html;
        tooltip.style.display = 'block';
    }

    function positionTooltip(tooltip, e, container) {
        if (!tooltip || !container) return;
        var rect = container.getBoundingClientRect();
        var x = e.clientX - rect.left + 15;
        var y = e.clientY - rect.top - 10;
        if (x + tooltip.offsetWidth > rect.width) {
            x = e.clientX - rect.left - tooltip.offsetWidth - 15;
        }
        tooltip.style.left = x + 'px';
        tooltip.style.top = y + 'px';
    }

    function highlightRank(iso, on) {
        var item = document.querySelector('.cs-country-rank-item[data-iso="' + iso + '"]');
        if (item) item.classList.toggle('cs-rank-highlight', on);
    }

    function escapeHtml(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    // ── Filtre pays global ──
    window.csCountryFilter = (function () {
        var c = new URLSearchParams(window.location.search).get('country');
        return c && /^[A-Z]{2}$/.test(c.toUpperCase()) ? c.toUpperCase() : null;
    })();

    function applyCountryFilter(iso) {
        window.csCountryFilter = iso || null;
        var url = new URL(window.location.href);
        if (iso) {
            url.searchParams.set('country', iso);
        } else {
            url.searchParams.delete('country');
        }
        window.history.replaceState({}, '', url.toString());
        updateCountryFilterBadge();
        refreshAllSections();
    }

    function initCountryFilterBadge() {
        var badge = document.getElementById('cs-country-filter-badge');
        if (!badge) return;
        badge.addEventListener('click', function () { applyCountryFilter(null); });
        updateCountryFilterBadge();
    }

    function updateCountryFilterBadge() {
        var badge = document.getElementById('cs-country-filter-badge');
        var label = document.getElementById('cs-country-filter-label');
        if (!badge || !label) return;
        if (window.csCountryFilter) {
            // Trouve le nom dans le data du country_map si présent
            var name = window.csCountryFilter;
            var section = document.querySelector('[data-cs-section="country_map"]');
            if (section) {
                try {
                    var data = JSON.parse(section.getAttribute('data-country-data') || '{}') || {};
                    if (data[window.csCountryFilter] && data[window.csCountryFilter].name) {
                        name = data[window.csCountryFilter].name;
                    }
                } catch (e) {}
            }
            label.textContent = name;
            badge.classList.remove('d-none');
        } else {
            badge.classList.add('d-none');
        }
    }

    // ── Charts (Chart.js) — 2 sections distinctes ──
    var csChartLine = null;
    var csChartBar = null;
    var csChartSav = null;

    function initLineChart() {
        if (typeof Chart === 'undefined') return;
        var section = document.querySelector('[data-cs-section="orders_chart"]');
        if (!section) return;
        var canvas = document.getElementById('cs-chart-line');
        if (!canvas) return;

        var labels  = parseDataAttr(section, 'data-chart-labels', []);
        var orders  = parseDataAttr(section, 'data-chart-orders', []);
        var revenue = parseDataAttr(section, 'data-chart-revenue', []);
        var ordersCompare  = parseDataAttr(section, 'data-chart-orders-compare', []);
        var revenueCompare = parseDataAttr(section, 'data-chart-revenue-compare', []);
        var isDark = (document.documentElement.getAttribute('data-bs-theme') || 'dark') === 'dark';
        var theme = document.documentElement.getAttribute('data-cs-theme');
        var isBrutal = theme === 'brutalist';
        var isTerm   = theme === 'terminal';
        var gridColor = isBrutal ? 'rgba(13,13,13,0.25)' : (isTerm ? 'rgba(168,255,96,0.15)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)'));
        var tickColor = isBrutal ? '#0d0d0d' : (isTerm ? '#5a6b5a' : (isDark ? '#9498a8' : '#6b7280'));

        if (csChartLine) csChartLine.destroy();
        var opts = chartCommonOptions(gridColor, tickColor, 'orders');
        if (isBrutal || isTerm) {
            // Pointillés gridlines (Chart.js 4 : borderDash sur grid + tickBorderDash)
            opts.scales.y.grid = {
                color: gridColor,
                borderDash: [4, 4],
                tickBorderDash: [4, 4],
                drawTicks: false,
                lineWidth: 0.5,
                display: true
            };
            opts.scales.y.border = { display: false, dash: [4, 4] };
            opts.scales.y.ticks = Object.assign({}, opts.scales.y.ticks, {
                maxTicksLimit: 4,
                font: { family: 'JetBrains Mono, monospace', size: 10 },
                color: tickColor,
                padding: 8
            });
            opts.scales.x.grid = { display: false };
            opts.scales.x.border = { display: false };
            opts.scales.x.ticks = Object.assign({}, opts.scales.x.ticks, {
                autoSkip: true,
                maxRotation: 0,
                font: { family: 'JetBrains Mono, monospace', size: 10 },
                color: tickColor
            });
        }
        var datasets = [buildLineDataset(orders, 'Commandes', getAccentColor())];
        if (ordersCompare && ordersCompare.length) {
            datasets.push(buildCompareDataset(ordersCompare, 'Commandes (préc.)', getAccentColor()));
        }
        csChartLine = new Chart(canvas.getContext('2d'), {
            type: 'line',
            data: { labels: labels, datasets: datasets },
            options: opts
        });
        bindLineToggle(orders, revenue, ordersCompare, revenueCompare);
    }

    // Courbe des demandes SAV (même rendu que la courbe des commandes, sans bascule de métrique)
    function initSavChart() {
        if (typeof Chart === 'undefined') return;
        var section = document.querySelector('[data-cs-section="sav_chart"]');
        if (!section) return;
        var canvas = document.getElementById('cs-chart-sav');
        if (!canvas) return;
        var labels     = parseDataAttr(section, 'data-chart-labels', []);
        var sav        = parseDataAttr(section, 'data-chart-sav', []);
        var savCompare = parseDataAttr(section, 'data-chart-sav-compare', []);
        var isDark = (document.documentElement.getAttribute('data-bs-theme') || 'dark') === 'dark';
        var theme = document.documentElement.getAttribute('data-cs-theme');
        var isBrutal = theme === 'brutalist';
        var isTerm = theme === 'terminal';
        var gridColor = isBrutal ? 'rgba(13,13,13,0.25)' : (isTerm ? 'rgba(168,255,96,0.15)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)'));
        var tickColor = isBrutal ? '#0d0d0d' : (isTerm ? '#5a6b5a' : (isDark ? '#9498a8' : '#6b7280'));
        if (csChartSav) csChartSav.destroy();
        var opts = chartCommonOptions(gridColor, tickColor, 'orders');
        opts.plugins.tooltip.callbacks.label = function (ctx) {
            var pre = (ctx.chart.data.datasets.length > 1 && ctx.dataset.label) ? ctx.dataset.label + ' : ' : '';
            return ' ' + pre + ctx.parsed.y + ' dem.';
        };
        var datasets = [buildLineDataset(sav, 'Demandes SAV', getAccentColor())];
        if (savCompare && savCompare.length) {
            datasets.push(buildCompareDataset(savCompare, 'Demandes SAV (préc.)', getAccentColor()));
        }
        csChartSav = new Chart(canvas.getContext('2d'), {
            type: 'line',
            data: { labels: labels, datasets: datasets },
            options: opts
        });
    }

    // Type de graphe paiements choisi par l'utilisateur (mémorisé par personne)
    function paymentChartType() {
        try { var t = localStorage.getItem('cs_payment_chart_type'); return (t === 'hbar' || t === 'doughnut') ? t : 'bar'; }
        catch (e) { return 'bar'; }
    }
    function setPaymentChartType(t) { try { localStorage.setItem('cs_payment_chart_type', t); } catch (e) {} }

    // Terminal : wrap les labels longs sur 2-3 lignes max
    function csSplitLabel(s, maxChars, maxLines) {
        s = String(s || '');
        if (s.length <= maxChars) return s;
        var words = s.split(/\s+/), lines = [], cur = '';
        for (var i = 0; i < words.length; i++) {
            var test = cur ? cur + ' ' + words[i] : words[i];
            if (test.length <= maxChars || !cur) { cur = test; }
            else { lines.push(cur); cur = words[i]; }
        }
        if (cur) lines.push(cur);
        if (lines.length > maxLines) {
            var tail = lines.slice(maxLines - 1).join(' ');
            if (tail.length > maxChars + 1) tail = tail.slice(0, maxChars) + '…';
            lines = lines.slice(0, maxLines - 1).concat([tail]);
        }
        return lines.length > 1 ? lines : s;
    }

    // Palette du donut : accent en tête, puis couleurs distinctes
    function csPaletteColors(n) {
        var base = ['#06B6D4', '#F59E0B', '#10B981', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316'];
        var acc = getAccentColor();
        var arr = [acc];
        for (var i = 0; i < base.length && arr.length < n; i++) {
            if (base[i].toLowerCase() !== String(acc).toLowerCase()) arr.push(base[i]);
        }
        while (arr.length < n) arr.push(base[arr.length % base.length]);
        return arr.slice(0, n);
    }

    // Rendu du graphe paiements selon le type (bar | hbar | doughnut) et la métrique (commandes | CA)
    function renderPaymentChart(breakdown, type, isRevenue) {
        var canvas = document.getElementById('cs-chart-bar');
        if (!canvas || typeof Chart === 'undefined') return;
        var isDark = (document.documentElement.getAttribute('data-bs-theme') || 'dark') === 'dark';
        var isTerm = document.documentElement.getAttribute('data-cs-theme') === 'terminal';
        var gridColor = isTerm ? 'rgba(168,255,96,0.10)' : (isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.06)');
        var tickColor = isTerm ? '#5a6b5a' : (isDark ? '#9498a8' : '#6b7280');
        var metricLabel = isRevenue ? 'CA' : 'Commandes';
        var data = breakdown.map(function (b) { return isRevenue ? b.revenue : b.orders; });
        var fmtVal = function (v) {
            return isRevenue ? (v.toLocaleString('fr-FR', { maximumFractionDigits: 0 }) + ' €') : (v + ' cmd');
        };

        if (csChartBar) csChartBar.destroy();

        // ── Donut / camembert ──
        if (type === 'doughnut') {
            var colors = csPaletteColors(data.length);
            var total = data.reduce(function (a, b) { return a + (b || 0); }, 0);
            csChartBar = new Chart(canvas.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: breakdown.map(function (b) { return b.label; }),
                    datasets: [{ data: data, backgroundColor: colors, borderColor: isDark ? '#1a1d28' : '#fff', borderWidth: 2 }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false, cutout: '58%',
                    plugins: {
                        legend: { position: 'right', labels: { color: tickColor, font: { size: 12 }, boxWidth: 12, usePointStyle: true, pointStyle: 'circle' } },
                        tooltip: {
                            backgroundColor: '#1a1d28', titleColor: '#fff', bodyColor: '#9498a8',
                            borderColor: '#2a2d3a', borderWidth: 1, cornerRadius: 8, padding: 10,
                            callbacks: {
                                label: function (ctx) {
                                    var pct = total > 0 ? Math.round((ctx.parsed / total) * 100) : 0;
                                    return ' ' + ctx.label + ' : ' + fmtVal(ctx.parsed) + ' (' + pct + '%)';
                                }
                            }
                        }
                    }
                }
            });
            return;
        }

        // ── Barres (verticales 'bar' ou horizontales 'hbar') ──
        var isH = (type === 'hbar');
        var barLabels = breakdown.map(function (b) { return (isTerm && !isH) ? csSplitLabel(b.label, 16, 3) : b.label; });
        var barConfig;
        if (isTerm) {
            var phosphor = (document.documentElement.getAttribute('data-bs-theme') === 'light') ? '42,111,31' : '168,255,96';
            var opacities = [1, 0.65, 0.35, 0.2, 0.15, 0.1];
            var bg = data.map(function (_, i) { return 'rgba(' + phosphor + ',' + (opacities[i] || 0.1) + ')'; });
            barConfig = { label: metricLabel, data: data, backgroundColor: bg, borderColor: 'transparent', borderRadius: 0, borderSkipped: false, barPercentage: 0.7, categoryPercentage: 0.85 };
        } else {
            barConfig = { label: metricLabel, data: data, backgroundColor: isRevenue ? '#06B6D4' : getAccentColor(), borderRadius: 6 };
        }
        // mode 'orders' → pas de callback auto sur l'axe Y ; on gère le formatage nous-mêmes (orientation + métrique)
        var opts = chartCommonOptions(gridColor, tickColor, 'orders', 'bar');
        opts.indexAxis = isH ? 'y' : 'x';
        opts.plugins.tooltip.callbacks.label = function (ctx) {
            return ' ' + fmtVal(isH ? ctx.parsed.x : ctx.parsed.y);
        };
        if (isRevenue) {
            var valAxis = isH ? opts.scales.x : opts.scales.y;
            valAxis.ticks = Object.assign({}, valAxis.ticks, {
                callback: function (val) { return val >= 1000 ? (val / 1000).toFixed(0) + 'k€' : val + '€'; }
            });
        }
        if (isTerm) {
            var vScale = isH ? opts.scales.x : opts.scales.y;
            var cScale = isH ? opts.scales.y : opts.scales.x;
            vScale.grid = { color: gridColor, borderDash: [4, 4], tickBorderDash: [4, 4], drawTicks: false, lineWidth: 0.5, display: true };
            vScale.border = { display: false };
            vScale.ticks = Object.assign({}, vScale.ticks, { font: { family: 'JetBrains Mono, monospace', size: 9 }, color: tickColor, maxTicksLimit: 4 });
            cScale.grid = { display: false };
            cScale.border = { display: false };
            cScale.ticks = Object.assign({}, cScale.ticks, { autoSkip: false, maxRotation: 0, font: { family: 'JetBrains Mono, monospace', size: 9 }, color: tickColor });
        }
        csChartBar = new Chart(canvas.getContext('2d'), {
            type: 'bar',
            data: { labels: barLabels, datasets: [barConfig] },
            options: opts
        });
    }

    function initBarChart() {
        if (typeof Chart === 'undefined') return;
        var section = document.querySelector('[data-cs-section="payment_breakdown"]');
        if (!section) return;
        var canvas = document.getElementById('cs-chart-bar');
        if (!canvas) return;
        var breakdown = parseDataAttr(section, 'data-chart-breakdown', []);
        var toggle = document.getElementById('cs-bar-mode-toggle');
        renderPaymentChart(breakdown, paymentChartType(), toggle ? toggle.checked : false);
        bindPaymentControls(breakdown);
    }

    function buildLineDataset(data, label, color) {
        var theme = document.documentElement.getAttribute('data-cs-theme');
        if (theme === 'terminal') {
            var isLight = document.documentElement.getAttribute('data-bs-theme') === 'light';
            var phosphor = isLight ? '#2a6f1f' : '#a8ff60';
            return {
                label: label,
                data: data,
                borderColor: phosphor,
                backgroundColor: 'transparent',
                borderWidth: 1.5,
                borderJoinStyle: 'miter',
                borderCapStyle: 'square',
                pointStyle: 'rect',
                pointRadius: 6,
                pointHoverRadius: 8,
                pointBackgroundColor: phosphor,
                pointBorderColor: phosphor,
                pointBorderWidth: 0,
                tension: 0,
                fill: false
            };
        }
        if (theme === 'brutalist') {
            return {
                label: label,
                data: data,
                borderColor: '#0d0d0d',
                backgroundColor: 'transparent',
                borderWidth: 3.5,
                borderJoinStyle: 'miter',
                borderCapStyle: 'square',
                pointStyle: 'rect',
                pointRadius: 5,
                pointHoverRadius: 7,
                pointBackgroundColor: '#ffd23f',
                pointBorderColor: '#0d0d0d',
                pointBorderWidth: 2,
                tension: 0,
                fill: false
            };
        }
        return {
            label: label,
            data: data,
            borderColor: color,
            backgroundColor: hexToRgba(color, 0.12),
            borderWidth: 2,
            pointRadius: 3,
            pointHoverRadius: 5,
            tension: 0.3,
            fill: true
        };
    }

    // Dataset de la période de comparaison : même forme/couleur que la série courante,
    // mais en pointillé, atténué, sans remplissage ni points — dessiné derrière.
    function buildCompareDataset(data, label, color) {
        var ds = buildLineDataset(data, label, color);
        ds.borderDash = [5, 4];
        ds.fill = false;
        ds.backgroundColor = 'transparent';
        ds.borderWidth = Math.max(1, (ds.borderWidth || 2) - 0.5);
        ds.pointRadius = 0;
        ds.pointHoverRadius = 3;
        ds.tension = ds.tension || 0;
        ds.order = 2;
        if (typeof ds.borderColor === 'string' && ds.borderColor.charAt(0) === '#') {
            ds.borderColor = hexToRgba(ds.borderColor, 0.6);
        }
        return ds;
    }

    function chartCommonOptions(gridColor, tickColor, mode, type) {
        var opts = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#1a1d28',
                    titleColor: '#fff',
                    bodyColor: '#9498a8',
                    borderColor: '#2a2d3a',
                    borderWidth: 1,
                    cornerRadius: 8,
                    padding: 10,
                    callbacks: {
                        label: function (ctx) {
                            var suffix = mode === 'revenue' ? ' \u20ac' : ' cmd';
                            var v = mode === 'revenue'
                                ? ctx.parsed.y.toLocaleString('fr-FR', { maximumFractionDigits: 0 })
                                : ctx.parsed.y;
                            var pre = (ctx.chart.data.datasets.length > 1 && ctx.dataset.label)
                                ? ctx.dataset.label + ' : ' : '';
                            return ' ' + pre + v + suffix;
                        }
                    }
                }
            },
            scales: {
                x: { grid: { display: false }, ticks: { color: tickColor, font: { size: 11 } } },
                y: { grid: { color: gridColor, drawTicks: false },
                     ticks: { color: tickColor, font: { size: 11 }, padding: 8 },
                     beginAtZero: true }
            }
        };
        if (mode === 'revenue') {
            opts.scales.y.ticks.callback = function (val) {
                return val >= 1000 ? (val / 1000).toFixed(0) + 'k\u20ac' : val + '\u20ac';
            };
        }
        return opts;
    }

    function bindLineToggle(orders, revenue, ordersCompare, revenueCompare) {
        var toggle = document.getElementById('cs-line-mode-toggle');
        if (!toggle) return;
        ordersCompare = ordersCompare || [];
        revenueCompare = revenueCompare || [];
        toggle.addEventListener('change', function () {
            var rev = toggle.checked;
            csChartLine.data.datasets[0] = rev
                ? buildLineDataset(revenue, 'CA', '#06B6D4')
                : buildLineDataset(orders, 'Commandes', getAccentColor());
            // Série de comparaison (si présente) — suit le mode actif
            var cmp = rev ? revenueCompare : ordersCompare;
            if (cmp && cmp.length) {
                csChartLine.data.datasets[1] = buildCompareDataset(
                    cmp, (rev ? 'CA' : 'Commandes') + ' (préc.)', rev ? '#06B6D4' : getAccentColor());
            } else if (csChartLine.data.datasets.length > 1) {
                csChartLine.data.datasets.splice(1, 1);
            }
            updateChartMode(csChartLine, rev);
            csChartLine.update();
            toggleModeLabels(document.querySelectorAll('.cs-line-mode-label'), rev);
        });
        // Permet de cliquer sur les labels pour basculer le mode (brutalist sans switch visuel)
        document.querySelectorAll('.cs-line-mode-label').forEach(function (lbl) {
            lbl.addEventListener('click', function () {
                var target = lbl.getAttribute('data-mode') === 'revenue';
                if (toggle.checked !== target) {
                    toggle.checked = target;
                    toggle.dispatchEvent(new Event('change', { bubbles: true }));
                }
            });
        });
    }

    function bindPaymentControls(breakdown) {
        var toggle = document.getElementById('cs-bar-mode-toggle');
        function metric() { return toggle ? toggle.checked : false; }

        // Bascule métrique Commandes / CA
        if (toggle) {
            toggle.addEventListener('change', function () {
                renderPaymentChart(breakdown, paymentChartType(), toggle.checked);
                toggleModeLabels(document.querySelectorAll('.cs-bar-mode-label, .cs-payment-term-sort-label'), toggle.checked);
            });
            // Clic sur les labels (terminal sans switch visuel)
            document.querySelectorAll('.cs-payment-term-sort-label').forEach(function (lbl) {
                lbl.addEventListener('click', function () {
                    var target = lbl.getAttribute('data-mode') === 'revenue';
                    if (toggle.checked !== target) {
                        toggle.checked = target;
                        toggle.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                });
            });
        }

        // Sélecteur de type de graphe (barres V / barres H / donut), mémorisé par utilisateur
        var switchEl = document.querySelector('[data-chart-type-switch]');
        if (switchEl) {
            var cur = paymentChartType();
            var btns = switchEl.querySelectorAll('.cs-chart-type-btn');
            btns.forEach(function (btn) {
                btn.classList.toggle('is-active', btn.getAttribute('data-type') === cur);
                btn.addEventListener('click', function () {
                    var t = btn.getAttribute('data-type');
                    setPaymentChartType(t);
                    btns.forEach(function (b) { b.classList.toggle('is-active', b === btn); });
                    renderPaymentChart(breakdown, t, metric());
                });
            });
        }
    }

    function updateChartMode(chart, isRevenue) {
        var suffix = isRevenue ? ' \u20ac' : ' cmd';
        chart.options.plugins.tooltip.callbacks.label = function (ctx) {
            var v = isRevenue
                ? ctx.parsed.y.toLocaleString('fr-FR', { maximumFractionDigits: 0 })
                : ctx.parsed.y;
            var pre = (ctx.chart.data.datasets.length > 1 && ctx.dataset.label)
                ? ctx.dataset.label + ' : ' : '';
            return ' ' + pre + v + suffix;
        };
        chart.options.scales.y.ticks.callback = isRevenue
            ? function (val) { return val >= 1000 ? (val / 1000).toFixed(0) + 'k\u20ac' : val + '\u20ac'; }
            : function (val) { return val; };
    }

    function toggleModeLabels(labels, isRevenue) {
        labels.forEach(function (l) {
            var active = (l.dataset.mode === 'revenue') === isRevenue;
            l.classList.toggle('cs-active', active);
            l.classList.toggle('text-muted', !active);
        });
    }

    function parseDataAttr(el, attr, fallback) {
        try { return JSON.parse(el.getAttribute(attr) || ''); } catch (e) { return fallback; }
    }

    function hexToRgba(hex, alpha) {
        var h = hex.replace('#', '');
        if (h.length === 3) h = h.split('').map(function (c) { return c + c; }).join('');
        var r = parseInt(h.substring(0, 2), 16);
        var g = parseInt(h.substring(2, 4), 16);
        var b = parseInt(h.substring(4, 6), 16);
        return 'rgba(' + r + ', ' + g + ', ' + b + ', ' + alpha + ')';
    }

    // ── Mode personnalisation des sections ──
    var csEditDirty = false;
    var csEditSaveTimer = null;

    function initCustomize() {
        var btn = document.getElementById('cs-customize-btn');
        var done = document.getElementById('cs-edit-done');
        var reset = document.getElementById('cs-edit-reset');
        if (btn) btn.addEventListener('click', toggleEditMode);
        if (done) done.addEventListener('click', exitEditMode);
        if (reset) reset.addEventListener('click', resetCustomization);
    }

    function resetCustomization() {
        if (!confirm('Revenir à l\'affichage par défaut ? Toutes vos préférences seront effacées.')) return;
        var btnReset = document.getElementById('cs-edit-reset');
        if (btnReset) btnReset.disabled = true;
        var status = document.getElementById('cs-edit-status');
        if (status) { status.textContent = 'Réinitialisation…'; status.classList.remove('cs-saved'); }

        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'resetSections');
        fetch(url.toString(), { method: 'POST' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data || !data.ok) throw new Error();
                window.location.reload();
            })
            .catch(function () {
                if (btnReset) btnReset.disabled = false;
                if (status) status.textContent = '⚠ Erreur';
            });
    }

    function toggleEditMode() {
        if (document.body.classList.contains('cs-edit-mode')) {
            exitEditMode();
        } else {
            enterEditMode();
        }
    }

    var csSortableInstance = null;

    function enterEditMode() {
        injectMissingSectionPlaceholders();
        injectSectionToggles();
        document.body.classList.add('cs-edit-mode');
        document.addEventListener('keydown', editKeyHandler);
        csEditDirty = false;
        initSortable();
    }

    function exitEditMode() {
        destroySortable();
        document.body.classList.remove('cs-edit-mode');
        document.removeEventListener('keydown', editKeyHandler);
        if (csEditDirty) {
            window.location.reload();
            return;
        }
        document.querySelectorAll('.cs-section-placeholder').forEach(function (el) { el.remove(); });
    }

    function initSortable() {
        if (typeof Sortable === 'undefined') return;
        var firstSection = document.querySelector('[data-cs-section]');
        if (!firstSection) return;
        var container = firstSection.parentNode;
        if (csSortableInstance) csSortableInstance.destroy();
        csSortableInstance = new Sortable(container, {
            handle: '.cs-edit-handle:not(.cs-edit-handle-locked)',
            draggable: '.cs-section-draggable',
            ghostClass: 'cs-sortable-ghost',
            chosenClass: 'cs-sortable-chosen',
            dragClass:  'cs-sortable-drag',
            animation: 180,
            forceFallback: false,
            onEnd: function () {
                persistSectionsOrder();
            }
        });
    }

    function destroySortable() {
        if (csSortableInstance) {
            csSortableInstance.destroy();
            csSortableInstance = null;
        }
    }

    /**
     * Calcule le nouvel ordre depuis le DOM et persiste en batch via saveSections.
     */
    function persistSectionsOrder() {
        var sections = [];
        var order = 10;
        document.querySelectorAll('[data-cs-section]').forEach(function (sec) {
            var cb = sec.querySelector('.cs-edit-cb');
            if (!cb) return; // required → ne pas envoyer (whitelist PHP les rejette)
            sections.push({
                id: sec.dataset.csSection,
                enabled: cb.checked ? 1 : 0,
                display_order: order
            });
            order += 10;
        });

        if (!sections.length) return;
        csEditDirty = true;
        var status = document.getElementById('cs-edit-status');
        if (status) { status.textContent = 'Réordonnement…'; status.classList.remove('cs-saved'); }

        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'saveSections');
        fetch(url.toString(), {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ sections: sections })
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (status) {
                    if (data && data.ok) {
                        status.textContent = '✓ Ordre enregistré';
                        status.classList.add('cs-saved');
                    } else {
                        status.textContent = '⚠ Erreur';
                    }
                }
            })
            .catch(function () {
                if (status) status.textContent = '⚠ Erreur réseau';
            });
    }

    /**
     * Crée un placeholder pour chaque section désactivée (absente du DOM).
     * Permet de la réactiver via le mode édition.
     */
    function injectMissingSectionPlaceholders() {
        var missing = window.CS_MISSING_SECTIONS || [];
        var meta = window.CS_SECTIONS_META || {};
        if (!missing.length) return;

        // Conteneur où injecter — on prend le parent commun des sections existantes.
        var firstSection = document.querySelector('[data-cs-section]');
        if (!firstSection) return;
        var container = firstSection.parentNode;

        missing.forEach(function (id) {
            if (document.querySelector('[data-cs-section="' + id + '"]')) return;
            var info = meta[id] || { title: id };
            var ph = document.createElement('div');
            ph.className = 'cs-section cs-section-placeholder cs-section-disabled';
            ph.setAttribute('data-cs-section', id);
            ph.innerHTML = '<div class="text-muted small text-center py-3"><i class="bi bi-eye-slash me-2"></i>'
                + escapeHtml(info.title) + ' <span class="cs-placeholder-tag">(masqué)</span></div>';
            container.appendChild(ph);
        });

        // Trier les sections (visibles + placeholders) par order défini dans CS_SECTIONS_META.
        var nodes = Array.prototype.slice.call(container.querySelectorAll('[data-cs-section]'));
        nodes.sort(function (a, b) {
            var oa = (meta[a.dataset.csSection] || {}).order || 100;
            var ob = (meta[b.dataset.csSection] || {}).order || 100;
            return oa - ob;
        });
        nodes.forEach(function (n) { container.appendChild(n); });
    }

    function editKeyHandler(e) {
        if (e.key === 'Escape') {
            e.preventDefault();
            exitEditMode();
        }
    }

    /**
     * Injecte un toggle d'édition au-dessus de chaque section non-required.
     * Idempotent : ne ré-injecte pas si déjà présent.
     */
    function injectSectionToggles() {
        var meta = window.CS_SECTIONS_META || {};
        document.querySelectorAll('[data-cs-section]').forEach(function (sec) {
            if (sec.querySelector(':scope > .cs-edit-toggle-wrap')) return;
            var id = sec.dataset.csSection;
            var title = (meta[id] && meta[id].title) ? meta[id].title : id;

            var isRequired = (window.CS_REQUIRED_SECTIONS || []).indexOf(id) > -1;
            var isPlaceholder = sec.classList.contains('cs-section-placeholder');
            var initialChecked = !isPlaceholder;

            var label = document.createElement('label');
            label.className = 'cs-edit-toggle-wrap';
            if (isRequired) {
                label.innerHTML = '<span class="cs-edit-handle cs-edit-handle-locked" title="Section obligatoire — non déplaçable"><i class="bi bi-lock-fill"></i></span>'
                    + '<input type="checkbox" checked disabled>'
                    + '<span class="cs-edit-section-title">' + escapeHtml(title) + '</span>'
                    + '<span class="cs-edit-section-required">Obligatoire</span>';
                sec.classList.add('cs-section-required');
            } else {
                label.innerHTML = '<span class="cs-edit-handle" title="Glisser pour réordonner"><i class="bi bi-grip-vertical"></i></span>'
                    + '<input type="checkbox" class="cs-edit-cb" data-section-id="' + escapeHtml(id) + '"' + (initialChecked ? ' checked' : '') + '>'
                    + '<span class="cs-edit-section-title">' + escapeHtml(title) + '</span>';
                sec.classList.add('cs-section-draggable');
            }
            sec.insertBefore(label, sec.firstChild);

            var cb = label.querySelector('.cs-edit-cb');
            if (cb) {
                cb.addEventListener('change', function () {
                    sec.classList.toggle('cs-section-disabled', !cb.checked);
                    saveSectionPref(id, cb.checked);
                });
            }
        });
    }

    /**
     * Save AJAX d'une seule section (debouncé pour éviter le spam si l'utilisateur clique vite).
     */
    function saveSectionPref(sectionId, enabled) {
        csEditDirty = true;
        var status = document.getElementById('cs-edit-status');
        if (status) { status.textContent = 'Enregistrement…'; status.classList.remove('cs-saved'); }

        if (csEditSaveTimer) clearTimeout(csEditSaveTimer);
        csEditSaveTimer = setTimeout(function () {
            var url = new URL(window.location.href);
            url.searchParams.set('ajax', '1');
            url.searchParams.set('action', 'saveSections');
            fetch(url.toString(), {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ sections: [{ id: sectionId, enabled: enabled ? 1 : 0, display_order: 100 }] })
            })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    if (status) {
                        if (data && data.ok) {
                            status.textContent = '✓ Enregistré';
                            status.classList.add('cs-saved');
                        } else {
                            status.textContent = '⚠ Erreur';
                        }
                    }
                })
                .catch(function () {
                    if (status) status.textContent = '⚠ Erreur réseau';
                });
        }, 200);
    }


    // ── Activité récente : Voir plus ──
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.cs-activity-toggle');
        if (!btn) return;
        var section = btn.closest('.cs-activity-section');
        if (!section) return;
        var expanded = section.classList.toggle('cs-activity-expanded');
        var label = btn.querySelector('span');
        var icon = btn.querySelector('i');
        if (label) label.textContent = expanded ? 'Voir moins' : 'Voir plus';
        if (icon) icon.className = expanded ? 'bi bi-chevron-up me-1' : 'bi bi-chevron-down me-1';
    });

    // ── Sections collapsibles ──
    function initCollapsibles() {
        document.addEventListener('click', function (e) {
            var toggle = e.target.closest('.cs-collapse-toggle');
            if (!toggle) return;
            var section = toggle.closest('.cs-collapsible');
            if (!section) return;
            section.classList.toggle('cs-collapsed');
        });
    }

    // ── Modal Top retours ──
    function initReturnsModal() {
        document.addEventListener('click', function (e) {
            var card = e.target.closest('.cs-kpi-card[data-stat="returns"]');
            if (!card) return;
            openReturnsModal();
        });
        // Drill-down sur les KPI cliquables : scroll + filtre du tableau commandes
        document.addEventListener('click', function (e) {
            var card = e.target.closest('.cs-kpi-clickable[data-drill]');
            if (!card) return;
            // Clic sur les contrôles internes ne déclenche pas le drill
            if (e.target.closest('button, a, input, select')) return;
            drillToOrders(card.dataset.drill);
        });
        // Bouton de reset des chips drill (tri / nouveaux clients)
        document.addEventListener('click', function (e) {
            var clr = e.target.closest('[data-clear-drill]');
            if (!clr) return;
            e.stopPropagation();
            var url = new URL(window.location.href);
            url.searchParams.delete('orders_sort');
            url.searchParams.delete('orders_customers');
            url.searchParams.delete('orders_page');
            window.history.replaceState({}, '', url.toString());
            if (typeof refreshSection === 'function') refreshSection('recent_orders');
        });

        // Toggle Remboursées / Annulées dans le modal retours.
        var typeToggle = document.getElementById('cs-returns-type-toggle');
        if (typeToggle) {
            typeToggle.addEventListener('change', function () {
                csReturnsType = typeToggle.checked ? 'cancelled' : 'refunded';
                updateReturnsLabels();
                loadReturns();
            });
        }
        document.querySelectorAll('.cs-returns-mode-label').forEach(function (lbl) {
            lbl.addEventListener('click', function () {
                var t = lbl.getAttribute('data-type');
                if (!t || t === csReturnsType) return;
                csReturnsType = t;
                if (typeToggle) typeToggle.checked = (t === 'cancelled');
                updateReturnsLabels();
                loadReturns();
            });
        });
    }

    var csReturnsType = 'refunded';

    function updateReturnsLabels() {
        document.querySelectorAll('.cs-returns-mode-label').forEach(function (lbl) {
            lbl.classList.toggle('cs-active', lbl.getAttribute('data-type') === csReturnsType);
        });
    }

    function drillToOrders(drill) {
        var ordersSection = document.querySelector('[data-cs-section="recent_orders"]');
        if (!ordersSection) return;

        // Si la section est repliée → on déplie d'abord
        if (ordersSection.classList.contains('cs-collapsed')) {
            ordersSection.classList.remove('cs-collapsed');
        }

        // Mapping drill → params (status / sort / customers). On reset les autres pour cohérence.
        var drillMap = {
            orders:        { status: 'all',       sort: '',       customers: '' },
            revenue:       { status: 'all',       sort: '',       customers: '' },
            pending:       { status: 'preparing', sort: '',       customers: '' },
            basket:        { status: 'all',       sort: 'basket', customers: '' },
            items:         { status: 'all',       sort: 'items',  customers: '' },
            new_customers: { status: 'all',       sort: '',       customers: 'new' }
        };
        var conf = drillMap[drill] || drillMap.orders;

        // applyFilter pousse une seule URL update — on bypasse en construisant l'URL directement
        var url = new URL(window.location.href);
        url.searchParams.set('orders_status', conf.status);
        if (conf.sort)      { url.searchParams.set('orders_sort', conf.sort); }       else { url.searchParams.delete('orders_sort'); }
        if (conf.customers) { url.searchParams.set('orders_customers', conf.customers); } else { url.searchParams.delete('orders_customers'); }
        url.searchParams.delete('orders_page');
        window.history.replaceState({}, '', url.toString());

        // Refresh + scroll conditionnel (uniquement si la section n'est pas déjà visible)
        if (typeof refreshSection === 'function') {
            refreshSection('recent_orders');
        }
        setTimeout(function () {
            var fresh = document.querySelector('[data-cs-section="recent_orders"]');
            if (!fresh) return;
            var rect = fresh.getBoundingClientRect();
            var vh = window.innerHeight || document.documentElement.clientHeight;
            var isVisible = rect.top < vh * 0.7 && rect.bottom > 0;
            if (!isVisible) {
                fresh.scrollIntoView({ behavior: 'smooth', block: 'start' });
            } else {
                // Flash visuel léger pour indiquer le changement
                fresh.classList.add('cs-flash');
                setTimeout(function () { fresh.classList.remove('cs-flash'); }, 800);
            }
        }, 400);
    }

    function openReturnsModal() {
        var modalEl = document.getElementById('cs-modal-top-returns');
        if (!modalEl || !window.bootstrap) return;
        var modal = window.bootstrap.Modal.getOrCreateInstance(modalEl);
        // Réinitialise sur "Remboursées" (défaut) à chaque ouverture.
        csReturnsType = 'refunded';
        var toggle = document.getElementById('cs-returns-type-toggle');
        if (toggle) toggle.checked = false;
        updateReturnsLabels();
        modal.show();
        loadReturns();
    }

    function loadReturns() {
        var body = document.getElementById('cs-modal-returns-body');
        var subtitle = document.getElementById('cs-modal-returns-subtitle');
        if (body) body.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-secondary"></div></div>';
        if (subtitle) subtitle.textContent = '';

        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'getTopReturns');
        url.searchParams.set('returns_type', csReturnsType);
        fetch(url.toString())
            .then(csParseJson)
            .then(function (data) {
                renderReturnsModal(body, subtitle, data);
            })
            .catch(function () {
                if (body) body.innerHTML = '<div class="text-center text-danger py-4">Erreur chargement</div>';
            });
    }

    // Rendu groupé PAR COMMANDE : une carte par commande, articles l'un sous l'autre.
    function renderReturnsModal(body, subtitle, data) {
        if (!body) return;
        var orders = (data && data.orders) || [];
        var typeLabel = (data && data.type === 'cancelled') ? 'annulée' : 'remboursée';
        var n = (data && data.total_returns) || 0;
        if (subtitle) subtitle.textContent = n + ' commande' + (n > 1 ? 's' : '') + ' ' + typeLabel + (n > 1 ? 's' : '') + ' du ' + (data.date_from || '') + ' au ' + (data.date_to || '');
        if (!orders.length) {
            body.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-check-circle fs-2 d-block mb-2"></i>Aucun retour sur cette période</div>';
            return;
        }
        var html = '';
        orders.forEach(function (o) {
            html += '<div class="cs-return-order">';
            html += '<div class="cs-return-order-head">';
            html += '<a href="' + o.bo_link + '" target="_blank" class="cs-return-order-ref fw-bold text-decoration-none"><i class="bi bi-receipt me-1"></i>Commande ' + escapeHtml(o.reference) + ' <i class="bi bi-box-arrow-up-right" style="font-size:10px"></i></a>';
            html += '<span class="text-muted small ms-2">' + escapeHtml(o.date) + '</span>';
            if (o.state) html += '<span class="badge cs-return-state ms-2">' + escapeHtml(o.state) + '</span>';
            html += '<span class="ms-auto small text-muted me-3">' + o.total_qty + ' art.</span>';
            html += '<span class="fw-bold text-danger">' + Number(o.total_value).toLocaleString('fr-FR', { maximumFractionDigits: 2 }) + ' €</span>';
            html += '</div>';
            html += '<table class="table table-sm cs-table mb-0"><tbody>';
            (o.products || []).forEach(function (p) {
                var img = p.image
                    ? '<img src="' + p.image + '" alt="" class="rounded" style="width:34px;height:34px;object-fit:cover">'
                    : '<div class="rounded bg-secondary d-flex align-items-center justify-content-center" style="width:34px;height:34px"><i class="bi bi-image text-muted small"></i></div>';
                var ids = '';
                if (p.reference) ids += '<span class="text-muted">Réf:</span> ' + escapeHtml(p.reference);
                if (p.ean13) ids += (ids ? ' · ' : '') + '<span class="text-muted">EAN:</span> ' + escapeHtml(p.ean13);
                var nameCell = p.bo_link
                    ? '<a href="' + p.bo_link + '" target="_blank" class="cs-link text-decoration-none">' + escapeHtml(p.name) + '</a>'
                    : escapeHtml(p.name);
                html += '<tr>'
                    + '<td style="width:44px">' + img + '</td>'
                    + '<td class="small">' + nameCell + (ids ? '<br><span class="small">' + ids + '</span>' : '') + '</td>'
                    + '<td class="text-center fw-bold small text-nowrap">' + p.qty + ' ×</td>'
                    + '<td class="text-end fw-bold small text-danger text-nowrap">' + Number(p.value).toLocaleString('fr-FR', { maximumFractionDigits: 2 }) + ' €</td>'
                    + '</tr>';
            });
            html += '</tbody></table>';
            html += '</div>';
        });
        body.innerHTML = html;
    }

    // ── Modal Transporteurs ──
    var carriersData = [];
    var carriersSelected = {};

    function initCarriersModal() {
        document.addEventListener('click', function (e) {
            var trigger = e.target.closest('[data-cs-section="performance"]');
            if (!trigger) return;
            openCarriersModal();
        });
    }

    function openCarriersModal() {
        var modalEl = document.getElementById('cs-modal-carriers');
        if (!modalEl || !window.bootstrap) return;
        var modal = window.bootstrap.Modal.getOrCreateInstance(modalEl);
        var body = document.getElementById('cs-modal-carriers-body');
        var subtitle = document.getElementById('cs-modal-carriers-subtitle');
        if (body) body.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-secondary"></div></div>';
        if (subtitle) subtitle.textContent = '';
        modal.show();

        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'getCarriersStats');
        fetch(url.toString())
            .then(function (r) { return r.json(); })
            .then(function (data) {
                carriersData = (data && data.carriers) || [];
                carriersSelected = {};
                carriersData.forEach(function (c) { carriersSelected[c.id_carrier] = true; });
                if (subtitle) subtitle.textContent = (data.total_orders || 0) + ' commandes du ' + (data.date_from || '') + ' au ' + (data.date_to || '');
                renderCarriersDropdown();
                renderCarriersTable();
            })
            .catch(function () {
                if (body) body.innerHTML = '<div class="text-center text-danger py-4">Erreur chargement</div>';
            });
    }

    function renderCarriersDropdown() {
        var list = document.getElementById('cs-modal-carriers-dropdown-list');
        if (!list) return;
        var html = '';
        html += '<li><div class="form-check"><input class="form-check-input" type="checkbox" id="cs-carriers-all" checked>'
              + '<label class="form-check-label fw-bold" for="cs-carriers-all">Tout sélectionner</label></div></li>';
        html += '<li><hr class="dropdown-divider"></li>';
        carriersData.forEach(function (c) {
            var cid = 'cs-carrier-' + c.id_carrier;
            html += '<li><div class="form-check"><input class="form-check-input cs-carrier-cb" type="checkbox" id="' + cid + '" data-id="' + c.id_carrier + '" checked>'
                  + '<label class="form-check-label" for="' + cid + '">' + escapeHtml(c.name) + ' <small class="text-muted">(' + c.orders + ')</small></label></div></li>';
        });
        list.innerHTML = html;

        var allCb = document.getElementById('cs-carriers-all');
        if (allCb) {
            allCb.addEventListener('change', function () {
                var checked = this.checked;
                list.querySelectorAll('.cs-carrier-cb').forEach(function (cb) {
                    cb.checked = checked;
                    carriersSelected[cb.dataset.id] = checked;
                });
                renderCarriersTable();
                updateCarriersDropdownLabel();
            });
        }
        list.querySelectorAll('.cs-carrier-cb').forEach(function (cb) {
            cb.addEventListener('change', function () {
                carriersSelected[this.dataset.id] = this.checked;
                if (allCb) {
                    var all = Array.from(list.querySelectorAll('.cs-carrier-cb')).every(function (c) { return c.checked; });
                    allCb.checked = all;
                }
                renderCarriersTable();
                updateCarriersDropdownLabel();
            });
        });
        updateCarriersDropdownLabel();
    }

    function updateCarriersDropdownLabel() {
        var label = document.getElementById('cs-carriers-dropdown-label');
        if (!label) return;
        var total = carriersData.length;
        var selected = carriersData.filter(function (c) { return carriersSelected[c.id_carrier]; }).length;
        if (selected === total) label.textContent = 'Tous (' + total + ')';
        else if (selected === 0) label.textContent = 'Aucun';
        else if (selected === 1) {
            var only = carriersData.find(function (c) { return carriersSelected[c.id_carrier]; });
            label.textContent = only ? only.name : '1 sélectionné';
        } else label.textContent = selected + ' sélectionnés';
    }

    function renderCarriersTable() {
        var body = document.getElementById('cs-modal-carriers-body');
        if (!body) return;
        var visible = carriersData.filter(function (c) { return carriersSelected[c.id_carrier]; });
        if (!visible.length) {
            body.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-truck fs-2 d-block mb-2"></i>Aucun transporteur sélectionné</div>';
            return;
        }
        var html = '<div class="table-responsive"><table class="table table-sm cs-table mb-0">'
                 + '<thead><tr><th>Transporteur</th><th class="text-end">Commandes</th><th class="text-end">% du total</th><th class="text-end">Délai moyen</th></tr></thead><tbody>';
        visible.forEach(function (c) {
            var delay = c.avg_delay !== null && c.avg_delay !== undefined
                ? '<strong class="' + (c.avg_delay <= 2 ? 'text-success' : c.avg_delay <= 4 ? 'text-warning' : 'text-danger') + '">' + c.avg_delay + 'j</strong>'
                : '<span class="text-muted">N/A</span>';
            html += '<tr>'
                + '<td>' + escapeHtml(c.name) + '</td>'
                + '<td class="text-end fw-bold">' + c.orders + '</td>'
                + '<td class="text-end">' + c.pct_orders + '%</td>'
                + '<td class="text-end">' + delay + '</td>'
                + '</tr>';
        });
        html += '</tbody></table></div>';
        body.innerHTML = html;
    }

    // ── Mode présentation / TV (fullscreen) ──
    // ── Pill dropdowns : composant générique en remplacement des <select> natifs.
    //    Récupère data-filter sur le wrapper, applique le filtre au clic sur une option,
    //    met à jour le label et la classe active. Délégation pour survivre aux refresh AJAX. ──
    function initPillDropdowns() {
        // Capture phase pour s'exécuter avant les éventuels event.stopPropagation()
        // (par exemple sur .cs-orders-term-controls / .cs-orders-brutal-controls)
        document.addEventListener('click', function (e) {
            var opt = e.target.closest && e.target.closest('.cs-pill-option');
            if (!opt) return;
            var wrap = opt.closest('.cs-pill-dropdown');
            if (!wrap) return;
            var filterName = wrap.dataset.filter;
            var value = opt.dataset.value || '';
            wrap.querySelectorAll('.cs-pill-option').forEach(function (o) {
                o.classList.toggle('cs-active', o === opt);
            });
            var labelEl = wrap.querySelector('.cs-pill-label');
            if (labelEl) labelEl.textContent = opt.textContent.trim();
            var btn = wrap.querySelector('.cs-pill-btn');
            if (btn && window.bootstrap) {
                var dd = window.bootstrap.Dropdown.getInstance(btn);
                if (dd) dd.hide();
            }
            if (typeof applyFilter === 'function' && filterName) {
                applyFilter(filterName, value);
            }
        }, true);
    }

    // ── Scroll indicator : toggle .cs-scrolled sur html quand on scrolle (pour effet sticky header) ──
    function initScrollIndicator() {
        var SCROLL_THRESHOLD = 8;
        var html = document.documentElement;
        var ticking = false;
        function update() {
            var scrolled = (window.scrollY || window.pageYOffset) > SCROLL_THRESHOLD;
            html.classList.toggle('cs-scrolled', scrolled);
            ticking = false;
        }
        window.addEventListener('scroll', function () {
            if (!ticking) {
                requestAnimationFrame(update);
                ticking = true;
            }
        }, { passive: true });
        update();
    }

    function initFullscreen() {
        // Délégation pour résister aux re-renders (et garantir le binding même en cas de timing)
        document.addEventListener('click', function (e) {
            var btn = e.target.closest && e.target.closest('#cs-fullscreen-btn');
            if (!btn) return;
            e.preventDefault();
            toggleFullscreen();
        });
        document.addEventListener('fullscreenchange', updateFullscreenIcon);
        document.addEventListener('webkitfullscreenchange', updateFullscreenIcon);
    }

    function toggleFullscreen() {
        var doc = document;
        var el = doc.documentElement;
        var isFs = doc.fullscreenElement || doc.webkitFullscreenElement || doc.msFullscreenElement;
        if (!isFs) {
            var req = el.requestFullscreen || el.webkitRequestFullscreen || el.msRequestFullscreen;
            if (!req) {
                console.warn('[CoolStats] Fullscreen API non disponible');
                document.body.classList.add('cs-fullscreen-mode');
                return;
            }
            try {
                var p = req.call(el);
                if (p && p.then) {
                    p.then(function () {
                        document.body.classList.add('cs-fullscreen-mode');
                    }).catch(function (err) {
                        console.warn('[CoolStats] Fullscreen refusé :', err && err.message ? err.message : err);
                        // Fallback : fake fullscreen via classe CSS
                        document.body.classList.add('cs-fullscreen-mode');
                    });
                } else {
                    document.body.classList.add('cs-fullscreen-mode');
                }
            } catch (e) {
                console.warn('[CoolStats] Fullscreen erreur :', e);
                document.body.classList.add('cs-fullscreen-mode');
            }
        } else {
            var ex = doc.exitFullscreen || doc.webkitExitFullscreen || doc.msExitFullscreen;
            if (ex) { try { ex.call(doc); } catch (e) {} }
            document.body.classList.remove('cs-fullscreen-mode');
        }
    }

    function updateFullscreenIcon() {
        var btn = document.getElementById('cs-fullscreen-btn');
        if (!btn) return;
        var isFs = !!(document.fullscreenElement || document.webkitFullscreenElement);
        var icon = btn.querySelector('i');
        if (icon) icon.className = isFs ? 'bi bi-fullscreen-exit' : 'bi bi-display';
        document.body.classList.toggle('cs-fullscreen-mode', isFs);
    }

    // ── Terminal theme : injection de barres ASCII dans la section top_products ──
    // Aspect "Bloomberg/hacker" — ratio qty / max via █░░░░░ sur 10 caractères.
    function initTerminalAsciiBars() {
        applyTerminalAscii();
        document.addEventListener('cs:section-refreshed', function (e) {
            if (e.detail && e.detail.id === 'top_products') applyTerminalAscii();
        });
    }
    function applyTerminalAscii() {
        if (document.documentElement.getAttribute('data-cs-theme') !== 'terminal') return;
        var section = document.querySelector('[data-cs-section="top_products"]');
        if (!section) return;
        var rows = section.querySelectorAll('tbody tr');
        if (!rows.length) return;
        function valueCell(tr) {
            return tr.querySelector('.cs-top-term-u') || tr.querySelector('td:nth-last-child(2)');
        }
        function barCell(tr) {
            return tr.querySelector('.cs-top-term-bar') || tr.querySelector('td:last-child');
        }
        var values = [];
        rows.forEach(function (tr) {
            var cell = valueCell(tr);
            if (cell) values.push(parseInt(cell.textContent.replace(/[^\d]/g, ''), 10) || 0);
        });
        var max = Math.max.apply(null, values) || 1;
        rows.forEach(function (tr, i) {
            var target = barCell(tr);
            if (!target || target.querySelector('.cs-ascii-bar')) return;
            var v = values[i] || 0;
            var filled = Math.max(0, Math.min(10, Math.round((v / max) * 10)));
            var wrap = document.createElement('span');
            wrap.className = 'cs-ascii-bar';
            if (filled > 0) {
                var on = document.createElement('span');
                on.className = 'cs-ascii-on';
                on.textContent = '█'.repeat(filled);
                wrap.appendChild(on);
            }
            if (filled < 10) {
                var off = document.createElement('span');
                off.className = 'cs-ascii-off';
                off.textContent = '█'.repeat(10 - filled);
                wrap.appendChild(off);
            }
            target.appendChild(wrap);
        });
    }

    // ── Export CSV Top produits (event delegation pour survivre aux refresh AJAX) ──
    function initCsvExport() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest && e.target.closest('#cs-export-top-products');
            if (!btn) return;
            e.preventDefault();
            var url = new URL(window.location.href);
            url.searchParams.set('ajax', '1');
            url.searchParams.set('action', 'exportTopProducts');
            // Préserve les filtres actifs (date_from/to, country, sort, top_limit) déjà dans l'URL
            window.location.href = url.toString();
        });
    }

    // ── Export CSV générique par section (lit le tableau rendu, sans dépendance) ──
    // Tout bouton [data-cs-csv] exporte le <table.cs-table> de sa section en CSV
    // (séparateur ; + BOM UTF-8 → ouvrable directement dans Excel). Les colonnes
    // dont l'en-tête est vide (image, actions) sont ignorées.
    function initSectionCsvExport() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest && e.target.closest('[data-cs-csv]');
            if (!btn) return;
            e.preventDefault();
            var section = btn.closest('[data-cs-section]');
            if (!section) return;
            var table = section.querySelector('table.cs-table') || section.querySelector('table');
            if (!table) return;
            var id = section.getAttribute('data-cs-section') || 'export';
            var fn = 'coolstats_' + id + '_' + (window.csDateFrom || '') + '_' + (window.csDateTo || '') + '.csv';
            exportTableToCsv(table, fn);
        });
    }

    function csCsvCell(cell) {
        var t = (cell.textContent || "").replace(/\s+/g, " ").trim();
        return t.replace(/\s*€$/, "").trim();
    }

    function exportTableToCsv(table, filename) {
        var rows = [];
        var keep = [];
        var headRows = table.querySelectorAll('thead tr');
        var headCells = headRows.length ? headRows[headRows.length - 1].querySelectorAll('th, td') : [];
        var header = [];
        headCells.forEach(function (c, i) {
            var t = csCsvCell(c);
            if (t !== '') { keep.push(i); header.push(t); }
        });
        if (header.length) { rows.push(header); }
        table.querySelectorAll('tbody tr').forEach(function (tr) {
            var cells = tr.querySelectorAll('td, th');
            var line = (keep.length ? keep : cells.length ? Array.from(cells.keys()) : []).map(function (idx) {
                return cells[idx] ? csCsvCell(cells[idx]) : '';
            });
            if (line.some(function (v) { return v !== ''; })) { rows.push(line); }
        });
        if (!rows.length) { return; }
        var csv = rows.map(function (r) {
            return r.map(function (v) {
                v = (v == null) ? '' : String(v);
                if (/[";\n]/.test(v)) { v = '"' + v.replace(/"/g, '""') + '"'; }
                return v;
            }).join(';');
        }).join('\r\n');
        var blob = new Blob(['﻿' + csv], { type: 'text/csv;charset=utf-8;' });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        setTimeout(function () { document.body.removeChild(a); URL.revokeObjectURL(a.href); }, 100);
    }

    // ── Export PDF (impression navigateur) ──
    function initPdfExport() {
        document.addEventListener('click', function (e) {
            var btn = e.target.closest && e.target.closest('#cs-pdf-btn');
            if (!btn) return;
            e.preventDefault();
            triggerPdfExport();
        });
        // Restaurer après l'impression
        window.addEventListener('afterprint', function () {
            document.body.classList.remove('cs-pdf-printing');
            var hidden = document.querySelectorAll('.cs-pdf-hidden');
            hidden.forEach(function (el) { el.classList.remove('cs-pdf-hidden'); });
        });
    }

    function triggerPdfExport() {
        var includeList = window.CS_PDF_SECTIONS;
        if (!Array.isArray(includeList)) includeList = null;
        // Marque les sections à exclure (si une whitelist est définie)
        if (includeList) {
            var sections = document.querySelectorAll('[data-cs-section]');
            sections.forEach(function (s) {
                var id = s.getAttribute('data-cs-section');
                if (includeList.indexOf(id) === -1) {
                    s.classList.add('cs-pdf-hidden');
                }
            });
        }
        document.body.classList.add('cs-pdf-printing');
        // Laisse le DOM se mettre à jour avant d'appeler print
        setTimeout(function () { window.print(); }, 100);
    }

    // ── Auto-refresh ──
    var csAutoRefreshTimer = null;

    function initAutoRefresh() {
        var minutes = parseInt(window.CS_AUTO_REFRESH_MIN || 0, 10);
        if (csAutoRefreshTimer) {
            clearInterval(csAutoRefreshTimer);
            csAutoRefreshTimer = null;
        }
        if (minutes <= 0) return;
        if (window.CS_DEBUG) {
            console.log('[CoolStats] Auto-refresh activé : toutes les ' + minutes + ' minute(s)');
        }
        csAutoRefreshTimer = setInterval(function () {
            // Ne pas refresh si on est en mode édition (éviter de perdre l'état).
            if (document.body.classList.contains('cs-edit-mode')) return;
            if (typeof refreshAllSections === 'function') refreshAllSections();
        }, minutes * 60 * 1000);
    }

    // ══════════════════════════════════════════════════════════════════
    // Robustesse session AJAX — détecte une redirection vers AdminLogin
    // (session expirée) au lieu d'injecter la page de login dans le DOM.
    // ══════════════════════════════════════════════════════════════════
    var csAuthRedirecting = false;

    function csIsAuthRedirect(r) {
        return !!(r && (r.redirected || /[?&]controller=AdminLogin/i.test(r.url || '')));
    }

    function csRedirectToLogin(loginUrl) {
        if (csAuthRedirecting) return;
        csAuthRedirecting = true;
        csToast('Session expirée — redirection vers la page de connexion…', 'warning');
        setTimeout(function () {
            if (loginUrl && /[?&]controller=AdminLogin/i.test(loginUrl)) {
                window.location.href = loginUrl;
            } else {
                window.location.reload();
            }
        }, 1400);
    }

    // Parseur JSON pour fetch : intercepte page de login (redirection OU HTML).
    function csParseJson(r) {
        if (csIsAuthRedirect(r)) {
            csRedirectToLogin(r.url);
            return new Promise(function () {}); // stoppe la chaîne
        }
        return r.text().then(function (t) {
            var s = (t || '').replace(/^\s+/, '');
            if (s.charAt(0) === '<') { // HTML reçu au lieu de JSON = page login
                csRedirectToLogin(r.url);
                return new Promise(function () {});
            }
            return JSON.parse(s);
        });
    }

    // Toast léger (utilise showToast s'il existe, sinon fallback autonome).
    function csToast(msg, type) {
        if (typeof window.showToast === 'function') { window.showToast(msg, type); return; }
        var el = document.createElement('div');
        el.className = 'cs-toast cs-toast-' + (type || 'info');
        el.textContent = msg;
        document.body.appendChild(el);
        setTimeout(function () { el.classList.add('cs-toast-show'); }, 10);
        setTimeout(function () {
            el.classList.remove('cs-toast-show');
            setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 300);
        }, 4000);
    }

    function escapeAttr(s) {
        return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // ══════════════════════════════════════════════════════════════════
    // Recherche produit (autocomplete) + filtre global du dashboard.
    // Le filtre ne se déclenche QUE sur sélection d'une suggestion ou Entrée
    // (pas à chaque frappe) — la frappe ne fait qu'alimenter les suggestions.
    // ══════════════════════════════════════════════════════════════════
    var csSuggestActiveIdx = -1;
    var csSuggestDebounce = null;

    function initProductSearch() {
        var input = document.getElementById('cs-product-search-input');
        if (!input) return;
        var clearBtn = document.getElementById('cs-product-search-clear');

        input.addEventListener('input', function () {
            var q = input.value.trim();
            if (clearBtn) clearBtn.classList.toggle('d-none', q.length === 0);
            if (csSuggestDebounce) clearTimeout(csSuggestDebounce);
            if (q.length < 2) { csHideProductSuggest(); return; }
            csSuggestDebounce = setTimeout(function () { csFetchProductSuggest(q); }, 250);
        });

        input.addEventListener('keydown', function (e) {
            var box = document.getElementById('cs-product-suggest');
            var open = box && box.style.display !== 'none';
            if (e.key === 'ArrowDown') { if (open) { e.preventDefault(); csMoveProductSuggest(1); } }
            else if (e.key === 'ArrowUp') { if (open) { e.preventDefault(); csMoveProductSuggest(-1); } }
            else if (e.key === 'Enter') {
                e.preventDefault();
                var active = box ? box.querySelector('.cs-suggest-item.cs-active') : null;
                if (active) { csApplyProductSearch(active.getAttribute('data-term')); }
                else { csApplyProductSearch(input.value.trim()); }
            } else if (e.key === 'Escape') {
                csHideProductSuggest();
            }
        });

        if (clearBtn) {
            clearBtn.addEventListener('click', function () {
                input.value = '';
                clearBtn.classList.add('d-none');
                csHideProductSuggest();
                csApplyProductSearch('');
            });
        }

        // Fermeture au clic extérieur.
        document.addEventListener('click', function (e) {
            if (!e.target.closest('#cs-product-search')) csHideProductSuggest();
        });
    }

    function csFetchProductSuggest(q) {
        var box = document.getElementById('cs-product-suggest');
        if (!box) return;
        box.style.display = 'block';
        box.innerHTML = '<div class="cs-suggest-msg"><span class="spinner-border spinner-border-sm me-2"></span>Recherche…</div>';
        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'searchProducts');
        url.searchParams.set('q', q);
        fetch(url.toString())
            .then(csParseJson)
            .then(function (data) { csRenderProductSuggest((data && data.products) || []); })
            .catch(function () {
                box.innerHTML = '<div class="cs-suggest-msg text-danger"><i class="bi bi-exclamation-triangle me-1"></i>Erreur de recherche</div>';
            });
    }

    function csRenderProductSuggest(products) {
        var box = document.getElementById('cs-product-suggest');
        if (!box) return;
        csSuggestActiveIdx = -1;
        if (!products.length) {
            box.innerHTML = '<div class="cs-suggest-msg">Aucun produit trouvé</div>';
            return;
        }
        var html = '';
        products.forEach(function (p) {
            var img = p.image
                ? '<img src="' + p.image + '" alt="" class="cs-suggest-img">'
                : '<span class="cs-suggest-img cs-suggest-img-empty"><i class="bi bi-image"></i></span>';
            var ids = [];
            if (p.reference) ids.push('Réf ' + escapeHtml(p.reference));
            if (p.ean13) ids.push('EAN ' + escapeHtml(p.ean13));
            html += '<button type="button" class="cs-suggest-item" data-term="' + escapeAttr(p.term) + '">'
                + img
                + '<span class="cs-suggest-text">'
                + '<span class="cs-suggest-name">' + escapeHtml(p.name) + '</span>'
                + (ids.length ? '<span class="cs-suggest-ids">' + ids.join(' · ') + '</span>' : '')
                + '</span></button>';
        });
        box.innerHTML = html;
        box.querySelectorAll('.cs-suggest-item').forEach(function (it) {
            it.addEventListener('click', function () { csApplyProductSearch(it.getAttribute('data-term')); });
            it.addEventListener('mouseenter', function () {
                box.querySelectorAll('.cs-suggest-item.cs-active').forEach(function (a) { a.classList.remove('cs-active'); });
                it.classList.add('cs-active');
            });
        });
        box.style.display = 'block';
    }

    function csMoveProductSuggest(dir) {
        var box = document.getElementById('cs-product-suggest');
        if (!box) return;
        var items = box.querySelectorAll('.cs-suggest-item');
        if (!items.length) return;
        csSuggestActiveIdx += dir;
        if (csSuggestActiveIdx < 0) csSuggestActiveIdx = items.length - 1;
        if (csSuggestActiveIdx >= items.length) csSuggestActiveIdx = 0;
        items.forEach(function (it, i) { it.classList.toggle('cs-active', i === csSuggestActiveIdx); });
        var active = items[csSuggestActiveIdx];
        if (active && active.scrollIntoView) active.scrollIntoView({ block: 'nearest' });
    }

    function csHideProductSuggest() {
        var box = document.getElementById('cs-product-suggest');
        if (box) { box.style.display = 'none'; box.innerHTML = ''; }
        csSuggestActiveIdx = -1;
    }

    function csApplyProductSearch(term) {
        term = (term || '').trim();
        csHideProductSuggest();
        var input = document.getElementById('cs-product-search-input');
        var clearBtn = document.getElementById('cs-product-search-clear');
        if (input) input.value = term;
        if (clearBtn) clearBtn.classList.toggle('d-none', term.length === 0);
        applyFilter('product', term); // pose ?product= + refreshAllSections
    }

    // ══════════════════════════════════════════════════════════════════
    // Sélecteur de thème visuel (header) — persiste en config puis recharge.
    // ══════════════════════════════════════════════════════════════════
    function initThemePicker() {
        document.addEventListener('click', function (e) {
            var opt = e.target.closest('.cs-theme-option');
            if (!opt) return;
            var theme = opt.getAttribute('data-theme');
            if (!theme || opt.classList.contains('active')) return;
            opt.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>' + opt.textContent.trim();
            var url = new URL(window.location.href);
            url.searchParams.set('ajax', '1');
            url.searchParams.set('action', 'setVisualTheme');
            url.searchParams.set('theme', theme);
            fetch(url.toString())
                .then(csParseJson)
                .then(function (d) {
                    if (d && d.ok) { window.location.reload(); }
                })
                .catch(function () {});
        });
    }

    // ══════════════════════════════════════════════════════════════════
    // Onglets Top produits / Top catégories (dans la section top_products).
    // ══════════════════════════════════════════════════════════════════
    var csTopActiveTab = 'products';

    function initTopTabs() {
        document.addEventListener('click', function (e) {
            var tab = e.target.closest('.cs-top-tab');
            if (!tab) return;
            var which = tab.getAttribute('data-cs-top-tab') || 'products';
            csTopActiveTab = which;
            applyTopTab(which, false);
        });
    }

    function applyTopTab(which, isRefresh) {
        var section = document.querySelector('[data-cs-section="top_products"]');
        if (!section) return;
        var prodView = section.querySelector('.cs-top-products-view');
        var catView  = section.querySelector('#cs-top-categories');
        var limitWrap = section.querySelector('#cs-top-limit-wrap');
        section.querySelectorAll('.cs-top-tab').forEach(function (t) {
            t.classList.toggle('cs-active', t.getAttribute('data-cs-top-tab') === which);
        });
        if (prodView) prodView.classList.toggle('d-none', which !== 'products');
        if (catView)  catView.classList.toggle('d-none', which !== 'categories');
        if (limitWrap) limitWrap.classList.toggle('cs-hidden', which !== 'products'); // limite = produits only
        if (which === 'categories') loadTopCategories();
    }

    function loadTopCategories() {
        var container = document.getElementById('cs-top-categories');
        if (!container) return;
        container.innerHTML = '<div class="p-3 text-center text-muted small"><div class="spinner-border spinner-border-sm"></div></div>';
        var url = new URL(window.location.href);
        url.searchParams.set('ajax', '1');
        url.searchParams.set('action', 'getTopCategories');
        // sort, date_from/to, country, channels, product déjà présents dans l'URL.
        fetch(url.toString())
            .then(csParseJson)
            .then(function (data) { renderTopCategories(container, data); })
            .catch(function () {
                container.innerHTML = '<div class="p-3 text-center text-danger small">Erreur de chargement des catégories</div>';
            });
    }

    function renderTopCategories(container, data) {
        if (!container) return;
        var cats = (data && data.categories) || [];
        var totals = (data && data.totals) || {};
        var isRev = (data && data.sort_mode) === 'revenue';
        if (!cats.length) {
            container.innerHTML = '<div class="p-3 text-center text-muted small"><i class="bi bi-tags fs-3 d-block mb-2"></i>Aucune donnée sur cette période</div>';
            return;
        }
        var pct = isRev ? (totals.pct_revenue || 0) : (totals.pct_qty || 0);
        var html = '<div class="table-responsive"><table class="table table-sm cs-table mb-0" style="min-width:600px">';
        html += '<thead>';
        html += '<tr class="cs-top-totals-row"><td colspan="3" class="small"><strong>Total Top 10 catégories</strong>'
            + '<span class="text-muted ms-2">représente <strong style="color:var(--cs-accent)">' + pct + '%</strong> du ' + (isRev ? 'CA' : 'volume') + ' de la période</span></td>'
            + '<td class="text-end fw-bold">' + (totals.top_qty || 0) + '</td>'
            + '<td class="text-end fw-bold">' + Number(totals.top_revenue || 0).toLocaleString('fr-FR', { maximumFractionDigits: 0 }) + '&nbsp;€</td></tr>';
        html += '<tr><th style="width:30px">#</th><th>Catégorie</th><th class="text-end text-nowrap">Produits</th><th class="text-end text-nowrap">Unités</th><th class="text-end text-nowrap">CA</th></tr>';
        html += '</thead><tbody>';
        cats.forEach(function (c, i) {
            html += '<tr>'
                + '<td><span class="cs-rank-number">' + (i + 1) + '</span></td>'
                + '<td class="small">' + escapeHtml(c.name) + '</td>'
                + '<td class="text-end small text-muted">' + c.product_count + '</td>'
                + '<td class="text-end fw-bold small">' + c.total_qty + '</td>'
                + '<td class="text-end fw-bold small">' + Number(c.total_revenue || 0).toLocaleString('fr-FR', { maximumFractionDigits: 0 }) + '&nbsp;€</td>'
                + '</tr>';
        });
        html += '</tbody></table></div>';
        container.innerHTML = html;
    }

    // Exposé pour les sections qui voudraient déclencher leur propre refresh.
    window.CoolStats = window.CoolStats || {};
    window.CoolStats.refreshSection = refreshSection;
    window.CoolStats.refreshAll = refreshAllSections;
    window.CoolStats.applyCountryFilter = applyCountryFilter;
    window.CoolStats.enterEditMode = enterEditMode;
    window.CoolStats.exitEditMode = exitEditMode;
})();
