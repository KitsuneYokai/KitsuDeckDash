import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(key));
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  getKitsuDeck() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString("kitsuDeck"));
  }

  setKitsuDeck(
    hostname,
    ip,
    pin,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "kitsuDeck",
        json.encode({
          "hostname": hostname,
          "ip": ip,
          "pin": pin,
        }));
  }

  removeKitsuDeck() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("kitsuDeck");
  }
}
