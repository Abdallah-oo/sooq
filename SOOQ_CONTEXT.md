# SOOQ — Project Context

> **Purpose:** single source of truth for any new conversation. Upload this file first.
> **Rule:** the assistant must read this fully, then continue from "Current Status" and "Next Action". At the end of every phase it must output an updated version of this file.

- **Last updated:** 2026-11-25
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
2. **Deliver only what changed.** Give new and modified files only, never the whole project zip. Each file is listed with its path, marked `NEW`, `MODIFIED` or `DELETE`. Modified files are given in full when the change touches more than ~30% of the file, otherwise as clear before/after snippets with exact locations.
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

12. **Server code is part of every delivery.** SQL goes in `supabase/migrations/`, Edge Functions in `supabase/functions/` (with their tests and README). Money-related SQL is reviewed line by line and logic that can run without Supabase (e.g. HMAC helpers) is tested locally. State clearly what could NOT be executed in the assistant sandbox.

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

Settled in Phase 2:
- **Pricing is server-side.** `calculate_order` (internal) is the single source of truth; the app calls `quote_order` (checkout totals) and `place_order` (sends the expected total; server rejects with `PRICE_CHANGED` if it differs). The client never computes delivery fee or discounts.
- **Delivery rules live in `app_settings`** (single row: `delivery_fee`, `free_delivery_threshold`, `currency_code`), currently 2.99 / 50 / USD (owner had no preference, values kept as they were). Change with one SQL `update`.
- **Promo codes live in `promo_codes`** (percent, min order, max uses, dates, active). Customers cannot read the table; they validate through the RPCs. Seeded with TABANJA1/2/3 = 10/20/15 %.
- Order business errors are raised in SQL as plain codes (`raise exception 'PROMO_INVALID'`) and mapped to messages in `SupabaseErrorHandler._businessMessages`.

Settled in Phase 3:
- **Paymob Intention API + Unified Checkout** (hosted page opened in an in-app WebView). The secret key never reaches the app; card / wallet details are typed on Paymob's page.
- **Methods:** cash on delivery, card, mobile wallet (separate Paymob integration ids; the Edge Function sends only the integration of the chosen method).
- **Currency: EGP.** Product prices are already in EGP. Online methods exist only when `app_settings.currency_code = 'EGP'` (server rejects with `CURRENCY_UNSUPPORTED`, app hides them). The owner changes `app_settings` (fee / threshold) and the `$` symbol themselves.
- **The webhook is the only source of truth for payment status.** The redirect back from Paymob is just a signal: the app polls the order (every 2 s, up to 10 times) until `payment_status` becomes paid / failed.
- **Amounts are never taken from the client:** `create-payment` reads `orders.total`; `apply_payment_result` rejects a "paid" callback whose amount / currency differs from the order.
- Order lifecycle for online payment: order is created `pending` + `unpaid`; paid orders stay `pending` until the store confirms (dashboard phase). Customers can cancel only while nothing was paid (unpaid or failed). Unpaid online orders can be expired by `expire_unpaid_online_orders` (pg_cron, optional).

---

## 4. Tech Stack and Architecture (as it exists)

**Dependencies (key ones):** `flutter_bloc` (Cubit), `go_router`, `get_it`, `dartz`, `supabase_flutter`, `hive_ce` + `hive_ce_flutter`, `shared_preferences`, `cached_network_image`, `skeletonizer`, `shimmer`, `gap`, `image_picker`, `image_cropper`, `permission_handler`, `gal`, `http`, `flutter_map`, `latlong2`, `geolocator`, `webview_flutter`.
SDK: Dart `^3.9.0`.

**Layout (feature-first Clean Architecture):**

