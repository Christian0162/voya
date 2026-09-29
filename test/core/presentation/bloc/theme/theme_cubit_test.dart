import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voya/core/presentation/bloc/theme/theme_cubit.dart';

void main() {
  test('defaults to ThemeMode.system when nothing is persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final cubit = ThemeCubit(prefs);

    expect(cubit.state, ThemeMode.system);
  });

  test('loads a persisted theme mode on construction', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final prefs = await SharedPreferences.getInstance();

    final cubit = ThemeCubit(prefs);

    expect(cubit.state, ThemeMode.dark);
  });

  group('setMode', () {
    late SharedPreferences prefs;

    blocTest<ThemeCubit, ThemeMode>(
      'emits and persists the new mode',
      setUp: () async {
        SharedPreferences.setMockInitialValues({});
        prefs = await SharedPreferences.getInstance();
      },
      build: () => ThemeCubit(prefs),
      act: (cubit) => cubit.setMode(ThemeMode.light),
      expect: () => [ThemeMode.light],
      verify: (_) {
        expect(prefs.getString('theme_mode'), 'light');
      },
    );
  });
}
