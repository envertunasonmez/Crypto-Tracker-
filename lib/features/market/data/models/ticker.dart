/// Binance 24hr ticker model for REST API response
class Ticker {
  final String symbol;
  final String priceChange;
  final String priceChangePercent;
  final String lastPrice;
  final String highPrice;
  final String lowPrice;
  final String volume;
  final String bidPrice;
  final String askPrice;

  const Ticker({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.lastPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.bidPrice,
    required this.askPrice,
  });

  factory Ticker.fromJson(Map<String, dynamic> json) {
    return Ticker(
      symbol: json['symbol'] as String? ?? '',
      priceChange: json['priceChange'] as String? ?? '0',
      priceChangePercent: json['priceChangePercent'] as String? ?? '0',
      lastPrice: json['lastPrice'] as String? ?? '0',
      highPrice: json['highPrice'] as String? ?? '0',
      lowPrice: json['lowPrice'] as String? ?? '0',
      volume: json['volume'] as String? ?? '0',
      bidPrice: json['bidPrice'] as String? ?? '0',
      askPrice: json['askPrice'] as String? ?? '0',
    );
  }

  /// Create a copy with updated WebSocket price data
  Ticker copyWithPrice({
    String? lastPrice,
    String? priceChangePercent,
  }) {
    return Ticker(
      symbol: symbol,
      priceChange: priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      lastPrice: lastPrice ?? this.lastPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      bidPrice: bidPrice,
      askPrice: askPrice,
    );
  }

  bool get isPositive => (double.tryParse(priceChangePercent) ?? 0) >= 0;
}
