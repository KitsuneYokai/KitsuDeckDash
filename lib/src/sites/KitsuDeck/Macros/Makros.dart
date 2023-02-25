import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';

import '../../ui.dart';
import '../../../helper/apiRequests/kitsuDeck/kitsuDeck.dart';

class KitsuDeckMakros extends StatefulWidget {
  // create a state variable to store the list of devices
  final KitsuDeckDeviceName;
  // create a constructor that takes in the list of devices
  const KitsuDeckMakros({Key? key, required this.KitsuDeckDeviceName})
      : super(key: key);

  @override
  _KitsuDeckMakrosState createState() => _KitsuDeckMakrosState();
}

class _KitsuDeckMakrosState extends State<KitsuDeckMakros> {
  var kitsuDeckMakros;

  void init() async {
    // get the list of devices from shared preferences
    var makros = await getKitsuDeckMakros(widget.KitsuDeckDeviceName);
    if (makros != false) {
      print(makros);
      setState(() {
        kitsuDeckMakros = makros;
      });
    }
  }

  // init the state variable
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
        canGoBack: true,
        title: widget.KitsuDeckDeviceName,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    Theme.of(context).primaryColor.withOpacity(0.9)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        setState(() {
                          kitsuDeckMakros = null;
                        });
                        var makros = await getKitsuDeckMakros(
                            widget.KitsuDeckDeviceName);
                        if (makros != false) {
                          setState(() {
                            kitsuDeckMakros = makros;
                          });
                        }
                      },
                      icon: const Icon(Icons.refresh)),
                  const Spacer(),
                  const Text('Makros'),
                  const Spacer(),
                  IconButton(onPressed: null, icon: Icon(Icons.add)),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 166,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(children: [
                  if (kitsuDeckMakros != null) ...[
                    for (var makros in kitsuDeckMakros) ...[
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.9),
                              Theme.of(context).primaryColor.withOpacity(0.9)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //inside container
                            Text(makros['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(makros['description']),
                          ],
                        ),
                      ),
                    ]
                  ] else ...[
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  ]
                ]),
              ),
            )
          ],
        ));
  }
}
