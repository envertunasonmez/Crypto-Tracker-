import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:trade_app/core/config/api_config.dart';

/// WebSocket payload for mini ticker (Binance !miniTicker@arr)
class MiniTickerUpdate {
  final String symbol;
  final String lastPrice;

  const MiniTickerUpdate({required this.symbol, required this.lastPrice});

  factory MiniTickerUpdate.fromJson(Map<String, dynamic> json) {
    return MiniTickerUpdate(
      symbol: json['s'] as String? ?? '',
      lastPrice: json['c'] as String? ?? '0',
    );
  }
}

/// WebSocket datasource for real-time price updates
abstract class MarketWebSocketDatasource {
  Stream<MiniTickerUpdate> get updates;
  bool get isConnected;
  void connect();
  void disconnect();
}

class MarketWebSocketDatasourceImpl implements MarketWebSocketDatasource {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  final StreamController<MiniTickerUpdate> _controller =
      StreamController<MiniTickerUpdate>.broadcast();

  @override
  Stream<MiniTickerUpdate> get updates => _controller.stream;

  @override
  bool get isConnected => _channel != null;

  @override
  void connect() {
    if (_channel != null) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(ApiConfig.miniTickerWsUrl));
      _subscription = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      _controller.addError(MarketWebSocketException('connection error: $e'));
    }
  }

  void _onData(dynamic data) {
    try {
      final list = json.decode(data) as List<dynamic>;
      for (final item in list) {
        final update = MiniTickerUpdate.fromJson(item as Map<String, dynamic>);
        if (update.symbol.isNotEmpty) {
          _controller.add(update);
        }
      }
    } catch (_) {}
  }

  void _onError(dynamic error) {
    _controller.addError(MarketWebSocketException('WebSocket error: $error'));
  }

  void _onDone() {
    _channel = null;
    _subscription = null;
  }

  @override
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}

class MarketWebSocketException implements Exception {
  final String message;

  MarketWebSocketException(this.message);

  @override
  String toString() => message;
}
