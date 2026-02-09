import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:trade_app/features/market/data/datasources/market_api_datasource.dart';
import 'package:trade_app/features/market/data/datasources/market_websocket_datasource.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';
import 'package:trade_app/features/market/data/repositories/market_repository.dart';

enum MarketState { initial, loading, success, error, loadingFromCache }

class MarketProvider with ChangeNotifier {
  MarketProvider({MarketRepository? repository})
    : _repository = repository ?? MarketRepositoryImpl();

  final MarketRepository _repository;
  StreamSubscription<MiniTickerUpdate>? _wsSubscription;

  MarketState _state = MarketState.initial;
  List<Ticker> _tickers = [];
  String _searchQuery = '';
  String? _errorMessage;
  bool _isLoadedFromCache = false;

  // WebSocket throttle - Up to 1 notify every 100ms
  static const _throttleDuration = Duration(milliseconds: 100);
  DateTime? _lastNotify;
  bool _pendingNotify = false;

  MarketState get state => _state;
  List<Ticker> get tickers => List.unmodifiable(_tickers);
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoadedFromCache => _isLoadedFromCache;

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

  /// Load markets with cache-first strategy
  /// 1. Try to load from cache (instant)
  /// 2. Then fetch fresh data from API in background
  Future<void> loadMarkets({bool forceRefresh = false}) async {
    _errorMessage = null;

    if (forceRefresh) {
      // Force refresh: show loading state
      _state = MarketState.loading;
      _isLoadedFromCache = false;
      notifyListeners();
    } else {
      // Try cache first
      try {
        _state = MarketState.loadingFromCache;
        notifyListeners();

        final cachedData = await _repository.fetchTickers();

        if (cachedData.isNotEmpty) {
          _tickers = cachedData;
          _isLoadedFromCache = true;
          _state = MarketState.success;
          notifyListeners();

          // Connect WebSocket for real-time updates
          _connectWebSocket();

          // Then fetch fresh data in background
          _fetchFreshDataInBackground();
          return;
        }
      } catch (e) {
        // Cache failed, continue to API fetch
      }

      // No cache available, show loading
      _state = MarketState.loading;
      _isLoadedFromCache = false;
      notifyListeners();
    }

    // Fetch from API
    try {
      _tickers = await _repository.fetchTickers(forceRefresh: true);
      _state = MarketState.success;
      _isLoadedFromCache = false;
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

  /// Fetch fresh data in background (silently update)
  Future<void> _fetchFreshDataInBackground() async {
    try {
      final freshData = await _repository.fetchTickers(forceRefresh: true);
      _tickers = freshData;
      _isLoadedFromCache = false;
      notifyListeners();
    } catch (e) {
      // Silent fail - user already has cached data
    }
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

  /// Clear cache and reload
  Future<void> clearCacheAndReload() async {
    await _repository.clearCache();
    await loadMarkets(forceRefresh: true);
  }

  void retry() => loadMarkets(forceRefresh: true);

  @override
  void dispose() {
    _wsSubscription?.cancel();
    if (_repository is MarketRepositoryImpl) {
      (_repository).dispose();
    }
    super.dispose();
  }
}
