import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:trade_app/features/market/data/models/ticker.dart';

/// Cache service for persistent data storage
abstract class CacheService {
  /// Saves ticker list to cache
  Future<void> saveTickers(List<Ticker> tickers);

  /// Loads cached ticker list
  Future<List<Ticker>?> loadTickers();

  /// Saves last update timestamp
  Future<void> saveLastUpdate(DateTime timestamp);

  /// Gets last update timestamp
  Future<DateTime?> getLastUpdate();

  /// Checks if cache is still valid (within duration)
  Future<bool> isCacheValid(Duration maxAge);

  /// Clears all cached data
  Future<void> clearCache();
}

class CacheServiceImpl implements CacheService {
  static const String _tickersKey = 'cached_tickers';
  static const String _timestampKey = 'last_update_timestamp';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> saveTickers(List<Ticker> tickers) async {
    try {
      final prefs = await _preferences;
      final jsonList = tickers.map((t) => _tickerToJson(t)).toList();
      final encoded = json.encode(jsonList);
      await prefs.setString(_tickersKey, encoded);
    } catch (e) {
      // Silent fail - cache is not critical
    }
  }

  @override
  Future<List<Ticker>?> loadTickers() async {
    try {
      final prefs = await _preferences;
      final encoded = prefs.getString(_tickersKey);
      if (encoded == null) return null;

      final List<dynamic> jsonList = json.decode(encoded) as List<dynamic>;
      return jsonList
          .map((j) => _tickerFromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLastUpdate(DateTime timestamp) async {
    try {
      final prefs = await _preferences;
      await prefs.setInt(_timestampKey, timestamp.millisecondsSinceEpoch);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<DateTime?> getLastUpdate() async {
    try {
      final prefs = await _preferences;
      final timestamp = prefs.getInt(_timestampKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isCacheValid(Duration maxAge) async {
    final lastUpdate = await getLastUpdate();
    if (lastUpdate == null) return false;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference <= maxAge;
  }

  @override
  Future<void> clearCache() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_tickersKey);
      await prefs.remove(_timestampKey);
    } catch (e) {
      // Silent fail
    }
  }

  // Helper methods for serialization
  Map<String, dynamic> _tickerToJson(Ticker ticker) {
    return {
      'symbol': ticker.symbol,
      'priceChange': ticker.priceChange,
      'priceChangePercent': ticker.priceChangePercent,
      'lastPrice': ticker.lastPrice,
      'highPrice': ticker.highPrice,
      'lowPrice': ticker.lowPrice,
      'volume': ticker.volume,
      'bidPrice': ticker.bidPrice,
      'askPrice': ticker.askPrice,
    };
  }

  Ticker _tickerFromJson(Map<String, dynamic> json) {
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
}