# SOOQ — Project Context

> **Purpose:** single source of truth for any new conversation. Upload this file first.
> **Rule:** the assistant must read this fully, then continue from "Current Status" and "Next Action". At the end of every phase it must output an updated version of this file.

- **Last updated:** 2026-11-23
- **Owner:** Abdallah Ahmed (Flutter developer, Cairo, Egypt)
- **Language:** the owner writes in Egyptian Arabic. Reply in Egyptian Arabic. Code, comments, identifiers and SQL stay in English.

---

## 1. Goal

Evolve **Sooq** (grocery shopping app, Flutter + Supabase) into a complete product:

1. **Customer app:** Google/Map-based delivery addresses, real orders, online payment (Paymob), order tracking.
2. **Admin dashboard:** to follow and manage orders (separate Flutter Web project).

Quality bar: **clean and professional**, portfolio-grade code.

---

## 2. Working Rules (how we work)

These rules are mandatory in every conversation.

1. **Feature by feature, one phase at a time.** Never start the next phase before the owner confirms the current one works.
2. **Deliver only what changed.** Give new and modified files only, never the whole project zip. Each file is listed with its path, marked `NEW` or `MODIFIED`. Modified files are given in full when the change touches more than ~30% of the file, otherwise as clear before/after snippets with exact locations.
3. **SQL is delivered as a separate numbered file** under `supabase/migrations/NNN_name.sql`, idempotent (`if not exists`, `drop policy if exists`), and always includes RLS.
4. **Keep the existing structure** (section 4) unless there is a clear improvement. When changing structure, state the reason in one or two lines first.
5. **No Flutter SDK in the assistant sandbox.** The assistant cannot run `flutter analyze` or build. It must review code by hand, check imports, brackets and unused imports, and ask the owner to run `flutter pub get && flutter analyze` and report errors.
6. **Every delivery ends with:**
   - a short list of what changed and why,
   - a "What you need to do" checklist (SQL to run, `pubspec` additions, platform config, manual test flow),
   - known limitations.
7. **Security by default.** Secrets never go in the app. Prices and totals are never trusted from the client. Every table has RLS.
8. **Clean code conventions:** small widgets, no business logic in widgets, cubits talk to repository interfaces only, errors via `Either<SupabaseError, T>`, no hard-coded magic numbers or strings in widgets (move to constants or config).
9. **Update this file** at the end of every phase: move the phase to Done, update Current Status, Next Action, Backend State and the Changelog.
10. **Git branch name on every delivery.** Each delivery starts with the branch name to create, using `feature/phase-N-short-name` (kebab-case, English). Fixes found while testing a delivered phase use `fix/phase-N-short-description`. Also give a one-line Conventional Commit message (e.g. `feat(address): add map picker and address book`). Branch is created from the latest `main` after the previous phase was merged.
11. If something in the existing code is wrong or risky, say so briefly and fix it as part of the relevant phase, do not silently work around it.

---

## 3. Decisions Already Made

| Topic | Decision | Notes |
|---|---|---|
| Payment gateway | **Paymob** | Egypt: cards + mobile wallets. Built behind a `PaymentGateway` interface so it can be swapped. Also support **Cash on Delivery**. |
| Maps | **`flutter_map` + OpenStreetMap** | No API key or billing needed. Hidden behind a small abstraction so Google Maps can replace it later if wanted. |
| Dashboard | **Separate Flutter Web project `sooq_admin`** | Same Supabase project. Admin access via `profiles.role = 'admin'` and `is_admin()` in RLS. |
| Backend | **Supabase** (existing project) | Auth, Postgres, Storage, Edge Functions (for Paymob). |
| Payment secrets | **Only in Edge Functions secrets** | Paymob API key, HMAC secret and integration IDs never ship in the app. |
| Order totals | **Computed server-side** | Via RPC `place_order` that reads real product prices. Client totals are for display only. |

Open decisions (ask the owner when the phase starts):
- Currency: the UI currently shows `$`. Egypt means **EGP**. Paymob amounts are in **piasters** (EGP x 100). Decide and centralise in one config.
- Delivery fee and free-delivery threshold are hard-coded in `cart_summary_sheet.dart` (`2.99`, `50.0`). Move to config or a `app_settings` table.
- Promo codes: `PromoCodeField` appears to be client-side only. Verify and move validation server-side in the Orders phase.

