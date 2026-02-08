/// Price and volume formatting tools
abstract final class FormatUtils {
  FormatUtils._();

  static String formatPrice(String price) {
    final val = double.tryParse(price);
    if (val == null) return price;
    if (val >= 1000) return val.toStringAsFixed(2);
    if (val >= 1) return val.toStringAsFixed(4);
    if (val >= 0.0001) return val.toStringAsFixed(6);
    return val.toStringAsFixed(8);
  }

  static String formatVolume(String vol) {
    final val = double.tryParse(vol);
    if (val == null) return vol;
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(2)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(2)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(2)}K';
    return val.toStringAsFixed(2);
  }
}
