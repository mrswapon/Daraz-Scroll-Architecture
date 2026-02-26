# Daraz Scroll Architecture

A Flutter app that mimics a Daraz-style product listing, focused on **scroll architecture** and **gesture coordination** rather than visual polish.

## Run Instructions

```bash
flutter pub get
flutter run
```

**Test credentials:** `mor_2314` / `83r5^_` (pre-filled on login screen)

## Architecture: MVC + BLoC

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # App widget, BLoC providers, routing
├── models/                            # M – Data models
│   ├── product_model.dart
│   └── user_model.dart
├── controllers/                       # C – BLoC state management
│   ├── auth/                          # Auth BLoC (login/logout)
│   ├── product/                       # Product BLoC (fetch/refresh)
│   └── profile/                       # Profile BLoC (user data)
├── views/                             # V – UI screens and widgets
│   ├── login/login_view.dart
│   ├── home/
│   │   ├── home_view.dart             # ★ Core scroll architecture
│   │   └── widgets/
│   │       ├── collapsible_header.dart
│   │       ├── sticky_tab_bar.dart
│   │       └── product_card.dart
│   └── profile/profile_view.dart
├── services/
│   └── api_service.dart               # HTTP client (FakeStore API)
└── repositories/
    ├── auth_repository.dart
    ├── product_repository.dart
    └── user_repository.dart
```

---

## Scroll Architecture Explanation

### 1. How Horizontal Swipe Was Implemented

Horizontal swipe between tabs is handled by Flutter's built-in `TabBarView` widget. `TabBarView` internally uses a `PageView` with horizontal scroll direction. Tabs are switchable by:

- **Tapping** the `TabBar` (in the sticky header)
- **Horizontal swiping** on the `TabBarView` body

**Why this works without conflicts:** Flutter's gesture arena disambiguates horizontal vs vertical drag gestures. When a user starts dragging, the system determines the primary axis of motion. If horizontal, the `TabBarView`'s `PageView` claims the gesture. If vertical, the `NestedScrollView`'s scroll controller claims it. This is Flutter's built-in gesture disambiguation — no custom `GestureDetector` or `RawGestureDetector` is needed.

### 2. Who Owns the Vertical Scroll and Why

**`NestedScrollView`** owns vertical scroll coordination. It manages two layers:

| Layer | What it controls | Scroll controller |
|-------|-----------------|-------------------|
| **Outer** | Collapsible `SliverAppBar` + pinned `SliverPersistentHeader` (tab bar) | `NestedScrollView`'s outer controller |
| **Inner** | Product grid inside each tab | One inner controller per tab (auto-managed) |

**Why NestedScrollView:**
- It provides a **single continuous scroll experience** to the user: scrolling up first collapses the header, then scrolls the product list.
- The outer scroll (header collapse state) is **shared across all tabs** — switching tabs does not reset the header position.
- Each tab's inner scroll position is preserved independently via `PageStorageKey`.
- `SliverOverlapAbsorber` + `SliverOverlapInjector` ensure the pinned tab bar doesn't overlap content.

**Why not a plain `CustomScrollView`:**
A single `CustomScrollView` with slivers for everything would require manually swapping sliver children when tabs change, losing the smooth horizontal page transition that `TabBarView` provides. It would also require manual scroll position management per tab.

### 3. Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| `NestedScrollView` over `CustomScrollView` | Coordinates outer (header) and inner (content) scrolling without manual state management |
| `SliverPersistentHeader` with `pinned: true` | Tab bar stays visible after header collapse — no magic offsets needed |
| `AutomaticKeepAliveClientMixin` on tab content | Preserves widget state and scroll position when switching tabs |
| `PageStorageKey` on inner `CustomScrollView` | Persists scroll offset across tab switches |
| `SliverOverlapAbsorber/Injector` | Prevents content from rendering behind the pinned tab bar |
| `RefreshIndicator` inside each tab | Pull-to-refresh works from any tab; triggers shared `ProductBloc` refresh |
| All 3 tab datasets fetched in parallel | Single `ProductsRefreshRequested` event refreshes all tabs simultaneously |

### 4. Trade-offs and Limitations

1. **`NestedScrollView` creates coordinated scrollables, not literally one `ScrollController`.** The "single scroll" guarantee is from the user's perspective — one continuous vertical scroll with no jitter. Internally, `NestedScrollView` coordinates outer + inner controllers.

2. **`SliverAppBar` with `pinned: false`** means the entire header scrolls out of view. If the design needed the search bar to remain visible (pinned), the header would need `pinned: true` with a smaller `collapsedHeight`.

3. **Pull-to-refresh only triggers at the top of inner scroll.** If the user has scrolled far down in a tab, they must scroll back to the top to trigger refresh. This is standard `RefreshIndicator` behavior.

4. **FakeStore API latency.** All three category fetches happen in parallel (`Future.wait`), but initial load depends on network speed. The BLoC loading state shows a spinner during this time.

5. **No infinite scroll / pagination.** FakeStore API returns all products at once (20 items). For a real Daraz-scale app, the architecture would need sliver-based pagination (e.g., `SliverList` with lazy loading via scroll position listeners).

## API Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `POST /auth/login` | Authentication (returns JWT) |
| `GET /products` | All products (Tab 1) |
| `GET /products/category/electronics` | Electronics (Tab 2) |
| `GET /products/category/jewelery` | Jewelery (Tab 3) |
| `GET /users/{id}` | User profile |
