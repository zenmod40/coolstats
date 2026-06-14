# Changelog CoolStats

Toutes les évolutions notables du module sont listées ici.
Format inspiré de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), versions [SemVer](https://semver.org/lang/fr/).

## [1.0.2] — 2026-06-14

Première publication open source.

### Open source (GPL v3)
- Module **libre et open source** sous licence **GPL v3** : code source ouvert, auditable, modifiable et redistribuable sans restriction. Aucune clé, aucune limite.

### ZM40 Common (attribution + écosystème)
- **Footer d'attribution** discret (dashboard) + **bloc « libre & open source »** en page de configuration (panel natif, prestations sur devis, liens GitHub / contact / autres modules).
- **Vérification de mise à jour** discrète et *notify-only* via l'API publique GitHub Releases (max 1×/jour, cache, fail-silent).
- **Onglet « Modules ZM40 »** (écosystème) en page de config : cartes des autres modules depuis le feed `zm40.com` (badges « Gratuit · Open source » / « Déjà installé »), masqué si feed indisponible.
- **Interrupteur opt-out global `ZM40_NET_ENABLED`** (activé par défaut) : désactive tout appel réseau. Requêtes **anonymes**, aucune donnée boutique transmise (RGPD-friendly).

### Sélecteur de thème
- Choix du thème visuel directement depuis le header du dashboard (5 thèmes), en complément du bouton clair/sombre.

### Export
- **Export CSV** ajouté sur les tableaux : commandes récentes, marges, paniers abandonnés et paiements (en plus du Top produits déjà existant). Fichier `.csv` (séparateur `;` + BOM UTF-8) ouvrable directement dans Excel.

### Recherche produit (filtre global)
- **Barre de recherche produit** dans le header avec **autocomplete** : nom, référence ou EAN, suggestions avec image, navigation clavier (↑/↓, Entrée, Échap), survol souris, fermeture au clic extérieur, messages d'erreur légers
- Le filtre se déclenche uniquement à la **sélection d'une suggestion ou sur Entrée** (pas à chaque frappe)
- Une fois actif, **tous les blocs orientés commandes** sont scopés aux commandes contenant le produit (KPI, graphiques, marges, paiements, pays, performance, commandes, activité, highlights, clients, objectifs, marketplaces, paiement natif)
- Les **tableaux Top** (produits + catégories) n'affichent que le produit recherché (match direct sur la ligne, pas les co-achats) ; le total période reste la référence (→ le % devient la part du produit)
- Image produit : fallback **cover → 1ʳᵉ image**
- *Non concernés (par nature) : inscriptions clients (basé sur la date de création de compte), paniers abandonnés, trafic*

### Top catégories
- Nouvel **onglet « Catégories »** dans le bloc Top produits (bascule produits ↔ catégories, sélecteur CA/Volume partagé) — Top 10 catégories par catégorie par défaut, avec part du total période

### Retours regroupés par commande
- La popup **« Produits les plus retournés »** est désormais **regroupée par commande** (n° + lien BO, articles d'une même commande affichés ensemble, totaux par commande)
- **Toggle Remboursées / Annulées** (défaut Remboursées)
- Basé sur la **date de transition d'état** (`order_history`), pas la date de création de la commande

### Robustesse
- Détection de **session expirée** sur les appels AJAX → message clair + redirection automatique vers la connexion (au lieu d'injecter la page de login dans le tableau de bord)

### Correctifs
- **Taux de retour** : ne compte désormais que les commandes **remboursées** (état 7) — les **annulations** (état 6) ne sont plus comptabilisées comme retour (cohérence KPI ↔ popup retours).
- **Marges** : état vide reformulé en neutre (le calcul s'active dès que le prix d'achat est renseigné, via PrestaShop ou un outil de gestion) — plus de bouton incitant à saisir les prix d'achat.
- Lisibilité des **suggestions de recherche** sur le thème Aurora (fond opaque au lieu de transparent).

## [1.0.1] — 2026-05-11

### Trafic & visiteurs
- Le tracking natif PrestaShop (statsdata) n'est plus utilisé par défaut (champ `mobile_theme` déprécié, OS lookup obsolète, pas de filtrage bots, pages vues peu fiables) — opt-in explicite désormais
- **Connecteur Matomo** : URL + Token + Site ID par boutique, test de connexion live, support multi-shop natif via `Configuration::get/updateValue` scope-aware
- **Connecteur Google Analytics 4** : auth via Service Account (JWT RS256 signé en PHP natif, pas de dépendance), guide de setup intégré, test de connexion, support multi-shop
- Empty state propre quand aucun provider configuré (cards Matomo / GA4 / Plausible avec badges "Bientôt")
- Bannières contextuelles multi-shop pour configurer Matomo/GA4 par boutique

### Thèmes visuels
- 5 nouveaux thèmes en plus du défaut : **Cozy** (papier pêche), **Aurora** (glass cards + blobs), **Editorial** (papier crème + sérif), **Brutalist** (blocs francs + hard shadow), **Terminal** (phosphor mono)
- Chaque thème supporte les modes light + dark (10 combinaisons)
- Sélecteur dans BO → Apparence
- La palette KPI configurée par l'admin reste prioritaire sur les couleurs par défaut du thème

### Export CSV
- Bouton d'export CSV sur la section **Top produits**
- Respecte les filtres actifs (dates, pays, sort, limit) + configs BO (séparateur, encoding)

### Drill-down KPI
- Étendu aux KPIs panier moyen → tri par montant, articles/panier → tri par nb d'articles, nouveaux clients → 1res commandes
- Overlay accent au survol avec libellé d'action explicite
- Scroll conditionnel : ne se déclenche que si la section commandes est hors viewport, sinon flash visuel

### Multi-shop
- Toutes les configs (palettes, accent, Matomo, GA4, etc.) scopées par boutique via `Configuration::get/updateValue` natif PS
- Bannières d'info/warning dans le BO pour clarifier le contexte boutique courant

### Diagnostic & perf
- Mode debug : badges ⏱ par section (vert/orange/rouge) + tableau récap en bas du dashboard
- Bouton "Créer/vérifier l'index ps_connections" dans BO → Avancé (déplacé hors flow d'install pour éviter les timeouts sur gros volumes)

### Fixes
- Bouton fullscreen : event delegation + Promise gérée + fallback CSS si l'API rejette
- Section pages vues : Aucune donnée affichée proprement quand statsdata n'alimente pas la table
- Install : `ALTER TABLE ps_connections` sorti du flow → install instantané même sur gros sites

---

## [1.0.0] — 2026-05

Première version publique. Module universel adaptatif vente directe / hybride MKP pour PrestaShop 1.7 / 8 / 9+.

### Architecture
- Détection adaptative MKP / vente directe (`CoolStatsContext`)
- Sections déclaratives (manifest `section.json` + `query.php` + `view.tpl`)
- Préférences utilisateur par admin (drag & drop SortableJS + on/off, table `ps_coolstats_section_prefs`)
- Dispatcher AJAX par section avec conservation focus/curseur
- 4 helpers SQL (date range, country join, états, comparaison calendar-aware)
- Interface `CoolStatsTrafficProvider` extensible (V2 : Matomo / GA4 / Plausible)

### Sections livrées
- **KPI** (5 indicateurs avec tendances N-1 vs prev/yoy/none)
- **Objectifs mensuels** (CA + commandes cibles + barres tricolores + projection fin de mois)
- **Customers** (6 stats : total, nouveaux, récurrents, cmd/client, LTV, remboursements)
- **Top products** (toggle Volume/CA)
- **Highlights** (star/watch/pairs)
- **Country map** (SVG monde + ranking + filtre clickable)
- **Charts** (line orders/CA, bar payments)
- **Performance** (modal carriers)
- **Recent orders** (filtrable statut, recherche, tri montant/articles, nouveaux clients)
- **Recent activity** (flux temps réel)
- **Traffic** (provider natif PS + IP exclusion)

### BO de configuration
- 5 onglets : Comportement / Apparence / États / Trafic / Avancé
- Design MG (header gradient + tabs custom + panels), référence CoolCheck
- Matrice de mapping des états (Valid/Cancelled/Shipped/Delivered) avec couleurs PS + count 12 mois
- Diagnostic trafic + wizard de configuration
- Whitelist sections pour l'export PDF

### Drill-down KPI → tableau commandes
- Commandes / CA → liste filtrée
- Panier moyen → tri par montant ↓
- Articles/panier → tri par nb d'articles ↓
- Nouveaux clients → 1res commandes uniquement
- Objectifs CA/commandes → commandes du mois en cours
- Overlay accent au survol avec libellé explicite + scroll conditionnel (uniquement si section hors viewport, sinon flash visuel)
- Chips de filtre actifs avec bouton clear

### Filtres globaux
- Date range (presets calendaires : semaine/mois/trimestre/année avec -1/-2 + custom)
- Pays (via clic sur map ou badge dropdown)
- Comparaison : période précédente / N-1 année / aucune (defaut configurable)
- Calcul N-1 calendar-aware (détecte boundaries année/trimestre/mois)

### Mode présentation
- Fullscreen API natif (cross-browser : standard + webkit + ms)
- Promise gérée avec fallback CSS si refus
- Event delegation pour résister aux re-renders AJAX

### Export PDF
- Bouton dédié dans le header dashboard
- Print natif (`window.print()`) + `@media print` :
  - Forçage thème clair quel que soit le mode actif
  - Header dédié (logo + nom marque + boutique + période + pays filtré + date d'édition)
  - Masquage contrôles (filters, customize, edit bar, drag handles, modals)
  - A4 paysage, page-break-inside avoid sur les sections
- Config BO : whitelist sections incluses dans l'export

### Branding & thème
- Logo configurable (path)
- Nom de marque
- **Palettes harmonieuses** : 6 presets (Indigo/Vert défaut, Ocean, Sunset, Forest, Mono Slate, Magenta) — chacune définit 5 couleurs (accent + 4 KPI catégoriels)
- Override de l'accent via color picker + reset à la couleur de la palette
- Toggle dark/light persisté (localStorage)
- Toutes les couleurs pilotées par CSS vars (`--cs-accent`, `--cs-accent-rgb`, `--cs-kpi-*`, `--cs-kpi-*-rgb`)
- Aucune couleur en dur dans les vues : tout est `var(--cs-...)` ou classes sémantiques

### Auto-refresh
- Intervalle configurable (BO)
- Suspendu en mode édition
- Respecte les filtres URL actifs

### Export CSV
- Séparateur configurable
- Encoding configurable (UTF-8 / Windows-1252)

### Sécurité & qualité
- IPs exclues (BO) pour ne pas polluer les stats de l'admin
- Mode debug optionnel
- Index `idx_coolstats_date_add` ajouté sur `ps_connections` pour perf trafic
- Validation PHP : `max(0,...)` sur valeurs numériques, whitelist sur IDs palette

### Menu PS
- Tab parent **CoolStats** (icône bar_chart) avec 2 enfants :
  - **Dashboard** (icône dashboard) — ouvre lite_display dans nouvel onglet
  - **Configuration** (icône settings)

---

## Notes V1.1 prévues

- Mode présentation : rotation automatique des vues (3 vues prédéfinies, durée configurable, bouton Diaporama distinct)
- Extension du drill-down pattern aux futurs KPI d'alertes (cmd >24h, ruptures, paniers abandonnés)
