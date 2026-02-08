import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/market_provider.dart';
import '../widgets/market_details_card.dart';
import '../widgets/market_price_card.dart';

class MarketDetailScreen extends StatelessWidget {
  final String symbol;

  const MarketDetailScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symbol),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<MarketProvider>(
        builder: (context, provider, _) {
          final ticker = provider.getTicker(symbol);

          if (ticker == null) {
            return const Center(
              child: Text('Market not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MarketPriceCard(ticker: ticker),
                const SizedBox(height: 24),
                MarketDetailsCard(ticker: ticker),
              ],
            ),
          );
        },
      ),
    );
  }
}
