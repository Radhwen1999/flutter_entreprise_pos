import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for app settings
abstract class SettingsLocalDataSource {
  /// Get biometric enabled setting
  Future<bool> getBiometricEnabled();

  /// Set biometric enabled setting
  Future<void> setBiometricEnabled(bool enabled);

  /// Get notification enabled setting
  Future<bool> getNotificationsEnabled();

  /// Set notification enabled setting
  Future<void> setNotificationsEnabled(bool enabled);

  /// Get dark mode setting
  Future<bool> getDarkModeEnabled();

  /// Set dark mode setting
  Future<void> setDarkModeEnabled(bool enabled);

  /// Get auto sync setting
  Future<bool> getAutoSyncEnabled();

  /// Set auto sync setting
  Future<void> setAutoSyncEnabled(bool enabled);

  /// Get sync interval in minutes
  Future<int> getSyncInterval();

  /// Set sync interval in minutes
  Future<void> setSyncInterval(int minutes);

  /// Get low stock threshold
  Future<int> getLowStockThreshold();

  /// Set low stock threshold
  Future<void> setLowStockThreshold(int threshold);

  /// Get currency code
  Future<String> getCurrencyCode();

  /// Set currency code
  Future<void> setCurrencyCode(String code);

  /// Clear all settings (reset to defaults)
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _boxName = 'settings_box';
  
  // Keys
  static const String _biometricKey = 'biometric_enabled';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _syncIntervalKey = 'sync_interval';
  static const String _lowStockKey = 'low_stock_threshold';
  static const String _currencyKey = 'currency_code';

  Box? _box;

  Future<Box> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<bool> getBiometricEnabled() async {
    final settingsBox = await box;
    return settingsBox.get(_biometricKey, defaultValue: false);
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    final settingsBox = await box;
    await settingsBox.put(_biometricKey, enabled);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    final settingsBox = await box;
    return settingsBox.get(_notificationsKey, defaultValue: true);
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final settingsBox = await box;
    await settingsBox.put(_notificationsKey, enabled);
  }

  @override
  Future<bool> getDarkModeEnabled() async {
    final settingsBox = await box;
    return settingsBox.get(_darkModeKey, defaultValue: true);
  }

  @override
  Future<void> setDarkModeEnabled(bool enabled) async {
    final settingsBox = await box;
    await settingsBox.put(_darkModeKey, enabled);
  }

  @override
  Future<bool> getAutoSyncEnabled() async {
    final settingsBox = await box;
    return settingsBox.get(_autoSyncKey, defaultValue: true);
  }

  @override
  Future<void> setAutoSyncEnabled(bool enabled) async {
    final settingsBox = await box;
    await settingsBox.put(_autoSyncKey, enabled);
  }

  @override
  Future<int> getSyncInterval() async {
    final settingsBox = await box;
    return settingsBox.get(_syncIntervalKey, defaultValue: 5);
  }

  @override
  Future<void> setSyncInterval(int minutes) async {
    final settingsBox = await box;
    await settingsBox.put(_syncIntervalKey, minutes);
  }

  @override
  Future<int> getLowStockThreshold() async {
    final settingsBox = await box;
    return settingsBox.get(_lowStockKey, defaultValue: 10);
  }

  @override
  Future<void> setLowStockThreshold(int threshold) async {
    final settingsBox = await box;
    await settingsBox.put(_lowStockKey, threshold);
  }

  @override
  Future<String> getCurrencyCode() async {
    final settingsBox = await box;
    return settingsBox.get(_currencyKey, defaultValue: 'USD');
  }

  @override
  Future<void> setCurrencyCode(String code) async {
    final settingsBox = await box;
    await settingsBox.put(_currencyKey, code);
  }

  @override
  Future<void> clearSettings() async {
    final settingsBox = await box;
    await settingsBox.clear();
  }
}