```
lib/
├── main.dart                 # Hive init -> Supabase.initialize -> setUpGetIt() -> runApp
├── sooq_app.dart             # MultiBlocProvider(CartCubit, FavoritesCubit) + MaterialApp.router
├── root.dart                 # Bottom nav shell (IndexedStack: Home, Fav, Search, Profile)
├── (repo root) supabase/  migrations/NNN_*.sql, functions/{_shared,create-payment,paymob-webhook}/ + README.md
├── core/
│   ├── config/               # map_config.dart (tiles, geocoder, defaults, user-agent)
│   ├── routing/              # app_router.dart (GoRouter, `_fadePage` helper), routes.dart
│   ├── services/supabase/    # client, constants, auth service, errors/
│   ├── services/hive/        # typed box access
│   ├── theme/                # AppColors, AppTextStyles
│   ├── utils/                # CustomButton, CustomText, CustomSnackBar, validators, money.dart (Money.format), app_date.dart, di/get_it.dart, ld/pref_helper.dart
│   └── widgets/              # AppNetworkImage, MessageState (empty / error state)
└── features/
    ├── Address/   Auth/  Cart/  Checkout/  Favorite/  Home/  On_Boarding/  Orders/  Payment/  Profile/  Search/
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
- App level: `CartCubit` (restored from Hive via `CartStorage`, auto-persisted in `onChange`), `FavoritesCubit`.
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

- `public.app_settings`, `public.promo_codes`, `public.orders` (`order_number` from sequence starting 1001, status / payment_method / payment_status as text + CHECK, price columns, address snapshot columns, `contact_phone`, `customer_name`), `public.order_items` (name / unit / image / price snapshots) — migration `003_orders.sql`.
- Functions (all `security definer`, `search_path = public`): `calculate_order` (internal, no client access), `quote_order`, `place_order` (COD only for now), `cancel_order` (pending + unpaid only). Error codes: NOT_AUTHENTICATED, EMPTY_CART, INVALID_ITEMS, PRODUCT_UNAVAILABLE, ADDRESS_NOT_FOUND, ADDRESS_PHONE_REQUIRED, PROMO_INVALID, PROMO_MIN_ORDER, PRICE_CHANGED, PAYMENT_METHOD_UNSUPPORTED, ORDER_NOT_FOUND, ORDER_NOT_CANCELLABLE.
- RLS: customers read own orders / items; admin reads all; **no client insert/update/delete** on orders or order_items. `app_settings` is readable by everyone, writable by admin. `promo_codes` admin-only. Admin status updates need a policy in the dashboard phase.
- `products.id` is `uuid`.
- Migration `004_payments.sql`: `orders.paymob_intention_id`, `orders.paymob_order_id`, `orders.paid_at`; table `payment_transactions` (PK `(transaction_id, status)`, `accepted` flag, trimmed audit `raw`, admin read only); function `apply_payment_result` (service role only; idempotent; returns paid | paid_on_cancelled | failed | refunded | duplicate | amount_mismatch | order_not_found); `place_order` now accepts cod | card | wallet (INVALID_PAYMENT_METHOD, CURRENCY_UNSUPPORTED); `cancel_order` also allows failed payments; `expire_unpaid_online_orders(minutes)` (service role only).
- **Edge Functions** (`supabase/functions/`): `create-payment` (JWT required; loads the caller's own order through RLS, creates the intention, returns `{checkout_url, return_url}`), `paymob-webhook` (deployed with `--no-verify-jwt`; verifies HMAC-SHA512 over the 20 documented fields, then calls `apply_payment_result`). Shared helpers + Deno tests in `_shared/`. Secrets: `PAYMOB_SECRET_KEY`, `PAYMOB_PUBLIC_KEY`, `PAYMOB_HMAC_SECRET`, `PAYMOB_CARD_INTEGRATION_ID`, `PAYMOB_WALLET_INTEGRATION_ID` (+ optional `PAYMOB_BASE_URL`, `PAYMOB_RETURN_URL`). Error codes returned to the app: NOT_AUTHENTICATED, INVALID_REQUEST, ORDER_NOT_FOUND, ORDER_NOT_PAYABLE, CURRENCY_UNSUPPORTED, PAYMENT_PROVIDER_ERROR, SERVER_MISCONFIGURED, SERVER_ERROR.

**To verify:** RLS policies on `categories`, `products`, `banners` (must be public read, admin-only write once the dashboard exists). Policies need an admin write path for the dashboard.

Supabase URL and anon key live in `lib/core/services/supabase/supabase_constants.dart` (anon key is public by design; safety depends on RLS).

---

## 6. Roadmap and Status

| # | Phase | Status | Scope |
|---|---|---|---|
| 0 | **Foundation** | Done (owner testing in parallel) | See Changelog |
| 1 | **Addresses + Map** | Done (owner testing in parallel) | `addresses` table + RLS; map picker (`flutter_map`, OSM); current location via `geolocator`; reverse geocoding; My Addresses list/add/edit/delete/set default; wire Profile -> My Addresses |
| 2 | **Orders + Checkout** | Done (owner testing in parallel) | `orders`, `order_items`, status enum; RPC `place_order` (server-side pricing, address snapshot, promo validation); Checkout screen (address + payment method + summary); real order placement; My Orders + order details; persist cart locally (Hive) |
| 3 | **Payment (Paymob)** | Code delivered, **waiting for owner's end-to-end test (Paymob test mode)** | `PaymentGateway` interface; Edge Function `create-payment` (auth -> Paymob order + payment key); WebView/SDK flow in app; Edge Function `paymob-webhook` (verify HMAC, update `orders.payment_status`); Cash on Delivery path; failure/retry handling |
| 4 | **Admin Dashboard** (`sooq_admin`, Flutter Web) | Not started | Admin login (role check); realtime orders table with filters; order details; change status; basic stats; later: products/categories management |
| 5 | **Order Tracking (customer)** | Not started | Realtime status updates, status timeline, push notification hook (later) |

Planned schema sketches (refine at phase start, do not treat as final):
- `addresses`: `id`, `user_id`, `label`, `full_address`, `latitude`, `longitude`, `building`, `floor`, `apartment`, `notes`, `is_default`, timestamps.
- `orders`: `id`, `user_id`, `status` (`pending|confirmed|preparing|out_for_delivery|delivered|cancelled`), `payment_method` (`cod|card|wallet`), `payment_status` (`unpaid|paid|failed|refunded`), `subtotal`, `discount`, `delivery_fee`, `total`, address snapshot columns, `paymob_order_id`, timestamps.
- `order_items`: `id`, `order_id`, `product_id`, `name_snapshot`, `unit_price_snapshot`, `quantity`.

---

## 7. Current Status

- Phases 0-2 delivered; owner testing them in parallel.
- Phase 3 (Paymob) delivered. Flow: Checkout (choose COD / Card / Wallet) -> `place_order` (online orders start unpaid) -> payment screen (`Routes.payment`, extra: `OrderModel`) -> `create-payment` -> Paymob page in a WebView -> redirect detected -> app polls the order -> webhook marks it paid -> success screen. Unpaid / failed online orders show "Payment pending" in My Orders and a **Pay now** button in the order details.
- Phase 3 needs from owner: set `app_settings` to EGP, run `004_payments.sql`, `flutter pub add webview_flutter`, set the 5 secrets, deploy both Edge Functions (`paymob-webhook` with `--no-verify-jwt`), set the callback URL in the Paymob dashboard, `flutter analyze`, then test with Paymob test cards / wallet (checklist in the delivery message).

## 8. Next Action

1. Get the results of the Phase 1-3 tests (analyze output, bugs, screenshots) and fix them first on `fix/phase-N-...` branches. Phase 3 especially: confirm the webhook is received (Supabase Dashboard -> Edge Functions -> Logs) and that a paid test order flips to `paid`.
2. Then start **Phase 4 (Admin Dashboard)** on branch `feature/phase-4-admin-dashboard`: separate Flutter Web project `sooq_admin` using the same Supabase project. Ask the owner first: where to host it (Firebase Hosting / Vercel / Supabase-less static host), scope of v1 (orders only vs products + categories + promo codes + settings), and who gets admin (`profiles.role`). Plan: `005_admin.sql` (admin policies: update `orders.status` through a guarded RPC `admin_set_order_status` with allowed transitions, admin CRUD on products / categories / promo_codes / app_settings, add `orders` to the `supabase_realtime` publication), admin login with role check (sign out non-admins), realtime orders table with filters (status, payment, date), order details with status actions, basic stats (today's orders, revenue from paid orders, pending count), refund visibility (`paid_on_cancelled`, `amount_mismatch` transactions).

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

- Orders list is not paginated (loads all of the user's orders). Add `range()` pagination when it matters.
- Cart rows show the price captured when the product was added; the checkout total is always the server's, so they can differ slightly if prices changed.
- `Money.symbol` is a constant (`$`). Other screens (product cards, favorites) still format prices on their own.
- No stock / availability model: `place_order` only checks that products exist.
- Promo `used_count` is not decremented when an order is cancelled.
- The cart is per device: it is cleared on logout, not synced between devices.
- Checkout address selection needs one tap on a card in the list (even right after adding a new address).

- The assistant could not execute SQL or Edge Functions (no Postgres / Deno in its sandbox). `003` and `004` were reviewed by hand and the Paymob helpers were tested under Node against Paymob's documented HMAC sample. If any SQL errors on first run, send the message and fix it on a `fix/phase-N-...` branch.
- No refund flow in the app: refunds are done from the Paymob dashboard and arrive through the webhook (`payment_status = 'refunded'`). `paid_on_cancelled` / `amount_mismatch` need manual review (Edge Function logs + `payment_transactions`).
- A retry from "Pay now" uses the order's original method (card or wallet); switching method on retry is not supported.
- `PAYMOB_RETURN_URL` defaults to `https://sooq.app/payment-return`, a placeholder that the WebView intercepts and never loads. Replace with a real page if the redirect ever needs to work outside the app.
- Test and live Paymob keys, integration ids and HMAC secret must be switched together at go-live (see `supabase/functions/README.md`).
- Product cards and other old widgets still show `$`; `Money.symbol` is a constant. Owner is changing the currency symbol.

