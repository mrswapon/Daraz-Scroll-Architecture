# Daraz Scroll Architecture

A Flutter app that mimics a Daraz-style product listing, focused on **scroll architecture** and **gesture coordination** rather than visual polish.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK `>=3.9.2`
- Dart SDK `>=3.9.2`

### Run Instructions

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

**Test credentials:** `mor_2314` / `83r5^_` (pre-filled on login screen)

---

## 📱 App Features

- **Authentication** — Login screen with JWT token-based auth
- **Product Listing** — Multi-tab product catalog with category filtering
- **Advanced Scrolling** — Collapsible header with sticky tab bar
- **Search Functionality** — Real-time product search filtering
- **Pull-to-Refresh** — Refresh all tabs simultaneously
- **Profile View** — User profile with address details
- **Shimmer Loading** — Skeleton loading states for better UX

---

## 🏗️ Architecture: Clean Architecture + BLoC

This project follows **Clean Architecture** principles with clear separation of concerns across layers:

```
lib/
├── core/                                    # Shared utilities and base classes
│   ├── error/
│   │   └── failure.dart                     # Failure types (Server, Cache, Connection)
│   └── usecase/
│       └── usecase.dart                     # Base UseCase contract + Either type
│
├── feature/                                 # Feature module
│   ├── data/                                # Data implementation layer
│   │   ├── models/
│   │   │   ├── product_dto.dart             # Product DTO with JSON parsing + entity mapper
│   │   │   └── user_dto.dart                # User DTO with JSON parsing + entity mapper
│   │   ├── repositories/
│   │   │   ├── auth_repository_impl.dart    # Auth repository implementation
│   │   │   ├── product_repository_impl.dart # Product repository implementation
│   │   │   └── user_repository_impl.dart    # User repository implementation
│   │   └── sources/
│   │       └── remote_data_source.dart      # HTTP client for FakeStore API
│   │
│   ├── domain/                              # Business logic layer (Framework-independent)
│   │   ├── entities/
│   │   │   ├── product_entity.dart          # Product & Rating domain entities
│   │   │   └── user_entity.dart             # User, Name & Address domain entities
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart         # Auth repository interface
│   │   │   ├── product_repository.dart      # Product repository interface
│   │   │   └── user_repository.dart         # User repository interface
│   │   └── usecases/
│   │       ├── auth/
│   │       │   └── login_usecase.dart       # Login interaction
│   │       ├── product/
│   │       │   ├── get_all_products_usecase.dart
│   │       │   ├── get_products_by_category_usecase.dart
│   │       │   └── get_categories_usecase.dart
│   │       └── user/
│   │           └── get_user_usecase.dart    # Get user by ID
│   │
│   └── presentation/                        # UI/State management layer
│       ├── blocs/
│       │   ├── auth/
│       │   │   ├── auth_bloc.dart           # Auth state management
│       │   │   ├── auth_event.dart
│       │   │   └── auth_state.dart
│       │   ├── product/
│       │   │   ├── product_bloc.dart        # Product state management
│       │   │   ├── product_event.dart
│       │   │   └── product_state.dart
│       │   └── profile/
│       │       ├── profile_bloc.dart        # Profile state management
│       │       ├── profile_event.dart
│       │       └── profile_state.dart
│       └── widgets/
│           ├── home/
│           │   ├── home_view.dart           # ★ Core scroll architecture
│           │   └── widgets/
│           │       ├── collapsible_header.dart
│           │       ├── sticky_tab_bar.dart
│           │       ├── product_card.dart
│           │       └── product_card_shimmer.dart
│           ├── login/
│           │   └── login_view.dart
│           └── profile/
│               └── profile_view.dart
│
├── main.dart                                # Entry point
└── app.dart                                 # App widget, DI wiring, routing
```

---

## 📐 Clean Architecture Layers

### Dependency Rule

**Source code dependencies only point inward.** The inner layers know nothing about outer layers:

```
Presentation → Domain ← Data
     ↓              ↑
   Flutter      External
   (BLoC)       APIs/DBs
```

### Layer Responsibilities

| Layer | Components | Responsibility | Framework Dependency |
|-------|-----------|----------------|---------------------|
| **Domain** | Entities, Repositories (interfaces), UseCases | Business logic & rules | Pure Dart (no Flutter) |
| **Data** | DTOs, Repository Implementations, Data Sources | Data fetching & mapping | `http` package |
| **Presentation** | BLoCs, Widgets | UI & state management | `flutter`, `flutter_bloc` |
| **Core** | Failure types, Either type, UseCase base | Shared utilities | Pure Dart |