---

## 4. Tech Stack and Architecture (as it exists)

**Dependencies (key ones):** `flutter_bloc` (Cubit), `go_router`, `get_it`, `dartz`, `supabase_flutter`, `hive_ce` + `hive_ce_flutter`, `shared_preferences`, `cached_network_image`, `skeletonizer`, `shimmer`, `gap`, `image_picker`, `image_cropper`, `permission_handler`, `gal`, `http`.
SDK: Dart `^3.9.0`.

**Layout (feature-first Clean Architecture):**

```
lib/
├── main.dart                 # Hive init -> Supabase.initialize -> setUpGetIt() -> runApp
├── sooq_app.dart             # MultiBlocProvider(CartCubit, FavoritesCubit) + MaterialApp.router
├── root.dart                 # Bottom nav shell (IndexedStack: Home, Fav, Search, Profile)
├── core/
│   ├── config/               # map_config.dart (tiles, geocoder, defaults, user-agent)
│   ├── routing/              # app_router.dart (GoRouter, `_fadePage` helper), routes.dart
│   ├── services/supabase/    # client, constants, auth service, errors/
│   ├── services/hive/        # typed box access
│   ├── theme/                # AppColors, AppTextStyles
│   ├── utils/                # CustomButton, CustomText, CustomSnackBar, validators, di/get_it.dart, ld/pref_helper.dart
│   └── widgets/              # AppNetworkImage
└── features/
    ├── Address/   Auth/  Cart/  Favorite/  Home/  On_Boarding/  Profile/  Search/
    └── (each: data/{models,repos,local}  presentation/{cubits,views,views/widgets})
```

**Conventions to follow in new code:**
- Folder names follow the existing style (`features/Auth`, `features/Cart`, PascalCase feature folders).
- Repos: `abstract interface class XRepo` + `XRepoImpl`, registered in GetIt **as the interface**.
- Repo methods return `Future<Either<SupabaseError, T>>`; catch with `SupabaseErrorHandler.handleSupabaseError(e)`.
- State: Cubits with simple state classes. Pagination uses Supabase `range()`.
- Navigation: `GoRouter` with `CustomTransitionPage` + `FadeTransition` (use `AppRouter._fadePage` for new routes). Typed route args classes (e.g. `AddressPickerArgs`) go in the feature's `presentation/route_args/`. Route names in `Routes`. **Never pass `BuildContext` or cubits through `extra`.** App-level cubits are read with `context.read`.
- UI: use `AppColors`, `AppTextStyles`, `CustomButton`, `CustomText`, `CustomSnackBar`. Keep the current visual style (green primary, rounded cards, floating blurred nav bar).
- DI: `setUpGetIt()` runs **after** `Supabase.initialize`.
- Errors: `SupabaseErrorHandler` maps `AuthException`, `PostgrestException` (RLS, unique, FK, check, JWT), socket and timeout errors to user-friendly messages. Map/location errors use `MapFailure` (`features/Address/data/services/map_failure.dart`).
- Package: Android `applicationId` / namespace is **`com.abdallah.sooq`**.

**Provider scoping (important):**
- App level: `CartCubit`, `FavoritesCubit`.
- Root route: `CategoryCubit`, `HomeCubit`, `AuthCubit` (used for logout from Profile).
- Login / Signup routes: their own `AuthCubit` (+ `PickImageCubit` on signup).

---

## 5. Backend State (Supabase)

**Existing tables** (created before this work; schema inferred from code, no SQL file for them in the repo):
- `categories` (`id`, `name`, ...)
- `products` (`id`, `name`, `image_url`, `price`, `rating`, `votes`, `category_id`, `unit`, `created_at`; joined as `categories(name)`)
- `banners` (`is_active`, `sort_order`, ...)
- Storage bucket for product images.

**Created by this work:**
- `public.profiles` (`id` -> `auth.users`, `full_name`, `phone`, `avatar_url`, `role` enum `customer|admin`, timestamps) — migration `001_foundation.sql`
- Trigger `on_auth_user_created` -> `handle_new_user()` (reads `raw_user_meta_data->>'full_name'`)
- Function `is_admin()` (security definer) for RLS policies
- RLS on `profiles`: select own or admin; update own, role cannot be changed by the user.

