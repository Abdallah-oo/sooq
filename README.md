<div align="center">

# 🛍️ Sooq

### A modern grocery shopping app built with Flutter & Supabase

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📸 Screenshots

> Add your screenshots inside a `screenshots/` folder in the repo root.

| | | |
|:---:|:---:|:---:|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Search](screenshots/search.png) |
| **Login** | **Home** | **Search** |
| ![Cart](screenshots/cart.png) | ![Favorites](screenshots/favorites.png) | ![Signup](screenshots/signup.png) |
| **Cart** | **Favorites** | **Sign Up** |

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔐 **Authentication** | Email & password login, signup with profile image and password strength indicator |
| 🏠 **Home** | Animated banner carousel, category filter, product grid, floating cart bar |
| 🔍 **Search** | Debounced live search, filter by category/price/rating, sort options, query highlighting |
| 🛒 **Cart** | Add/remove items, promo codes, delivery fee logic, swipe-to-delete, order placement |
| ❤️ **Favorites** | Persistent wishlist with sort, staggered grid animation, synced across all screens |

---

## 🏗️ Architecture

The project follows **Clean Architecture** with strict layer separation across every feature.

```
lib/
├── core/
│   ├── di/               # Dependency injection — get_it
│   ├── routing/          # GoRouter — all named routes
│   ├── supabase/         # Client, services, error mapping
│   ├── theme/            # AppColors, AppTextStyles
│   └── utils/            # Shared widgets, validators, snackbar
│
└── features/
    ├── Auth/
    ├── Home/
    ├── Search/
    ├── Cart/
    └── Favorites/
```

Every feature follows the same internal structure:

```
feature/
├── data/
│   ├── models/           # Typed data classes
│   └── repos/
│       ├── repo.dart          # Abstract contract
│       └── repo_impl.dart     # Supabase implementation
└── presentation/
    ├── cubits/
    │   ├── cubit.dart
    │   └── state.dart
    └── views/
        ├── view.dart
        └── widgets/
```

---

## 🧠 State Management

State management is handled exclusively with **flutter_bloc (Cubit)** — no `setState` for business logic anywhere in the app.

| Cubit | Scope | Why |
|-------|-------|-----|
| `AuthCubit` | View-scoped | Tied to auth screen lifecycle |
| `CategoryCubit` | View-scoped | Tied to home screen lifecycle |
| `SearchCubit` | View-scoped | Tied to search screen lifecycle |
| `CartCubit` | **Singleton** | Shared across home, search, cart screens |
| `FavoritesCubit` | **Singleton** | Shared across home, search, favorites screens |

Singleton cubits are registered via `get_it` and initialized in `main()` — their state is live on every screen simultaneously with no synchronization needed.

---

## 🔧 Tech Stack

| Concern | Solution |
|---------|----------|
| Framework | Flutter |
| Language | Dart |
| Backend | Supabase (Auth + Database + Storage) |
| State Management | flutter_bloc (Cubit) |
| Dependency Injection | get_it |
| Navigation | go_router |
| Error Handling | dartz (`Either<Failure, Success>`) |
| Local Persistence | shared_preferences |
| Image Handling | image_picker + image_cropper |
| Image Caching | cached_network_image |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: # Cubit state management
  get_it:       # Service locator / DI
  dartz:        # Functional Either type
  go_router:    # Declarative navigation
  supabase_flutter:      # Backend
  shared_preferences:    # Local persistence
  image_picker:          # Camera & gallery
  image_cropper:         # Circle crop for avatars
  cached_network_image:  # Network image caching
  carousel_slider:       # Home banner
  gap:                   # Clean spacing
  flutter_svg:           # SVG icons
  auto_size_text:        # Responsive text
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

