import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kitsu_deck_dash/src/sites/ui.dart';
import 'package:provider/provider.dart';

import 'classes/kitsu_deck/device.dart';
import 'classes/websocket/connector.dart';

/// The Widget that configures your application.
class KitsuDeckDash extends StatefulWidget {
  const KitsuDeckDash({
    super.key,
  });

  @override
  KitsuDeckDashState createState() => KitsuDeckDashState();
}

class KitsuDeckDashState extends State<KitsuDeckDash> {
  @override
  Widget build(BuildContext context) {
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
        scaffoldBackgroundColor: Colors.grey[300],
        colorScheme: const ColorScheme.light().copyWith(
          secondary: Colors.pink,
        ),
      ),
      darkTheme: ThemeData(
        // text field
        inputDecorationTheme: InputDecorationTheme(
          // background color
          fillColor: Colors.grey[800]!.withOpacity(0.4),
          filled: true,
          // change border
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[700]!, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.grey[200]!.withOpacity(0.4), width: 3),
          ),
        ),
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.grey,
          selectedIconTheme: IconThemeData(color: Colors.white),
          selectedLabelTextStyle: TextStyle(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.white),
          unselectedLabelTextStyle: TextStyle(color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
          ),
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey[700], // adjust to your liking
        scaffoldBackgroundColor: Colors.grey[800],
        // adjust to your liking
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.pink),
      ),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(builder: (BuildContext context) {
          return const MainView();
        });
      },
    );
  }
}
