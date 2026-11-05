/// Formats a price in Ethiopian birr, e.g. "ETB 450" or "ETB 450.50".
String formatPrice(num amount) {
  final text = amount == amount.truncate()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  return 'ETB $text';
}