Create a file at `lib/core/supabase/supabase_constants.dart`:
```dart
class SupabaseConstants {
  static const String url     = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

> ⚠️ Never commit your real keys. Add `supabase_constants.dart` to `.gitignore`.

**4. Run the app**
```bash
flutter run
```

---

## 📁 Project Structure

<details>
<summary>Click to expand full structure</summary>

```
lib/
├── core/
│   ├── di/
│   │   └── get_it.dart
│   ├── routing/
│   │   └── routes.dart
│   ├── supabase/
│   │   ├── supabase_client.dart
│   │   ├── supabase_constants.dart
│   │   ├── supabase_auth_services.dart
│   │   └── supabase_error.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   └── utils/
│       ├── validators.dart
│       ├── custom_button.dart
│       ├── custom_text.dart
│       ├── snack_bar.dart
│       └── responsive.dart
│
└── features/
    ├── Auth/
    │   ├── data/
    │   │   └── repos/
    │   │       ├── auth_repo.dart
    │   │       └── auth_repo_impl.dart
    │   └── presentation/
    │       ├── cubits/
    │       │   ├── auth_cubit/
    │       │   └── pick_image_cubit/
    │       └── views/
    │           ├── Login_Views/
    │           ├── Signup_Views/
    │           └── widgets/
    │
    ├── Home/
    │   ├── data/
    │   │   └── models/
    │   │       ├── product_model.dart
    │   │       ├── product_constants.dart
    │   │       ├── category_model.dart
    │   │       └── category_constants.dart
    │   └── presentation/
    │       ├── cubits/
    │       │   ├── cart_cubit/
    │       │   └── category_cubit/
    │       └── views/
    │           └── widgets/
    │
    ├── Search/
    │   ├── data/
    │   │   └── search_repository.dart
    │   └── presentation/
    │       ├── cubits/
    │       │   └── search_cubit/
    │       └── views/
    │           └── widgets/
    │
    ├── Cart/
    │   └── presentation/
    │       └── views/
    │           └── widgets/
    │
    └── Favorites/
        ├── data/
        │   └── favorites_repository.dart
        └── presentation/
            ├── cubits/
            │   └── favorites_cubit/
            └── views/
                └── widgets/
```

</details>

---

## 🎨 Design System

All colors and typography are centralized — no hardcoded values anywhere in the codebase.

**Colors** — defined in `AppColors`:
- `AppColors.primary` — brand green `#08650B`
- `AppColors.surface` — light grey `#F7F7F7`
- `AppColors.error` — red `#EF4444`
- Shadow tokens: `shadowSm`, `shadowMd`, `shadowLg`, `shadowPrimary`

**Typography** — defined in `AppTextStyles` using **Poppins**:
- `displaySmall`, `titleLarge`, `titleMedium`, `titleSmall`
- `bodyLarge`, `bodyMedium`, `bodySmall`
- `labelLarge`, `labelMedium`, `button`, `caption`

---

## 🔑 Key Design Decisions

**1. Either-based error handling**
All repository methods return `Either<SupabaseError, T>`. The UI never catches raw exceptions — errors are always typed and user-readable before they reach the cubit.

**2. Singleton cubits via get_it**
`CartCubit` and `FavoritesCubit` are registered as singletons so the cart badge, the cart screen, and every product card all share one source of truth — zero sync issues.

**3. Debounced search**
`SearchCubit` cancels and restarts a 350ms `Timer` on every keystroke. Zero wasted network calls while the user is typing.

**4. ValueNotifier for local UI state**
Password visibility toggles, promo code status, and loading indicators inside sheets use `ValueNotifier` — the parent widget never rebuilds for purely local state changes.

**5. Reusable `FavoriteButton`**
Drop `FavoriteButton(product: product)` anywhere in the app. It reads from and writes to `FavoritesCubit` via `get_it` internally. Zero wiring required from the caller.

---

## 🗺️ Roadmap

- [ ] Orders history screen
- [ ] Product detail page with Hero transition
- [ ] Push notifications
- [ ] Address management
- [ ] Payment integration
- [ ] Dark mode support
- [ ] Localization (Arabic / English)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome.

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
