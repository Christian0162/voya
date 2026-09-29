import 'package:equatable/equatable.dart';

/// A destination country available for interview practice.
///
/// New countries are added by extending [Country.all] — nothing else in the
/// app needs to change, which is the point of keeping this a plain data list
/// rather than a hardcoded enum switched on throughout the UI.
class Country extends Equatable {
  const Country({
    required this.code,
    required this.name,
    required this.flagEmoji,
    String? shortName,
  }) : shortName = shortName ?? name;

  final String code;
  final String name;
  final String flagEmoji;

  /// A shorter label for tight spaces (the setup wizard's country grid) —
  /// defaults to [name] when a country's full name already fits comfortably.
  /// "United States"/"United Kingdom" are the two long enough to warrant one.
  final String shortName;

  static const List<Country> all = [
    Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
    Country(code: 'CA', name: 'Canada', flagEmoji: '🇨🇦'),
    Country(code: 'US', name: 'United States', flagEmoji: '🇺🇸', shortName: 'US'),
    Country(code: 'GB', name: 'United Kingdom', flagEmoji: '🇬🇧', shortName: 'UK'),
    Country(code: 'JP', name: 'Japan', flagEmoji: '🇯🇵'),
    Country(code: 'KR', name: 'South Korea', flagEmoji: '🇰🇷'),
    Country(code: 'DE', name: 'Germany', flagEmoji: '🇩🇪'),
  ];

  @override
  List<Object?> get props => [code];
}