---

## 10. Changelog

### Phase 3 — Payment (Paymob) (2026-11-25)

**Branch:** `feature/phase-3-paymob`
**SQL:** `supabase/migrations/004_payments.sql`. **New package:** `webview_flutter`. **Edge Functions:** `create-payment`, `paymob-webhook` (+ `_shared/{cors,paymob,paymob_test}.ts`, `README.md`).

**New files:** `features/Payment/` (`data/models/payment_session.dart`, `data/repos/{payment_repo,payment_repo_impl}.dart`, `presentation/cubit/payment_{cubit,state}.dart`, `presentation/views/payment_view.dart`, `presentation/views/widgets/paymob_web_view.dart`) and everything under `supabase/functions/`.

**Modified files:** `core/routing/{routes,app_router}.dart` (payment route), `core/utils/di/get_it.dart` (PaymentRepo), `core/services/supabase/errors/supabase_error_handler.dart` (FunctionException + payment codes), `features/Orders/data/models/{order_enums,order_model,order_quote}.dart` (wallet method, `isOnline`, `isAvailableIn`, `canPay`, `currencyCode`), `features/Orders/presentation/views/{order_details_view,order_success_view}.dart` and `widgets/order_card.dart` (Pay now, payment status), `features/Checkout/presentation/views/checkout_view.dart` and `widgets/payment_method_tile.dart` (3 methods, descriptions, branch to the payment screen).

