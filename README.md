<div align="center">

<img src="screenshots/splash.jpg" alt="Sooq" width="200" style="border-radius:30px"/>

# Sooq

**A modern grocery shopping app built with Flutter & Supabase**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)


</div>

---

## 📸 Screenshots

**Onboarding & Auth**

| Splash | Onboarding | Login |
|:---:|:---:|:---:|
| ![Splash](screenshots/splash.jpg) | ![Onboarding](screenshots/onboarding.jpg) | ![Login](screenshots/login.jpg) |

| Sign Up | Profile Image | Validation |
|:---:|:---:|:---:|
| ![Signup](screenshots/signup.jpg) | ![Signup Crop](screenshots/signup_crop_profile_image.jpg) | ![Signup Validation](screenshots/signup_validation.jpg) |

**Home & Search**

| Home | Search | Search Filter |
|:---:|:---:|:---:|
| ![Home](screenshots/home.jpg) | ![Search](screenshots/search.jpg) | ![Search Filter](screenshots/search_filter.jpg) |

| Search Result | | |
|:---:|:---:|:---:|
| ![Search Result](screenshots/search_result.jpg) | | |

**Cart**

| Cart | Empty State | Delete Item |
|:---:|:---:|:---:|
| ![Cart](screenshots/cart.jpg) | ![Cart Empty](screenshots/cart_empty_state.jpg) | ![Cart Delete](screenshots/cart_delete_item.jpg) |

| Checkout | | |
|:---:|:---:|:---:|
| ![Checkout](screenshots/cart_successful_checkout.jpg) | | |

**Favorites & Profile**

| Favorites | Filter | Delete Item |
|:---:|:---:|:---:|
| ![Favorites](screenshots/favorite.jpg) | ![Favorites Filter](screenshots/favorite_filter.jpg) | ![Favorites Delete](screenshots/favorite_delete_item.jpg) |

| Profile | | |
|:---:|:---:|:---:|
| ![Profile](screenshots/profile.jpg) | | |

---

## ✨ Features

- 🚀 **Onboarding** — Smooth intro screens shown only on first launch
- 🔐 **Authentication** — Login & signup with profile image, real-time password strength indicator
- 🏠 **Home** — Dynamic categories, banners and products fetched live from Supabase, with an offline-first cache for instant cold starts
- 📦 **Catalog** — 170+ products across 5 categories, backed by a real Postgres schema (`categories`, `products`, `banners`) with Storage-hosted images, seeded via a standalone Dart script
- 🔍 **Search** — Server-side search with debounce, `ilike` matching, category/price/rating filters, sort options, paginated results, and query highlighting
- 🛒 **Cart** — Add/remove items by product id, swipe-to-delete, animated order summary
- ❤️ **Favorites** — Persistent wishlist (stored locally by product id, not by name), animated heart button with haptic feedback, sort & swipe-to-remove
- 👤 **Profile** — Account menu with orders, addresses, notifications, language, and logout
- ♾️ **Pagination everywhere** — Home category previews, the "See all" category grid, and search results all page through Supabase with `range()` instead of loading entire tables

---

## 🏗️ Architecture

The project follows **Clean Architecture** with strict separation between layers across every feature.

```
lib/
├── main.dart
├── sooq_app.dart
├── root.dart                        # Bottom nav shell with IndexedStack
│
├── core/
│   ├── routing/
│   │   ├── app_router.dart          # GoRouter — all routes with fade transitions
│   │   └── routes.dart              # Route name constants
│   ├── services/
│   │   ├── supabase/
│   │   │   ├── supabase_client.dart
│   │   │   ├── supabase_constants.dart
│   │   │   └── errors/
│   │   │       ├── supabase_error.dart
│   │   │       └── supabase_error_handler.dart
│   │   └── hive/
│   │       ├── hive_services.dart   # Typed box access for offline caching
│   │       └── hive_types_ids.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   └── utils/
│       ├── di/
│       │   └── get_it.dart          # Dependency injection setup
│       ├── ld/
│       │   └── pref_helper.dart     # SharedPreferences unified wrapper
│       ├── custom_button.dart
│       ├── custom_text.dart
│       ├── app_network_image.dart   # Shared CachedNetworkImage wrapper
│       ├── snack_bar.dart
│       ├── validators.dart
│       ├── responsive.dart
│       └── iterable_extension.dart
│
└── features/
    ├── On_Boarding/
    ├── Auth/
    ├── Home/
    ├── Search/
    ├── Cart/
    ├── Favorite/
    └── Profile/
```

Every feature follows the same internal pattern:

```
feature/
├── data/
│   ├── models/
│   ├── local/                         # Hive-backed data sources, where relevant
│   └── repos/
│       ├── feature_repo.dart          # Abstract contract
│       └── feature_repo_impl.dart     # Supabase implementation
└── presentation/
    ├── cubit/
    │   ├── feature_cubit.dart
    │   └── feature_state.dart
    └── views/
        ├── feature_view.dart
        └── widgets/
```

