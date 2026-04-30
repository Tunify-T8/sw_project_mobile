import 'package:country_picker/country_picker.dart';

class CountryCodeUtils {
  CountryCodeUtils._();

  static final CountryService _countryService = CountryService();

  static String? normalizeCountryCode(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final upper = trimmed.toUpperCase();
    final byCode = _countryService.findByCode(upper);
    if (byCode != null) {
      return byCode.countryCode;
    }

    final exactByName = _countryService.findByName(trimmed);
    if (exactByName != null) {
      return exactByName.countryCode;
    }

    final lower = trimmed.toLowerCase();
    for (final country in _countryService.getAll()) {
      if (country.name.toLowerCase() == lower ||
          country.displayNameNoCountryCode.toLowerCase() == lower ||
          country.displayName.toLowerCase() == lower) {
        return country.countryCode;
      }
    }

    return null;
  }

  static List<String> parseCountryCodes(String raw) {
    final seen = <String>{};
    final codes = <String>[];

    for (final part in raw.split(',')) {
      final code = normalizeCountryCode(part);
      if (code != null && seen.add(code)) {
        codes.add(code);
      }
    }

    return codes;
  }

  static Country? countryForCode(String code) {
    return _countryService.findByCode(code);
  }

  static String labelForCode(String code) {
    final country = countryForCode(code);
    if (country == null) return code.toUpperCase();
    return '${country.flagEmoji} ${country.name}';
  }
}