**Design notes:** the redirect from Paymob is only a signal, the order is polled until the signed webhook has updated it; a stale `failed` from an earlier attempt is not mistaken for the current attempt's result; callbacks are idempotent (`payment_transactions` PK) and amount-checked inside one DB transaction with the order row locked; Paymob's `special_reference` is `<order uuid>_<timestamp>` so retries never collide and the webhook can map any callback to its order.

### Phase 2 — Orders + Checkout (2026-11-25)

**Branch:** `feature/phase-2-orders`
**SQL:** `supabase/migrations/003_orders.sql`. No new packages.

**New files:** `core/utils/{money,app_date}.dart`, `core/widgets/message_state.dart`; `features/Cart/data/{models/cart_item,local/cart_storage,local/hive_cart_storage}.dart`; `features/Orders/` (`data/models/{order_enums,order_item_model,order_model,order_quote}.dart`, `data/repos/{order_repo,order_repo_impl}.dart`, `presentation/cubits/{orders_cubit,order_details_cubit}/`, `presentation/views/{orders_view,order_details_view,order_success_view}.dart`, `widgets/{order_card,order_status_chip,price_breakdown}.dart`); `features/Checkout/presentation/` (`cubit/checkout_{cubit,state}.dart`, `views/checkout_view.dart`, `widgets/{checkout_address_card,payment_method_tile,promo_code_field}.dart`).

**Modified files:** `core/routing/{routes,app_router}.dart` (checkout, orders, orderDetails, orderSuccess), `core/utils/di/get_it.dart` (CartStorage, OrderRepo), `core/services/hive/hive_services.dart` + `main.dart` (Cart box), `core/services/supabase/errors/supabase_error_handler.dart` (business error codes, PGRST116), `sooq_app.dart` (CartCubit with storage), Cart (`cart_cubit`, `cart_state`, `cart_view_body`, `cart_summary_sheet`), `features/Profile/profile.dart` (My Orders), `features/Address/presentation/views/addresses_view.dart` (uses shared `MessageState`).

**Deleted:** `features/Cart/presentation/views/widgets/promo_code_field.dart` (hard-coded codes; replaced by the server-driven field in Checkout). `CartItem` moved to `features/Cart/data/models/cart_item.dart` and is re-exported by `cart_cubit.dart`.

**Design notes:** checkout failures after `place_order` trigger a silent re-quote so a `PRICE_CHANGED` rejection shows the new totals; order rows snapshot address, names and prices so later edits never change history; success screen resets the stack to Home before opening the order so "back" never lands on the empty cart.

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
