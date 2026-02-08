import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:trade_app/core/config/api_config.dart';
import 'package:trade_app/features/market/data/models/ticker.dart';

/// REST API datasource for market data
abstract class MarketApiDatasource {
  Future<List<Ticker>> fetchTicker24hr();
}

class MarketApiDatasourceImpl implements MarketApiDatasource {
  MarketApiDatasourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<List<Ticker>> fetchTicker24hr() async {
    final response = await _client.get(Uri.parse(ApiConfig.ticker24hrUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
      return jsonList
          .map((j) => Ticker.fromJson(j as Map<String, dynamic>))
          .where((t) =>
              t.symbol.isNotEmpty && double.tryParse(t.lastPrice) != null)
          .toList();
    } else {
      throw MarketApiException(
        'API error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}

class MarketApiException implements Exception {
  final String message;
  final int? statusCode;

  MarketApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
