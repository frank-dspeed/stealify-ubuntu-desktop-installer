import 'package:flutter/material.dart';
import 'package:gsettings/gsettings.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Provides access to application-wide settings.
class Settings extends ChangeNotifier {
  /// Creates an app settings instance using the given GSettings as a backend
  /// for storing the settings.
  Settings(this._gsettings);

  final GSettings _gsettings;

  /// Returns settings for the given [context].
  ///
  /// Note: pass `listen: false` when applying settings without listening for
  /// changes (the entire app will be rebuilt anyway).
  static Settings of(BuildContext context, {bool listen = true}) {
    return Provider.of<Settings>(context, listen: listen);
  }

  /// The current application theme.
  ThemeMode get theme => _theme;
  ThemeMode _theme = ThemeMode.system;

  /// Applies a theme matching the given [brightness].
  void applyTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        _theme = ThemeMode.dark;
        _gsettings.setValue('gtk-theme', 'Yaru-dark');
        break;
      case Brightness.light:
        _theme = ThemeMode.light;
        _gsettings.setValue('gtk-theme', 'Yaru');
        break;
    }
    notifyListeners();
    _gsettings.sync();
  }

  /// The current application locale.
  Locale get locale => _locale;
  Locale _locale = Locale(Intl.shortLocale(Intl.systemLocale));

  /// Applies the given [locale].
  void applyLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _gsettings.dispose();
  }
}