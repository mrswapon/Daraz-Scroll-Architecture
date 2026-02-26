import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/auth/auth_bloc.dart';
import '../../controllers/auth/auth_state.dart';
import '../../controllers/product/product_bloc.dart';
import '../../controllers/product/product_event.dart';
import '../../controllers/product/product_state.dart';
import '../../models/product_model.dart';
import 'widgets/collapsible_header.dart';
import 'widgets/product_card.dart';
import 'widgets/sticky_tab_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['All', 'Electronics', 'Jewelery'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // Load products on first build.
    context.read<ProductBloc>().add(const ProductsLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //======================== scroll to each tab's scrollable child. <=====================
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            //======================> Collapsible banner/search area. <=====================
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: false,
              backgroundColor: const Color(0xFFF85606),
              flexibleSpace: const FlexibleSpaceBar(
                background: CollapsibleHeaderContent(),
              ),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            //============== Sticky tab bar pinned so it remains visible after header collapses. <==========
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFF85606),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFFF85606),
                    indicatorWeight: 3,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        //========================> TabBarView handles horizontal swipe between tabs. <======================
        body: TabBarView(
          controller: _tabController,
          children: [
            _TabContent(
              tabIndex: 0,
              selector: (state) => state.filteredAllProducts,
            ),
            _TabContent(
              tabIndex: 1,
              selector: (state) => state.filteredElectronics,
            ),
            _TabContent(
              tabIndex: 2,
              selector: (state) => state.filteredJewelery,
            ),
          ],
        ),
      ),
    );
  }
}

//=======================> A single tab's content: a refreshable product grid. <===========================
class _TabContent extends StatefulWidget {
  final int tabIndex;
  final List<ProductModel> Function(ProductState) selector;

  const _TabContent({
    required this.tabIndex,
    required this.selector,
  });

  @override
  State<_TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<_TabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(const ProductsRefreshRequested());
    await context.read<ProductBloc>().stream.firstWhere(
          (state) => state.status != ProductStatus.loading,
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final products = widget.selector(state);
        if (state.status == ProductStatus.loading && products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductStatus.error && products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'Something went wrong'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<ProductBloc>()
                      .add(const ProductsLoadRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        //==============================> Empty search results <======================
        if (state.status == ProductStatus.loaded && products.isEmpty) {
          return Builder(
            builder: (context) {
              return CustomScrollView(
                key: PageStorageKey<int>(widget.tabIndex),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No products found for "${state.searchQuery}"',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
        //=========================> RefreshIndicator wraps a CustomScrollView that <=======================
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: Builder(
            builder: (context) {
              return CustomScrollView(
                key: PageStorageKey<int>(widget.tabIndex),
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  //====================> Product grid <====================
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(product: products[index]),
                        childCount: products.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
