import 'package:trade_app/features/market/data/datasources/market_api_datasource.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/data/datasources/market_websocket_datasource.dart';

/// Market repository interface - abstracts data sources.
abstract class MarketRepository {
  /// Retrieves 24-hour ticker data from a REST API.
  Future<List<Ticker>> fetchTickers();

  /// Real-time update stream via WebSocket
  Stream<MiniTickerUpdate> get priceUpdates;

  /// Initiates WebSocket connection.
  void connectWebSocket();
}

/// Combines API and WebSocket datasources.
class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({
    MarketApiDatasource? apiDatasource,
    MarketWebSocketDatasource? wsDatasource,
  })  : _apiDatasource = apiDatasource ?? MarketApiDatasourceImpl(),
        _wsDatasource = wsDatasource ?? MarketWebSocketDatasourceImpl();

  final MarketApiDatasource _apiDatasource;
  final MarketWebSocketDatasource _wsDatasource;

  @override
  Future<List<Ticker>> fetchTickers() => _apiDatasource.fetchTicker24hr();

  @override
  Stream<MiniTickerUpdate> get priceUpdates => _wsDatasource.updates;

  @override
  void connectWebSocket() => _wsDatasource.connect();

  void dispose() {
    if (_apiDatasource is MarketApiDatasourceImpl) {
      (_apiDatasource).dispose();
    }
    if (_wsDatasource is MarketWebSocketDatasourceImpl) {
      (_wsDatasource).dispose();
    }
  }
}