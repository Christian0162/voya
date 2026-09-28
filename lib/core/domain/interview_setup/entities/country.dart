import 'package:equatable/equatable.dart';

/// A destination country available for interview practice.
///
/// New countries are added by extending [Country.all] — nothing else in the
/// app needs to change, which is the point of keeping this a plain data list
/// rather than a hardcoded enum switched on throughout the UI.
class Country extends Equatable {
  const Country({required this.code, required this.name, required this.flagEmoji});

  final String code;
  final String name;
  final String flagEmoji;

  static const List<Country> all = [
    Country(code: 'AU', name: 'Australia', flagEmoji: '🇦🇺'),
    Country(code: 'CA', name: 'Canada', flagEmoji: '🇨🇦'),
    Country(code: 'US', name: 'United States', flagEmoji: '🇺🇸'),
    Country(code: 'GB', name: 'United Kingdom', flagEmoji: '🇬🇧'),
    Country(code: 'JP', name: 'Japan', flagEmoji: '🇯🇵'),
    Country(code: 'KR', name: 'South Korea', flagEmoji: '🇰🇷'),
    Country(code: 'DE', name: 'Germany', flagEmoji: '🇩🇪'),
  ];

  @override
  List<Object?> get props => [code];
}
