import 'package:intl/intl.dart';

/// Currency and number formatting utilities
class CurrencyFormatter {
  CurrencyFormatter._();

  // ═══════════════════════════════════════════════════════════════
  // CURRENCY FORMATTERS
  // ═══════════════════════════════════════════════════════════════
  
  static final NumberFormat _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _usdCompact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final NumberFormat _noSymbol = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  // ═══════════════════════════════════════════════════════════════
  // NUMBER FORMATTERS
  // ═══════════════════════════════════════════════════════════════
  
  static final NumberFormat _decimal = NumberFormat.decimalPattern('en_US');
  static final NumberFormat _compact = NumberFormat.compact(locale: 'en_US');
  static final NumberFormat _percent = NumberFormat.percentPattern('en_US');

  // ═══════════════════════════════════════════════════════════════
  // FORMAT METHODS
  // ═══════════════════════════════════════════════════════════════
  
  /// Format as USD currency (e.g., $1,234.56)
  static String formatUSD(double amount) => _usdFormat.format(amount);

  /// Format as compact USD (e.g., $1.2K)
  static String formatUSDCompact(double amount) => _usdCompact.format(amount);

  /// Format number without currency symbol (e.g., 1,234.56)
  static String formatNumber(double amount) => _noSymbol.format(amount);

  /// Format as decimal with thousand separators (e.g., 1,234)
  static String formatDecimal(num number) => _decimal.format(number);

  /// Format as compact number (e.g., 1.2K)
  static String formatCompact(num number) => _compact.format(number);

  /// Format as percentage (e.g., 12.5%)
  static String formatPercent(double value) => _percent.format(value);

  // ═══════════════════════════════════════════════════════════════
  // CUSTOM FORMATS
  // ═══════════════════════════════════════════════════════════════
  
  /// Format with custom currency symbol
  static String formatWithSymbol(double amount, String symbol) {
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  /// Format with K/M/B suffix for large numbers
  static String formatShorthand(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  /// Format as price with optional cents
  static String formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return '\$${price.toInt()}';
    }
    return formatUSD(price);
  }

  /// Format change with + or - prefix
  static String formatChange(double change, {bool showSign = true}) {
    final formatted = formatUSD(change.abs());
    if (!showSign) return formatted;
    return change >= 0 ? '+$formatted' : '-$formatted';
  }

  /// Format percentage change with + or - prefix
  static String formatPercentChange(double change) {
    final formatted = '${change.abs().toStringAsFixed(1)}%';
    return change >= 0 ? '+$formatted' : '-$formatted';
  }
}
