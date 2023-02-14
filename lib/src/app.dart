import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'sites/home/home.dart';
import 'sites/settings/settings_controller.dart';
import 'sites/settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            primaryColor: Colors.orange,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light().copyWith(
              secondary: Colors.pink,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey[700], // adjust to your liking
            scaffoldBackgroundColor: Colors.grey[800],
            // adjust to your liking
            textTheme: const TextTheme(
              bodyText1: TextStyle(
                color: Colors.white,
              ),
              bodyText2: TextStyle(
                color: Colors.white,
              ),
              subtitle1: TextStyle(
                color: Colors.white,
              ),
              subtitle2: TextStyle(
                color: Colors.white,
              ),
              headline6: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            colorScheme:
                const ColorScheme.dark().copyWith(secondary: Colors.pink),
          ),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  case Home.routeName:
                    return const Home();
                  default:
                    return const Home();
                }
              },
            );
          },
        );
      },
    );
  }
}
