import 'package:flutter/material.dart';
import 'dart:convert';

import '../Macros/MakrosAdd.dart';
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

  void initGetMakros() async {
    // get the list of devices from shared preferences
    kitsuDeckMakros = null;
    var makros = await getKitsuDeckMakros(widget.KitsuDeckDeviceName);
    for (var makro in makros) {
      var img =
          await getKitsuDeckMakroImg(widget.KitsuDeckDeviceName, makro['id']);
      // append the image to the makro
      makro['picture'] = jsonDecode(img)['picture'];
    }
    if (makros != false) {
      setState(() {
        kitsuDeckMakros = makros;
      });
    }
  }

  // init the state variable
  @override
  void initState() {
    initGetMakros();
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        setState(() {
                          kitsuDeckMakros = null;
                        });
                        var macros = await getKitsuDeckMakros(
                            widget.KitsuDeckDeviceName);
                        for (var macro in macros) {
                          var img = await getKitsuDeckMakroImg(
                              widget.KitsuDeckDeviceName, macro['id']);
                          // append the image to the makro
                          macro['picture'] = jsonDecode(img)['picture'];
                        }
                        if (macros != false) {
                          setState(() {
                            kitsuDeckMakros = macros;
                          });
                        }
                      },
                      icon: const Icon(Icons.refresh)),
                  const Spacer(),
                  const Text('Makros'),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MacroAddBottomSheet(
                                hostname: widget.KitsuDeckDeviceName,
                                title: "Add Macro")));
                      },
                      icon: const Icon(Icons.add)),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 166,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                    runAlignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
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
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.9)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.memory(
                                  base64Decode(makros['picture']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(makros['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(makros['description']),
                                      Text("Pressed: ${makros['invoked']}"),
                                    ],
                                  ),
                                )
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
