import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [
    Locale('en', ''),
    Locale('am', ''),
    Locale('om', ''),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)
        ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String languageCode = locale.languageCode;
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      // fallback to English
      if (languageCode != 'en') return await _loadFallbackTranslations();
      _localizedStrings = {};
      return false;
    }
  }

  Future<bool> _loadFallbackTranslations() async {
    try {
      String fallbackJsonString = await rootBundle.loadString('assets/lang/en.json');
      Map<String, dynamic> fallbackJsonMap = json.decode(fallbackJsonString);
      _localizedStrings = fallbackJsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      _localizedStrings = {};
      return false;
    }
  }

  String translate(String key) => _localizedStrings[key] ?? key;

  bool hasKey(String key) => _localizedStrings.containsKey(key);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am', 'om'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
