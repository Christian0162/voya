import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's appearance choice (System/Light/Dark) so it survives
/// an app restart. Reuses Flutter's own [ThemeMode] enum directly as the
/// cubit's state rather than inventing a parallel one — `.name` round-trips
/// cleanly through SharedPreferences ('system'/'light'/'dark').
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  static ThemeMode _load(SharedPreferences prefs) {
    final stored = prefs.getString(_key);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_key, mode.name);
  }
}