- `public.addresses` (user_id, label, full_address, latitude, longitude, building, floor, apartment, phone, notes, is_default, timestamps) — migration `002_addresses.sql`. DB triggers: first address is default; setting a default un-marks the old one; deleting the default promotes the newest remaining one. Unique partial index: one default per user. RLS: owner CRUD, admin read.

**To verify:** RLS policies on `categories`, `products`, `banners` (must be public read, admin-only write once the dashboard exists). Policies need an admin write path for the dashboard.

Supabase URL and anon key live in `lib/core/services/supabase/supabase_constants.dart` (anon key is public by design; safety depends on RLS).

---

## 6. Roadmap and Status

| # | Phase | Status | Scope |
|---|---|---|---|
| 0 | **Foundation** | Done (owner testing in parallel) | See Changelog |
| 1 | **Addresses + Map** | Code delivered, **waiting for owner's test + analyze** | `addresses` table + RLS; map picker (`flutter_map`, OSM); current location via `geolocator`; reverse geocoding; My Addresses list/add/edit/delete/set default; wire Profile -> My Addresses |
| 2 | **Orders** | Not started | `orders`, `order_items`, status enum; RPC `place_order` (server-side pricing, address snapshot, promo validation); Checkout screen (address + payment method + summary); real order placement; My Orders + order details; persist cart locally (Hive) |
| 3 | **Payment (Paymob)** | Not started | `PaymentGateway` interface; Edge Function `create-payment` (auth -> Paymob order + payment key); WebView/SDK flow in app; Edge Function `paymob-webhook` (verify HMAC, update `orders.payment_status`); Cash on Delivery path; failure/retry handling |
| 4 | **Admin Dashboard** (`sooq_admin`, Flutter Web) | Not started | Admin login (role check); realtime orders table with filters; order details; change status; basic stats; later: products/categories management |
| 5 | **Order Tracking (customer)** | Not started | Realtime status updates, status timeline, push notification hook (later) |

Planned schema sketches (refine at phase start, do not treat as final):
- `addresses`: `id`, `user_id`, `label`, `full_address`, `latitude`, `longitude`, `building`, `floor`, `apartment`, `notes`, `is_default`, timestamps.
- `orders`: `id`, `user_id`, `status` (`pending|confirmed|preparing|out_for_delivery|delivered|cancelled`), `payment_method` (`cod|card|wallet`), `payment_status` (`unpaid|paid|failed|refunded`), `subtotal`, `discount`, `delivery_fee`, `total`, address snapshot columns, `paymob_order_id`, timestamps.
- `order_items`: `id`, `order_id`, `product_id`, `name_snapshot`, `unit_price_snapshot`, `quantity`.

---

## 7. Current Status

- Phase 0 delivered; owner testing it in parallel (SQL run, admin promotion, `flutter analyze`, signup/login/logout flow).
- Phase 1 (Addresses + Map) code and `002_addresses.sql` delivered. Flow: Profile -> My Addresses -> Add -> map picker (pin in center, GPS button, reverse geocoding) -> details form -> save. Edit reuses the same flow. `AddressesView` supports `selectMode` (route `extra: true`) for checkout.
- Phase 1 needs from owner: `flutter pub add flutter_map latlong2 geolocator`, Android/iOS location permissions, run `002_addresses.sql`, `flutter analyze`, manual test.

## 8. Next Action

1. Get the results of Phase 0 and Phase 1 testing (analyze output, bugs, screenshots if UI needs tweaks). Fix them first.
2. Then start **Phase 2 (Orders)** on branch `feature/phase-2-orders`: `003_orders.sql` (`orders`, `order_items`, status enum, RLS, RPC `place_order` with server-side pricing + address snapshot), `OrderRepo`, Checkout screen (select address via `Routes.addresses` with `extra: true`, payment method, summary), persist cart locally, My Orders + details. Ask the owner the open decisions first: currency (EGP?), delivery fee / free threshold source, promo-code rules.

---

## 9. Known Issues and Tech Debt

