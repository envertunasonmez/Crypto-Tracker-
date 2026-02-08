/// API ve WebSocket base URL yapılandırması.
/// Tüm endpoint'ler bu dosyadan yönetilir.
abstract final class ApiConfig {
  ApiConfig._();

  /// Binance REST API base URL
  static const String restBaseUrl = 'https://api.binance.com/api/v3';

  /// Binance WebSocket stream base URL
  static const String wsBaseUrl = 'wss://stream.binance.com:9443/ws';

  /// 24 hour ticker endpoint path
  static const String ticker24hrPath = '/ticker/24hr';

  /// Mini ticker stream for all symbols
  static const String miniTickerStream = '!miniTicker@arr';

  /// Full REST endpoint URL
  static String get ticker24hrUrl => '$restBaseUrl$ticker24hrPath';

  /// Full WebSocket URL
  static String get miniTickerWsUrl => '$wsBaseUrl/$miniTickerStream';
}
