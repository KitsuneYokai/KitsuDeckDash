import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kitsu_deck_dash/src/helper/navbar.dart';
import '../ui.dart';
import '../../helper/network.dart';
import '../../helper/apiRequests/kitsuDeck/kitsuDeck.dart';

class KitsuDeckAdd extends StatefulWidget {
  static const routeName = '/device';

  const KitsuDeckAdd({
    Key? key,
  }) : super(key: key);

  @override
  _KitsuDeckAddState createState() => _KitsuDeckAddState();
}

class _KitsuDeckAddState extends State<KitsuDeckAdd> {
  bool _isLoading = false;
  List<String> _ipList = [];

  Future<void> _getIpList() async {
    setState(() {
      _isLoading = true;
    });
    _ipList = await getKitsuDeckHostname();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      canGoBack: true,
      title: "Add a KitsuDeck",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height - 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Search for KitsuDecks on your network",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    iconSize: 100,
                    color: Colors.white,
                    onPressed: () async {
                      await _getIpList();
                      // Do something with _ipList
                    },
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_ipList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _ipList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_ipList[index]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KitsuDeckAddDevice(
                                    kitsuDeckHostname: _ipList[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  const Spacer(),
                  const Text(
                      "If you cant find your Kitsu Deck you can add it manually"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2.phase of the registration
class KitsuDeckAddDevice extends StatefulWidget {
  static const routeName = '/device/add';
  final String kitsuDeckHostname;
  const KitsuDeckAddDevice({
    Key? key,
    required this.kitsuDeckHostname,
  }) : super(key: key);

  @override
  KitsuDeckAddDeviceState createState() => KitsuDeckAddDeviceState();
}

class KitsuDeckAddDeviceState extends State<KitsuDeckAddDevice> {
  bool isProtected = false;

  Future<void> initGetKitsuDeckIndex() async {
    try {
      final response = await getKitsuDeckIndex(widget.kitsuDeckHostname);
      setState(() {
        if (response["protected"]) {
          isProtected = true;
        }
      });
    } catch (e) {
      print("Error decoding JSON: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    initGetKitsuDeckIndex();
  }

  // add the text controller to the text field
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MainView(
      title: "Add ${widget.kitsuDeckHostname}",
      canGoBack: true,
      child: Column(
        children: [
          if (isProtected)
            const Text(
                "This KitsuDeck is protected, please enter the username/password"),
          // generate a container with a form to enter the username and password with a gradient background and a button
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Enter your username and password",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final auth = await postKitsuDeckAuth(
                          widget.kitsuDeckHostname,
                          usernameController.text,
                          passwordController.text);
                      if (jsonDecode(auth)["status"] == true) {
                        // TODO: save the hostname of the device using flutter secure storage (i have yet to implement this) and then navigate to the KitsuDeck page
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
