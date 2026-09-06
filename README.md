# Riverpod E-commerce

Application e-commerce Flutter construite pour valider la maîtrise du
state management avec **Riverpod**. Catalogue de produits, panier
d'achat, favoris persistés localement, filtrage/tri et un profil
utilisateur (mocké), le tout piloté par une architecture en couches
séparant clairement logique métier et widgets.

## Fonctionnalités

- **Catalogue de produits** : liste (grille) + écran de détail, données
  chargées de façon asynchrone (simulation d'appel API avec délai +
  lecture d'un JSON local).
- **Panier d'achat** : ajout, suppression, modification de quantité,
  calcul du total, animation de confirmation à l'ajout.
- **Favoris persistés** : ajout/retrait depuis la grille ou le détail
  produit, sauvegardés sur l'appareil via `shared_preferences` (survit
  au redémarrage de l'app).
- **Filtrage et tri** : recherche par nom, filtre par catégorie
  (chips), tri (prix croissant/décroissant, nom, meilleures notes).
- **Profil utilisateur (mock)** : chargement asynchrone d'un profil
  fictif (nom, email, adresse, statistiques de commandes).
- **Gestion des états de chargement/erreur** : chaque écran asynchrone
  affiche un indicateur de chargement, un message d'erreur avec bouton
  "Réessayer", ou les données, via `AsyncValue`.
- **Bonus** : animation (rebond + changement d'icône) sur le bouton
  "Ajouter au panier".

## Architecture

Le code applicatif vit dans `lib/src/` et suit une architecture en
couches : les widgets ne contiennent aucune logique métier, ils lisent
et déclenchent des actions sur des providers Riverpod, qui eux-mêmes
délèguent l'accès aux données à une couche `data/`.

```
lib/
├── main.dart                     # Bootstrap : init SharedPreferences, ProviderScope
└── src/
    ├── app.dart                  # MaterialApp (thème clair/sombre)
    ├── models/                   # Entités immuables (Product, CartItem, ...)
    │   ├── product.dart
    │   ├── cart_item.dart
    │   ├── user_profile.dart
    │   └── product_filter.dart   # Etat de recherche/filtre/tri + enum SortOption
    ├── data/                     # Accès aux données, aucune dépendance à Riverpod
    │   ├── product_repository.dart   # Lit assets/data/products.json (fake API + délai)
    │   ├── favorites_storage.dart    # Persistance des favoris (SharedPreferences)
    │   └── user_repository.dart      # Profil utilisateur mocké
    ├── providers/                # Toute la logique métier / state management
    │   ├── repository_providers.dart
    │   ├── product_providers.dart
    │   ├── cart_provider.dart
    │   ├── favorites_provider.dart
    │   └── user_provider.dart
    ├── screens/                  # Un écran = un ConsumerWidget qui compose les widgets
    │   ├── home_shell.dart       # Navigation (bottom bar) entre les 4 onglets
    │   ├── catalog_screen.dart
    │   ├── product_detail_screen.dart
    │   ├── favorites_screen.dart
    │   ├── cart_screen.dart
    │   └── profile_screen.dart
    └── widgets/                  # Widgets réutilisables, sans accès direct aux repositories
        ├── async_value_view.dart # Rendu uniforme loading/error/data pour un AsyncValue
        ├── product_card.dart
        ├── product_image.dart
        ├── filter_bar.dart
        ├── cart_item_tile.dart
        └── add_to_cart_button.dart
```

Les données produits sont mockées dans `assets/data/products.json` et
lues par `ProductRepository`, qui simule un vrai appel réseau
(`Future.delayed`) avant de parser le JSON — l'UI doit donc réellement
gérer les états `loading` / `error` / `data` via `AsyncValue`, comme
elle le ferait avec une vraie API.

## Providers Riverpod

L'application utilise exclusivement Riverpod (`flutter_riverpod`) comme
solution de state management, avec 9 providers répartis en 3 rôles :

| Provider | Type | Rôle |
|---|---|---|
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | Instance de `SharedPreferences`, surchargée dans `main()` une fois résolue de façon asynchrone. |
| `productRepositoryProvider` / `userRepositoryProvider` / `favoritesStorageProvider` | `Provider` | Injectent les dépendances de la couche `data/` (repositories, stockage). |
| `productListProvider` | `FutureProvider<List<Product>>` | Charge le catalogue produit de façon asynchrone (`AsyncValue`). |
| `productFilterProvider` | `StateNotifierProvider<ProductFilterNotifier, ProductFilter>` | Etat de la recherche, du filtre catégorie et du tri courant. |
| `categoriesProvider` | `Provider<List<String>>` | Liste dérivée des catégories disponibles (calculée depuis `productListProvider`). |
| `filteredProductsProvider` | `Provider<AsyncValue<List<Product>>>` | Combine catalogue + filtre + tri ; c'est ce provider que l'écran catalogue observe. |
| `cartProvider` | `StateNotifierProvider<CartNotifier, List<CartItem>>` | Contenu du panier et toutes ses mutations (ajout, suppression, quantité). |
| `cartItemCountProvider` / `cartTotalProvider` | `Provider<int>` / `Provider<double>` | Valeurs dérivées du panier (badge, total à payer). |
| `favoritesProvider` | `StateNotifierProvider<FavoritesNotifier, Set<String>>` | Ensemble des ids favoris, persisté via `FavoritesStorage` à chaque modification. |
| `userProfileProvider` | `FutureProvider<UserProfile>` | Charge le profil utilisateur mocké de façon asynchrone. |

Points clés de l'implémentation :

- **Séparation stricte** : les `StateNotifier` ne connaissent que des
  modèles et, pour les favoris, une interface de stockage — jamais de
  widget. Les écrans ne font que `ref.watch` / `ref.read`.
- **Providers dérivés** (`filteredProductsProvider`,
  `cartTotalProvider`, `cartItemCountProvider`, `categoriesProvider`)
  pour garder le calcul du "quoi afficher" hors des widgets.
- **`AsyncValue` partout où c'est asynchrone**, avec un widget générique
  `AsyncValueView` qui uniformise l'affichage loading/erreur/données et
  propose un bouton "Réessayer" (`ref.invalidate`).
- **Persistance des favoris** : `FavoritesNotifier` initialise son état
  depuis `SharedPreferences` à la création, puis sauvegarde à chaque
  `toggle`.

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```

La suite de tests couvre :
- la logique métier du panier (`CartNotifier`) ;
- la persistance des favoris (`FavoritesNotifier` + `SharedPreferences`) ;
- le filtrage/tri dérivé (`filteredProductsProvider`) ;
- un test d'intégration widget (chargement du catalogue, navigation
  vers le détail, ajout au panier et mise à jour du badge).
