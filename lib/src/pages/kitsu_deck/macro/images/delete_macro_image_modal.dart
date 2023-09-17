import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../classes/kitsu_deck/connector.dart';

class DeleteMacroImageModal extends StatefulWidget {
  const DeleteMacroImageModal({super.key, required this.image});
  final Map image;

  @override
  DeleteMacroImageModalState createState() => DeleteMacroImageModalState();
}

class DeleteMacroImageModalState extends State<DeleteMacroImageModal> {
  @override
  Widget build(BuildContext context) {
    final kitsuDeck = Provider.of<DeckWebsocket>(context);
    if (kitsuDeck.isConnected) {
      kitsuDeck.stream.firstWhere((event) {
        Map jsonData = jsonDecode(event);
        if (jsonData["event"] == "DELETE_MACRO_IMAGE") {
          if (jsonData["status"] == true) {
            if (mounted) Navigator.pop(context, true);
          } else {
            SnackBar snackBar = SnackBar(
              content: Text(jsonData["message"]),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            if (mounted) Navigator.pop(context, false);
          }
        }
        return false;
      });
    }
    return AlertDialog(
      title: const Text("Are you sure?"),
      content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Do you really want to delete this image?"),
            const SizedBox(height: 10),
            widget.image["image_widget"]
          ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            kitsuDeck.send(jsonEncode({
              "event": "DELETE_MACRO_IMAGE",
              "auth_pin": kitsuDeck.pin,
              "image_id": widget.image["id"]
            }));
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }
}

Future<bool?> showDeleteMacroImageModal(BuildContext context, Map image) async {
  return await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return DeleteMacroImageModal(image: image);
    },
  );
}
