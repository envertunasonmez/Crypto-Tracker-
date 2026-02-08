import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:trade_app/features/market/data/datasources/market_api_datasource.dart';
import 'package:trade_app/features/market/data/datasources/market_websocket_datasource.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/data/repositories/market_repository.dart';

enum MarketState { initial, loading, success, error }

class MarketProvider with ChangeNotifier {
  MarketProvider({MarketRepository? repository})
    : _repository = repository ?? MarketRepositoryImpl();

  final MarketRepository _repository;
  StreamSubscription<MiniTickerUpdate>? _wsSubscription;

  MarketState _state = MarketState.initial;
  List<Ticker> _tickers = [];
  String _searchQuery = '';
  String? _errorMessage;

  // WebSocket throttle - Up to 1 notify every 100ms
  static const _throttleDuration = Duration(milliseconds: 100);
  DateTime? _lastNotify;
  bool _pendingNotify = false;

  MarketState get state => _state;
  List<Ticker> get tickers => List.unmodifiable(_tickers);
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  List<Ticker> get filteredTickers {
    if (_searchQuery.isEmpty) return _tickers;
    final query = _searchQuery.toUpperCase();
    return _tickers.where((t) => t.symbol.contains(query)).toList();
  }

  Ticker? getTicker(String symbol) {
    for (var i = 0; i < _tickers.length; i++) {
      if (_tickers[i].symbol == symbol) return _tickers[i];
    }
    return null;
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadMarkets() async {
    _state = MarketState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tickers = await _repository.fetchTickers();
      _state = MarketState.success;
      _connectWebSocket();
    } on MarketApiException catch (e) {
      _state = MarketState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = MarketState.error;
      _errorMessage = 'Unexpected error: $e';
    }
    notifyListeners();
  }

  void _connectWebSocket() {
    _wsSubscription?.cancel();
    _repository.connectWebSocket();
    _wsSubscription = _repository.priceUpdates.listen(
      _onPriceUpdate,
      onError: (_) {},
    );
  }

  void _onPriceUpdate(MiniTickerUpdate update) {
    final index = _tickers.indexWhere((t) => t.symbol == update.symbol);
    if (index >= 0) {
      _tickers[index] = _tickers[index].copyWithPrice(
        lastPrice: update.lastPrice,
      );
      _throttledNotify();
    }
  }

  void _throttledNotify() {
    final now = DateTime.now();
    if (_lastNotify == null ||
        now.difference(_lastNotify!) >= _throttleDuration) {
      _lastNotify = now;
      _pendingNotify = false;
      notifyListeners();
    } else if (!_pendingNotify) {
      _pendingNotify = true;
      Future.delayed(_throttleDuration, () {
        if (_pendingNotify) {
          _pendingNotify = false;
          _lastNotify = DateTime.now();
          notifyListeners();
        }
      });
    }
  }

  void retry() => loadMarkets();

  @override
  void dispose() {
    _wsSubscription?.cancel();
    if (_repository is MarketRepositoryImpl) {
      (_repository).dispose();
    }
    super.dispose();
  }
}
