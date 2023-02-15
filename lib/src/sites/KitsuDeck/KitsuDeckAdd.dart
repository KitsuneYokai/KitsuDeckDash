import 'package:flutter/material.dart';
import '../ui.dart';
import '../../helper/network.dart';

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
    _ipList = await getKitsuDeckIP();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
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
