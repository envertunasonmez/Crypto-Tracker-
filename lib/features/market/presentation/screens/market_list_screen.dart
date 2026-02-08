import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trade_app/features/market/presentation/providers/market_provider.dart';
import 'package:trade_app/features/market/presentation/widgets/market_list_content.dart';
import 'package:trade_app/features/market/presentation/widgets/market_search_header.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _initialLoadCount = 30;
  static const _loadMoreCount = 30;
  int _displayedCount = _initialLoadCount;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().loadMarkets();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      setState(() => _displayedCount += _loadMoreCount);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<MarketProvider>().loadMarkets(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: MarketSearchHeader(
                  searchController: _searchController,
                  onSearchChanged: (v) => context.read<MarketProvider>().setSearchQuery(v),
                  onClear: () {
                    _searchController.clear();
                    context.read<MarketProvider>().setSearchQuery('');
                  },
                ),
              ),
              MarketListContent(
                displayedCount: _displayedCount,
                initialLoadCount: _initialLoadCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
