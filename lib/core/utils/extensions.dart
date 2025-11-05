import 'package:flutter/material.dart';
import 'formatters.dart';

/// Extension methods for String
extension StringExtension on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    return RegExp(
            r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$')
        .hasMatch(this);
  }

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalize first letter of each word
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty ? word.capitalize : '')
        .join(' ');
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Check if string is empty or contains only whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Parse to int safely
  int? get toIntOrNull => int.tryParse(this);

  /// Parse to double safely
  double? get toDoubleOrNull => double.tryParse(this);
}

/// Extension methods for DateTime
extension DateTimeExtension on DateTime {
  /// Format date for display
  String get formatted => Formatters.formatDate(this);

  /// Format date time for display
  String get formattedDateTime => Formatters.formatDateTime(this);

  /// Format time for display
  String get formattedTime => Formatters.formatTime(this);

  /// Format for API
  String get apiFormat => Formatters.formatApiDate(this);

  /// Format relative time
  String get relativeTime => Formatters.formatRelativeTime(this);

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get date only (without time)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Extension methods for BuildContext
extension ContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get width => screenSize.width;

  /// Get screen height
  double get height => screenSize.height;

  /// Check if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Get safe area padding
  EdgeInsets get padding => mediaQuery.padding;

  /// Get view insets
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Show snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  /// Navigate to route
  Future<T?> pushPage<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Replace current route
  Future<T?> pushReplacementPage<T, TO>(Widget page, {TO? result}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
      result: result,
    );
  }

  /// Pop route
  void popPage<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Pop until first route
  void popToRoot() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

/// Extension methods for double
extension DoubleExtension on double {
  /// Format as currency
  String get currency => Formatters.formatCurrency(this);

  /// Format as rating
  String get rating => Formatters.formatRating(this);
}

/// Extension methods for int
extension IntExtension on int {
  /// Format with commas
  String get formatted => Formatters.formatNumber(this);

  /// Format file size
  String get fileSize => Formatters.formatFileSize(this);
}

/// Extension methods for Duration
extension DurationExtension on Duration {
  /// Format duration
  String get formatted => Formatters.formatDuration(this);
}

/// Extension methods for List
extension ListExtension<T> on List<T> {
  /// Safely get element at index
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Check if list is empty or null
  bool get isEmptyOrNull => isEmpty;

  /// Get first element or null
  T? get firstOrNull => isNotEmpty ? first : null;

  /// Get last element or null
  T? get lastOrNull => isNotEmpty ? last : null;
}
