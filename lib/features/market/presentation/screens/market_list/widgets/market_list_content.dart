import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trade_app/core/widgets/empty_view.dart';
import 'package:trade_app/core/widgets/error_view.dart';
import 'package:trade_app/core/widgets/loading_view.dart';
import 'package:trade_app/features/market/presentation/providers/market_provider.dart';
import 'package:trade_app/features/market/presentation/screens/market_list/widgets/market_list_item.dart';
import 'package:trade_app/features/market/presentation/screens/market_list/widgets/shimmer_loading.dart';
import 'package:trade_app/features/market/presentation/screens/market_detail/market_detail_screen.dart' as detail;

class MarketListContent extends StatelessWidget {
  final int displayedCount;
  final int initialLoadCount;

  const MarketListContent({
    super.key,
    required this.displayedCount,
    required this.initialLoadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketProvider>(
      builder: (context, provider, _) {
        switch (provider.state) {
          case MarketState.loadingFromCache:
            return const SliverFillRemaining(
              child: LoadingView(message: 'Loading markets...'),
            );

          case MarketState.loading:
            return const SliverFillRemaining(
              child: ShimmerLoading(),
            );

          case MarketState.error:
            return SliverFillRemaining(
              child: ErrorView(
                message: provider.errorMessage ?? 'Unknown error',
                onRetry: provider.retry,
              ),
            );

          case MarketState.success:
          case MarketState.initial:
            final tickers = provider.filteredTickers;
            final itemCount = tickers.length;
            final countToShow = itemCount <= initialLoadCount
                ? itemCount
                : (displayedCount > itemCount ? itemCount : displayedCount);

            if (tickers.isEmpty) {
              return SliverFillRemaining(
                child: EmptyView(
                  message: provider.searchQuery.isEmpty ? 'No data found' : 'No search results',
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ticker = tickers[index];
                    return MarketListItem(
                      key: ValueKey(ticker.symbol),
                      ticker: ticker,
                      index: index,
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              detail.MarketDetailScreen(symbol: ticker.symbol),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;

                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(curve: curve),
                            );

                            var offsetAnimation = animation.drive(tween);
                            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: const Interval(0.0, 0.5),
                              ),
                            );

                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: fadeAnimation,
                                child: child,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      ),
                    );
                  },
                  childCount: countToShow,
                  addAutomaticKeepAlives: false,
                ),
              ),
            );
        }
      },
    );
  }
}