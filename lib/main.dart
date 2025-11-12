import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'modules/intro/intro_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved language code or default to English
  final prefs = await SharedPreferences.getInstance();
  final savedCode = prefs.getString('language_code') ?? 'en';
  runApp(MyApp(initialLocale: Locale(savedCode)));
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) async {
    if (_locale == locale) return;
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property Booking App',
      theme: ThemeData(primarySwatch: Colors.blue),

      // ✅ Localization setup
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      locale: _locale,

      // 🔹 Fallback for Flutter widgets (Material/Cupertino) if Oromo
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale.languageCode == 'om') return const Locale('en'); // fallback
        for (var supported in supportedLocales) {
          if (supported.languageCode == _locale.languageCode) return supported;
        }
        return const Locale('en');
      },

      home: IntroPage(setLocale: setLocale),
    );
  }
}
