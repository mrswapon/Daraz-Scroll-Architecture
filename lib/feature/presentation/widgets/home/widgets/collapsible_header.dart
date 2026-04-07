import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daraz_scroll_architecture/feature/presentation/blocs/product/product_bloc.dart';
import 'package:daraz_scroll_architecture/feature/presentation/blocs/product/product_event.dart';
import 'package:daraz_scroll_architecture/feature/presentation/blocs/product/product_state.dart';

class CollapsibleHeaderContent extends StatefulWidget {
  const CollapsibleHeaderContent({super.key});

  @override
  State<CollapsibleHeaderContent> createState() =>
      _CollapsibleHeaderContentState();
}

class _CollapsibleHeaderContentState extends State<CollapsibleHeaderContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final currentQuery = context.read<ProductBloc>().state.searchQuery;
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF85606), Color(0xFFE8450A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search bar — dispatches ProductSearchChanged on input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                width: 220,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<ProductBloc>().add(
                      ProductSearchChanged(query: query),
                    );
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search in Daraz',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    suffixIcon: BlocSelector<ProductBloc, ProductState, String>(
                      selector: (state) => state.searchQuery,
                      builder: (context, query) {
                        if (query.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ProductBloc>().add(
                              const ProductSearchChanged(query: ''),
                            );
                          },
                        );
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),
            // Promotional banner
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'MEGA SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Up to 70% OFF',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
