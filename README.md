# CoolStats — Dashboard analytics moderne pour PrestaShop

> Tableau de bord analytics nouvelle génération pour PrestaShop.
> Vente directe **et** marketplaces, en un coup d'œil.

*Modern analytics dashboard for PrestaShop. Free & open source (GPL v3).*

![PrestaShop 1.7 → 9](https://img.shields.io/badge/PrestaShop-1.7%20%E2%86%92%209-blue)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue)

![CoolStats — dashboard Aurora](https://zm40.com/assets/img/coolstats/dashboard-aurora.webp)

## 5 thèmes prêts à l'emploi · clair & sombre

CoolStats embarque cinq thèmes complets, basculables depuis le dashboard. Chacun couvre l'intégralité de l'interface (KPI, cartes, tableaux, graphiques) — pas un simple swap de couleurs.

| Aurora | Cozy | Editorial |
|:--:|:--:|:--:|
| ![Aurora](https://zm40.com/assets/img/coolstats/dashboard-aurora.webp) | ![Cozy](https://zm40.com/assets/img/coolstats/dashboard-cozy.webp) | ![Editorial](https://zm40.com/assets/img/coolstats/dashboard-editorial.webp) |
| *Pop éditorial, hero coloré* | *Tile-based, chaleureux* | *Rapport magazine, typo serif* |

| Neo Brutalist | Terminal |
|:--:|:--:|
| ![Brutalist](https://zm40.com/assets/img/coolstats/dashboard-brutalist.webp) | ![Terminal](https://zm40.com/assets/img/coolstats/dashboard-terminal.webp) |
| *KPI pop, bordures épaisses* | *Console verte sur fond noir* |

## Sections du dashboard

Quelques exemples des sections drag & drop (toutes optionnelles, réorganisables, masquables) :

| Carte Europe | Paniers abandonnés |
|:--:|:--:|
| ![Carte Europe](https://zm40.com/assets/img/coolstats/section-carte-europe.webp) | ![Paniers abandonnés](https://zm40.com/assets/img/coolstats/section-paniers-abandonnes.webp) |

| Objectifs avec projection | Top catégories & produits |
|:--:|:--:|
| ![Objectifs](https://zm40.com/assets/img/coolstats/section-objectifs.webp) | ![Top catégories](https://zm40.com/assets/img/coolstats/section-top-categories.webp) |

![Top produits avec photos](https://zm40.com/assets/img/coolstats/section-top-produits.webp)

## Fonctionnalités

- **Sections drag & drop** : KPI, objectifs, top produits & catégories, carte Europe, graphiques, marges, retours, relation client… réorganisables.
- **Recherche produit** (nom / réf / EAN) qui filtre l'ensemble du dashboard.
- **Connecteurs** : Google Analytics 4, Matomo, + tracking natif PrestaShop.
- **Thèmes** (Aurora, Cozy, Editorial, Brutalist, Terminal) + mode clair/sombre, changeables depuis le dashboard.
- **Vente directe & marketplaces** réunies dans une seule vue.
- **Chiffre d'affaires en HT ou TTC** : un réglage bascule tout le dashboard entre les montants HT et TTC enregistrés par PrestaShop (sans recalcul de TVA), par boutique en multi-shop. Les marges restent calculées en HT.
- **Relation client** : KPI de la période — Commandes, Demandes SAV (service client natif PrestaShop, avec part des commandes) et Rétractations (si le module Rétractations est installé) — + courbe d'évolution des demandes SAV sur le même modèle que la courbe des commandes.
- **Comparaison de périodes** : période précédente ou N-1 superposée en pointillé sur la courbe des commandes, alignée index par index, bascule Commandes / CA, légende explicite.
- **Répartition par moyen de paiement** : type de graphique sélectionnable depuis l'en-tête du bloc (barres verticales, barres horizontales, donut) — choix mémorisé par utilisateur.

## Compatibilité

PrestaShop **1.7, 8, 9** · PHP **7.2+**. Aucune dépendance Composer requise.

> Une version legacy compatible ThirtyBees / PrestaShop 1.6 est disponible sur demande via [zm40.com](https://zm40.com).

## Installation

1. Télécharger la dernière release (`coolstats.zip`).
2. Back-office PrestaShop → **Modules** → **Téléverser un module**.
3. Installer, puis ouvrir **CoolStats** dans le menu.

## Configuration

- Connecter GA4 / Matomo depuis l'onglet **Trafic & visiteurs** (clés stockées côté serveur, jamais exposées au front).
- Choisir un thème, réorganiser les sections par glisser-déposer.
- Définir les états de commande valides/annulés/remboursés selon votre boutique (onglet **États de commande**).

## Confidentialité

CoolStats vérifie périodiquement (au maximum 1×/jour) si une nouvelle version est disponible via l'**API publique de GitHub**, et récupère la liste des autres modules ZM40 depuis **zm40.com**. Ces requêtes sont **anonymes** : **aucune donnée de votre boutique n'est transmise** (seule l'adresse IP de votre serveur est visible, comme pour toute requête HTTP). Vous pouvez **tout désactiver** dans la configuration du module (onglet **Avancé** → « Vérifier les mises à jour »).

## Support & services

CoolStats est **offert à la communauté, sans support garanti**. Les issues GitHub sont les bienvenues pour les **bugs** et les **idées**.

Besoin d'aide à l'installation, d'une adaptation sur mesure, d'un connecteur (ERP, marketplace, API), de débogage ou de maintenance ? → **[zm40.com](https://zm40.com)** (c'est Nicolas qui répond).

## Contribuer

Les PR sont bienvenues. Merci de garder le style du code et d'ouvrir une issue avant les gros changements.

## Licence

GNU **GPL v3** © 2026 Nicolas Michaud — ZM40 / Magic Garden · [zm40.com](https://zm40.com)

Voir [LICENSE](LICENSE) pour le texte complet.