- Favorites are stored locally per device (by product id), not per user. Consider moving to Supabase `favorites` table.
- Cart is in-memory only (lost on app close). Addressed in Phase 2.
- Checkout is a fake success dialog that only clears the cart. Replaced in Phase 2.
- Onboarding shows on every cold start for logged-out users; README claims "first launch only" but no flag is persisted.
- `test/widget_test.dart` is the Flutter default and probably does not match the app.
- README is partly out of date (e.g. architecture tree, features). Update at the end.
- `supabase_constants.dart` hard-codes URL and key. Optional: move to `--dart-define`.
- `CustomTextField` lives in `features/Auth/.../widgets` but is now used by Address too: move to `core/widgets` (touches Auth imports).
- OSM public tiles and Nominatim are for development / low traffic only (usage policies). Before a big release switch tile provider and geocoder via `MapConfig` + `NominatimGeocodingService`. Nominatim call sets a `User-Agent` header, which browsers forbid, so web builds need a different geocoder.
- No limit on addresses per user (add a cap in DB or UI if needed).
- Routes that take `state.extra` (`categoryProducts`, `addressPicker`, `addressForm`) crash if the process is restored without `extra`. Acceptable for now.

---

## 10. Changelog

### Phase 1 — Addresses + Map (2026-11-23)

**Branch:** `feature/phase-1-addresses-map`

**SQL:** `supabase/migrations/002_addresses.sql`.
**New dependencies:** `flutter_map`, `latlong2`, `geolocator` (added with `flutter pub add`). Android: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`. iOS: `NSLocationWhenInUseUsageDescription`.

**New files:** `lib/core/config/map_config.dart`; `lib/features/Address/` with `data/models/address_model.dart`, `data/repos/{address_repo,address_repo_impl}.dart`, `data/services/{map_failure,location_service,geocoding_service}.dart`, `presentation/cubits/{addresses_cubit,address_picker_cubit,address_form_cubit}/`, `presentation/route_args/address_route_args.dart`, `presentation/views/{addresses_view,address_picker_view,address_form_view}.dart`, `presentation/views/widgets/address_card.dart`.

**Modified files:** `core/routing/routes.dart` (3 routes), `core/routing/app_router.dart` (3 routes + `_fadePage`), `core/utils/di/get_it.dart` (AddressRepo, LocationService, GeocodingService), `core/services/supabase/errors/supabase_error_handler.dart` (PostgrestException mapping), `features/Profile/profile.dart` (My Addresses opens the list).

**Design notes:** picker cubit debounces reverse-geocoding (700 ms) and ignores stale responses via a request counter; the address text stays editable in the form so geocoder failures or inaccuracies never block the user; default-address integrity lives in DB triggers, not in the app.

### Phase 0 — Foundation (2026-11-23)

**Branch:** `feature/phase-0-foundation`

**SQL:** `supabase/migrations/001_foundation.sql` (profiles, role enum, signup trigger, backfill, `is_admin()`, RLS).

**Modified files:**
- `lib/main.dart` — init order: Hive -> Supabase -> `setUpGetIt()`.
- `lib/sooq_app.dart` — app-level `CartCubit` + `FavoritesCubit`; title `Sooq`.
- `lib/core/utils/di/get_it.dart` — registers `AuthRepo` (interface).
- `lib/core/routing/app_router.dart` — session redirect on `/`; Cart route no longer takes `BuildContext`; Root route provides `AuthCubit`; `CategoryProductsViewParameters` now only holds `category`.
- `lib/core/services/supabase/supabase_auth_services.dart` — `signUp` takes `name`, sends `data: {'full_name': name}`.
- `lib/features/Auth/data/repos/auth_repo.dart`, `auth_repo_impl.dart` — `signOut()` added; signup passes name.
- `lib/features/Auth/presentation/cubits/Auth_Cubit/auth_cubit.dart`, `auth_state.dart` — `AuthAction.logout`, `onTapLogout()`.
- `lib/features/Profile/profile.dart` — real logout with confirm dialog; clears cart; `context.go(login)`.
- `lib/features/Home/presentation/views/category_products_view.dart`, `widgets/products_section.dart`, `widgets/cart_bar.dart`, `widgets/home_app_bar.dart` — removed cubit/context passing; unused imports cleaned.

---

## 11. How to Start a New Conversation

Paste or attach this file, then say something like:

> Read SOOQ_CONTEXT.md. Continue from "Next Action". Follow the Working Rules. Send me only changed files.

If the owner also attaches the project zip, the assistant should compare it against section 4 and the Changelog before writing code, and mention any difference it finds.