---

## 🗄️ Backend (Supabase)

The catalog is fully database-backed — no product, category, or banner data is hardcoded in the app.

| Table | Purpose |
|-------|---------|
| `categories` | `id`, `name`, `slug`, `image_url` |
| `products` | `id`, `name`, `image_url`, `price`, `rating`, `votes`, `category_id` (FK → `categories`), `unit` |
| `banners` | `id`, `title`, `image_url`, `sort_order`, `is_active` |

- Product and category images live in **Supabase Storage**, organized as `products/{category-slug}/{product-name}.webp`, and are referenced in the database as full public URLs.
- All read access is governed by **Row Level Security** policies (public `select`, writes restricted to the service role).
- The initial catalog (172 products across 5 categories) was seeded with a standalone Dart script (`tool/seed_products.dart`) that lists the Storage bucket, derives a product name from each file name, and inserts a matching row with randomized price/rating/votes.

---

## 🧠 State Management

State is managed exclusively with **flutter_bloc (Cubit)** — no `setState` for business logic anywhere in the codebase.

| Cubit | Scope | How it's provided |
|-------|-------|-------------------|
| `AuthCubit` | Screen-scoped | `BlocProvider` in router |
| `PickImageCubit` | Screen-scoped | `BlocProvider` in router |
| `HomeCubit` | Root-scoped | `MultiBlocProvider` on Root route — fetches categories & banners |
| `CategoryCubit` | Root-scoped | `MultiBlocProvider` on Root route — tracks the selected category tab |
| `FetchCategoryProductsCubit` | Reusable, screen-scoped | A **single cubit class instantiated per category** (`BlocProvider(key: ValueKey(category.id), ...)`), both for the Home preview row and the full "See all" grid — zero duplicated logic between the two |
| `CartCubit` | Root-scoped | `MultiBlocProvider` on Root route |
| `FavoritesCubit` | Root-scoped | `MultiBlocProvider` on Root route |
| `SearchCubit` | Screen-scoped | `BlocProvider` in `SearchView` |

`CartCubit` and `FavoritesCubit` are provided at the `Root` route level — the favorites badge in the nav bar, the heart button on every product card, and the floating cart bar all share one live instance with zero synchronization needed.

`FetchCategoryProductsCubit` is the same class used in two different contexts (a 7-item horizontal preview on Home, a 20-item-per-page vertical grid on "See all"), parameterized by `categoryId` and `pageSize` — the pattern that made per-category pagination and caching possible without five near-identical cubits.

---

## ♾️ Pagination & Offline Caching

- **Pagination** is implemented with Supabase's `.range(start, end)`, driven by sealed `FetchCategoryProductsState` states (`Loading`, `Success`, `LoadingMore`, `LoadMoreFailure`, `Failure`) so the UI can distinguish "first load," "loading next page," and "failed to load more" without boolean-flag juggling.
- Scrolling within 300px of the end of a list triggers the next page automatically, both in the Home horizontal previews and the vertical "See all" grid.
- **The first page of every category is cached locally with Hive** (`hive_ce`, typed via generated `TypeAdapter`s). On cold start, the cached page renders instantly while a fresh request runs in the background and silently replaces it — a stale-while-revalidate pattern that keeps the Home screen from ever showing a blank loading state on a second launch.
- Search results use the same `range()`-based pagination with infinite scroll, and in-flight requests are invalidated by a monotonically increasing request id so a slow response to an earlier keystroke can never overwrite the results of a newer one.

---

## 🗺️ Navigation

Navigation uses **GoRouter** with a custom `FadeTransition` on every route.

| Route | Path | Description |
|-------|------|-------------|
| Onboarding | `/` | First launch intro |
| Login | `/Login` | Auth entry point |
| Signup | `/Signup` | Registration |
| Root | `/Root` | Main shell — bottom nav with 4 tabs |
| Cart | `/Cart` | Full cart screen |
| Category Products | `/CategoryProducts` | "See all" — full paginated grid for one category |

---

## 🔧 Tech Stack

| Concern | Solution |
|---------|----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Supabase (Auth + Postgres + Storage, Row Level Security) |
| State Management | flutter_bloc (Cubit) |
| Dependency Injection | get_it |
| Navigation | go_router |
| Error Handling | dartz (`Either<SupabaseError, T>`) |
| Local Persistence | shared_preferences (via `PrefHelper`) for favorites & recent searches; `hive_ce` for offline product caching |
| Image Picking & Cropping | image_picker + image_cropper |
| Image Caching | cached_network_image (via a shared `AppNetworkImage` wrapper) |
| Loading Skeletons | skeletonizer |
| Responsive Text | auto_size_text |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc:
  get_it:
  dartz:
  go_router:
  supabase_flutter:
  shared_preferences:
  hive_ce:
  hive_ce_flutter:
  image_picker:
  image_cropper:
  cached_network_image:
  carousel_slider:
  skeletonizer:
  gap:
  flutter_svg:
  auto_size_text:
  loading_animation_widget:

