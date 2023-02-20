// import the libraries we need
import 'package:http/http.dart' as http;
import 'dart:convert';

// make a get request to the kitsuDeckHostname to get the device firmware version & to see if the auth is set or not.
getKitsuDeckIndex(kitsuDeckHostname) async {
  var response = await http.get(Uri.parse('http://$kitsuDeckHostname/'));
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

postKitsuDeckAuth(kitsuDeckHostname, username, password) async {
  // set up POST request arguments
  String url = 'http://$kitsuDeckHostname/kitsuDeck/auth';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"username": "$username", "password": "$password"}';
  // make POST request
  http.Response response =
      await http.post(Uri.parse(url), headers: headers, body: json);
  // check the status code for the result
  if (response.statusCode == 200) {
    return response.body;
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}
