import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../main.dart';
import '../classes/kitsu_deck/device.dart';

getCurrentIP() async {
  final interfaces = await NetworkInterface.list();
  for (final interface in interfaces) {
    if (interface.name.toLowerCase().contains('eth') ||
        interface.name.toLowerCase().contains('en') ||
        interface.name.toLowerCase().contains('wi-fi')) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return (addr.address.toString());
        }
      }
    }
    return false;
  }
}

kitsuDeckValidationCheck(String address) async {
  final url = Uri.parse('http://$address');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var responseData = {
        "hostname": data["hostname"],
        "ip": data["ip"],
        "protected": data["protected"],
      };
      return responseData;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<List<Map>> getKitsuDeckHostname() async {
  final ipList = <String>[];
  final returnList = <Map>[];
  final currentIP = await getCurrentIP();
  if (currentIP == null) {
    return returnList;
  }
  final baseIP = currentIP.substring(0, currentIP.lastIndexOf('.') + 1);
  final futures = <Future>[];
  for (int i = 1; i <= 255; i++) {
    final ip = baseIP + i.toString();
    final address = InternetAddress(ip);
    final lookup = address.reverse();
    futures.add(lookup.then((result) {
      if (result.host.startsWith('KitsuDeck-')) {
        ipList.add(result.host);
      }
    }).catchError((error) {
      kitsuDeck.log(
          'Error occurred while looking up the host for IP $ip: $error',
          LogType.info);
    }));
  }
  await Future.wait(futures);
  for (final ip in ipList) {
    // make a http request to the ip
    final response = await kitsuDeckValidationCheck(ip);
    if (response != false) {
      returnList.add(response);
    }
  }
  return returnList;
}

pinValidationCheck(String address, String pin) async {
  final url = Uri.parse('http://$address/auth');
  try {
    // make a post request to the ip
    final response = await http.post(url, body: jsonEncode({"auth_pin": pin}));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

getMacroImage(String address, String pin, String name) async {
  final url = Uri.parse('http://$address/getMacroImage');
  try {
    // make a post request to the ip
    final response = await http.post(url,
        body: jsonEncode({"auth_pin": pin, "name": name}),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<bool> postMacroImage(
    String address, String pin, http.MultipartFile image) async {
  final url = Uri.parse('http://$address/postMacroImage');
  try {
    final request = http.MultipartRequest('POST', url);
    request.headers['Content-Type'] = 'multipart/form-data';
    request.files.add(image);
    request.fields.addAll({'auth_pin': pin});
    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
