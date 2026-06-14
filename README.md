# CoolStats — Dashboard analytics moderne pour PrestaShop

> Tableau de bord analytics nouvelle génération pour PrestaShop.
> Vente directe **et** marketplaces, en un coup d'œil.

*Modern analytics dashboard for PrestaShop. Free & open source (GPL v3).*

![PrestaShop 1.7 → 9](https://img.shields.io/badge/PrestaShop-1.7%20%E2%86%92%209-blue)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue)

![CoolStats — dashboard](https://zm40.com/assets/img/coolstats/dashboard-aurora.webp)

## Fonctionnalités

- **Sections drag & drop** : KPI, objectifs, top produits & catégories, carte Europe, graphiques, marges, retours… réorganisables.
- **Recherche produit** (nom / réf / EAN) qui filtre l'ensemble du dashboard.
- **Connecteurs** : Google Analytics 4, Matomo, + tracking natif PrestaShop.
- **Thèmes** (Aurora, Cozy, Editorial, Brutalist, Terminal) + mode clair/sombre, changeables depuis le dashboard.
- **Vente directe & marketplaces** réunies dans une seule vue.

## Compatibilité

PrestaShop **1.7, 8, 9** · PHP **7.2+**. Aucune dépendance Composer requise.

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
