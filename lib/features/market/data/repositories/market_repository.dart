import 'package:trade_app/features/market/data/datasources/cache_service.dart';
import 'package:trade_app/features/market/data/datasources/market_api_datasource.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/data/datasources/market_websocket_datasource.dart';

/// Market repository interface - abstracts data sources.
abstract class MarketRepository {
  /// Retrieves 24-hour ticker data from a REST API or cache.
  /// Returns cached data if valid, otherwise fetches from API.
  Future<List<Ticker>> fetchTickers({bool forceRefresh = false});

  /// Real-time update stream via WebSocket
  Stream<MiniTickerUpdate> get priceUpdates;

  /// Initiates WebSocket connection.
  void connectWebSocket();

  /// Clears all cached data
  Future<void> clearCache();
}

/// Combines API, WebSocket and Cache datasources.
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    MarketApiDatasource? apiDatasource,
    MarketWebSocketDatasource? wsDatasource,
    CacheService? cacheService,
  })  : _apiDatasource = apiDatasource ?? MarketApiDatasourceImpl(),
        _wsDatasource = wsDatasource ?? MarketWebSocketDatasourceImpl(),
        _cacheService = cacheService ?? CacheServiceImpl();

  final MarketApiDatasource _apiDatasource;
  final MarketWebSocketDatasource _wsDatasource;
  final CacheService _cacheService;

  /// Cache validity duration - 5 minutes
  static const _cacheMaxAge = Duration(minutes: 5);

  @override
  Future<List<Ticker>> fetchTickers({bool forceRefresh = false}) async {
    // If force refresh is not requested, try to load from cache first
    if (!forceRefresh) {
      final isCacheValid = await _cacheService.isCacheValid(_cacheMaxAge);
      
      if (isCacheValid) {
        final cachedTickers = await _cacheService.loadTickers();
        if (cachedTickers != null && cachedTickers.isNotEmpty) {
          // Return cached data immediately for better UX
          return cachedTickers;
        }
      }
    }

    // Fetch fresh data from API
    final tickers = await _apiDatasource.fetchTicker24hr();

    // Save to cache for future use
    await _cacheService.saveTickers(tickers);
    await _cacheService.saveLastUpdate(DateTime.now());

    return tickers;
  }

  @override
  Stream<MiniTickerUpdate> get priceUpdates => _wsDatasource.updates;

  @override
  void connectWebSocket() => _wsDatasource.connect();

  @override
  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  void dispose() {
    if (_apiDatasource is MarketApiDatasourceImpl) {
      (_apiDatasource).dispose();
    }
    if (_wsDatasource is MarketWebSocketDatasourceImpl) {
      (_wsDatasource).dispose();
    }
  }
}