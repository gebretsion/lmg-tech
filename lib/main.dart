import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lmg_app/core/config/language_provider.dart';
import 'package:lmg_app/core/config/theme_provider.dart';
import 'package:lmg_app/core/localization/localization.dart';
import 'package:lmg_app/core/theme/app_theme.dart';
import 'package:lmg_app/modules/home/home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            key: UniqueKey(),
            debugShowCheckedModeBanner: false,
            title: 'Property Booking App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Set the locale directly from the provider.
            locale: languageProvider.currentLocale,

            // 1. Your app's delegate for your JSON files.
            // 2. Flutter's delegates for built-in widget translations.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Declare ONLY the locales that Flutter's delegates support.
            // This makes Flutter fall back to 'en' for its own widgets when the app locale is 'om'.
            supportedLocales: const [Locale('en', ''), Locale('am', '')],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
