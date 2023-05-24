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
    // initialize the KitsuDeck class with the shared preferences settings
    final kitsuDeck = Provider.of<KitsuDeck>(context);
    final websocket = Provider.of<DeckWebsocket>(context);

    return FutureBuilder(
        future: kitsuDeck.initKitsuDeckSettings(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (kitsuDeck.hostname != null.toString() &&
                kitsuDeck.ip != null.toString()) {
              websocket.initConnection("ws://${kitsuDeck.ip!}/ws");
            }
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
                colorScheme:
                    const ColorScheme.dark().copyWith(secondary: Colors.pink),
              ),
              onGenerateRoute: (RouteSettings routeSettings) {
                return MaterialPageRoute<void>(builder: (BuildContext context) {
                  return const MainView();
                });
              },
            );
          }
          return CircularProgressIndicator();
        });
  }
}

class NoTransitionBuilder extends PageTransitionsBuilder {
  const NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