### Key Design Patterns

#### 1. Repository Pattern
- Domain layer defines interfaces (contracts)
- Data layer provides implementations
- BLoCs depend on domain interfaces, not concrete implementations

#### 2. Use Case (Interactor) Pattern
- Each use case encapsulates a single business operation
- Use cases are the only way presentation layer accesses domain logic
- Examples: `LoginUseCase`, `GetAllProductsUseCase`, `GetUserUseCase`

#### 3. DTO to Entity Mapping
- Data layer uses DTOs (Data Transfer Objects) for JSON parsing
- DTOs map to domain entities via `.toEntity()` method
- Domain entities are pure business objects, framework-independent

#### 4. Either Type for Error Handling
- All use cases return `Either<Failure, T>`
- `Left` represents failure, `Right` represents success
- BLoCs handle both cases explicitly via pattern matching

---

## 🔄 State Management with BLoC

### Auth Flow
```
LoginView → AuthBloc → LoginUseCase → AuthRepository → RemoteDataSource
                                    ↓
                            JWT Token Storage
```

### Product Flow
```
HomeView → ProductBloc → GetAllProductsUseCase → ProductRepository → RemoteDataSource
                       ↓
                GetProductsByCategoryUseCase (per tab)
```

### Profile Flow
```
ProfileView → ProfileBloc → GetUserUseCase → UserRepository → RemoteDataSource
```

---

## 📜 Scroll Architecture Explanation

### 1. Horizontal Swipe Implementation

Horizontal swipe between tabs is handled by Flutter's built-in `TabBarView` widget. `TabBarView` internally uses a `PageView` with horizontal scroll direction. Tabs are switchable by:

- **Tapping** the `TabBar` (in the sticky header)
- **Horizontal swiping** on the `TabBarView` body

**Why this works without conflicts:** Flutter's gesture arena disambiguates horizontal vs vertical drag gestures. When a user starts dragging, the system determines the primary axis of motion. If horizontal, the `TabBarView`'s `PageView` claims the gesture. If vertical, the `NestedScrollView`'s scroll controller claims it. This is Flutter's built-in gesture disambiguation — no custom `GestureDetector` or `RawGestureDetector` is needed.

### 2. Vertical Scroll Ownership

**`NestedScrollView`** owns vertical scroll coordination. It manages two layers:

| Layer | What it controls | Scroll controller |
|-------|-----------------|-------------------|
| **Outer** | Collapsible `SliverAppBar` + pinned `SliverPersistentHeader` (tab bar) | `NestedScrollView`'s outer controller |
| **Inner** | Product grid inside each tab | One inner controller per tab (auto-managed) |

**Why NestedScrollView:**
- ✅ **Single continuous scroll experience** — scrolling up first collapses the header, then scrolls the product list
- ✅ **Shared header state** — outer scroll (header collapse state) is shared across all tabs
- ✅ **Preserved scroll positions** — each tab's inner scroll position is preserved independently via `PageStorageKey`
- ✅ **No overlap issues** — `SliverOverlapAbsorber` + `SliverOverlapInjector` ensure the pinned tab bar doesn't overlap content

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

---

## 🌐 API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/auth/login` | Authentication (returns JWT) |
| `GET` | `/products` | All products (Tab 1) |
| `GET` | `/products/category/electronics` | Electronics (Tab 2) |
| `GET` | `/products/category/jewelery` | Jewelery (Tab 3) |
| `GET` | `/products/categories` | Product categories |
| `GET` | `/users/{id}` | User profile |

**API Base URL:** `https://fakestoreapi.com`

---

## 📦 Dependencies

### Production
- `flutter_bloc` ^9.1.0 — State management
- `equatable` ^2.0.7 — Value equality
- `http` ^1.3.0 — HTTP client
- `cached_network_image` ^3.4.1 — Image caching
- `shimmer` ^3.0.0 — Loading skeleton

### Development
- `flutter_test` — Testing framework
- `flutter_lints` ^5.0.0 — Linting rules

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 📸 Screenshots

| Login | Home | Profile |
|-------|------|---------|
| Authentication screen with pre-filled credentials | Product listing with collapsible header | User profile with address details |

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [FakeStore API](https://fakestoreapi.com/)