dev_dependencies:
  build_runner:
  hive_ce_generator:
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- A [Supabase](https://supabase.com) project

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/your-username/sooq.git
cd sooq
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Supabase**

Open `lib/core/services/supabase/supabase_constants.dart` and replace the values:

```dart
class SupabaseConstants {
  static const String url     = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

> ⚠️ Add `supabase_constants.dart` to `.gitignore` before your first push to avoid exposing your credentials.

**4. Set up the database**

Run the schema and RLS policies from `supabase/schema.sql` (tables: `categories`, `products`, `banners`) in the Supabase SQL editor, then create the matching Storage buckets (`products`, `Categories`, `Banners`) and upload your images.

**5. (Optional) Seed sample products**

If you want to populate `products` from images already in Storage:
```bash
cd tool
dart pub get
dart run --no-native-assets seed_products.dart
```

**6. Run the app**
```bash
flutter run
```

---

## 🎨 Design System

All colors and typography are centralized — no magic numbers or hardcoded values anywhere in the codebase.

**Typography** — `AppTextStyles` · Font: **Poppins**

| Token | Size | Weight | Use |
|-------|------|--------|-----|
| `displaySmall` | 22 | 700 | Hero headings |
| `titleLarge` | 18 | 700 | Screen titles |
| `titleMedium` | 16 | 600 | Section headers |
| `titleSmall` | 14 | 600 | Card titles |
| `bodyLarge` | 14 | 500 | Primary body text |
| `bodyMedium` | 13 | 400 | Secondary body text |
| `labelLarge` | 13 | 600 | Buttons, labels |
| `caption` | 11 | 400 | Metadata, hints |

**Colors** — `AppColors`

| Token | Hex | Use |
|-------|-----|-----|
| `primary` | `#08650B` | Brand green |
| `primaryLight` | `#B4F3B6` | Tinted surfaces |
| `surface` | `#F7F7F7` | Card backgrounds |
| `error` | `#EF4444` | Errors, destructive actions |
| `warning` | `#F9A825` | Warnings |

**Shadow tokens:** `shadowSm` · `shadowMd` · `shadowLg` · `shadowPrimary`

---

## 🔑 Key Design Decisions

**1. Fully database-backed catalog, not hardcoded data**
Categories, products, and banners all live in Postgres and Supabase Storage rather than as Dart constants or local assets — adding, renaming, or re-pricing a product never requires an app update.

**2. Identity by id, not by name**
Cart, favorites, and product lookups all compare `ProductModel.id` (with `==`/`hashCode` overridden on `id`), not product name — correct and collision-proof even with hundreds of products, some of which may share a display name.

**3. One reusable cubit per category, not one cubit class per category**
`FetchCategoryProductsCubit` takes `categoryId` and `pageSize` as constructor parameters and is instantiated fresh (`BlocProvider(key: ValueKey(category.id), ...)`) wherever a category's products are needed — the Home preview row and the full "See all" grid share the exact same class with zero duplicated pagination or caching logic.

**4. Cache-first, network-always for the first page**
The first page of each category is read from Hive and rendered immediately, then unconditionally re-fetched from Supabase in the background and used to replace it — the cache is a speed optimization for cold starts, never a substitute for a fresh network read.

**5. `PrefHelper` as a unified persistence layer**
All `SharedPreferences` access goes through a single static `PrefHelper` — recent searches and favorites both use it, with a lazy singleton pattern to avoid repeated `getInstance()` calls across the app. Favorites are serialized as JSON (full `ProductModel` snapshots), not just names, so saved items survive catalog changes.

**6. Either-based error handling**
All repository methods return `Either<SupabaseError, T>`. Supabase exceptions are caught and mapped to user-readable messages inside a dedicated error handler before they ever reach a cubit — the UI always receives a clean, typed result.

**7. Root-level cubit provision**
`CartCubit` and `FavoritesCubit` are provided at the `Root` route via `MultiBlocProvider`. Any screen rendered inside the bottom nav shell can access them without re-creation or prop-drilling.

**8. Fade transitions on all routes**
Every GoRouter `pageBuilder` uses `CustomTransitionPage` with a `FadeTransition` at 400ms — a consistent, polished feel across the entire navigation flow.

**9. Glassmorphic bottom navigation bar**
The nav bar in `root.dart` uses `BackdropFilter` with `ImageFilter.blur(sigmaX: 12, sigmaY: 12)` and a semi-transparent overlay to achieve a frosted glass effect that floats over the page content.

**10. Debounced, server-side search with request invalidation**
`SearchCubit` cancels and restarts a `Timer` on every keystroke with a 350ms delay before querying Supabase directly (`ilike`, price/rating filters, sort, pagination) — and tags every request with an incrementing id so a late response to an old query can never overwrite newer results.

---

## 🤝 Contributing

1. Fork the project
2. Create your branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ using Flutter

</div>
