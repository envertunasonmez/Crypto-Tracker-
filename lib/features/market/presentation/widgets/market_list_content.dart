import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trade_app/core/widgets/empty_view.dart';
import 'package:trade_app/core/widgets/error_view.dart';
import 'package:trade_app/core/widgets/loading_view.dart';
import 'package:trade_app/features/market/presentation/providers/market_provider.dart';
import 'package:trade_app/features/market/presentation/widgets/market_list_item.dart';
import 'package:trade_app/features/market/presentation/screens/market_detail_screen.dart' as detail;

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
          case MarketState.loading:
            return const SliverFillRemaining(
              child: LoadingView(message: 'Markets are loading...'),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => detail.MarketDetailScreen(symbol: ticker.symbol),
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
