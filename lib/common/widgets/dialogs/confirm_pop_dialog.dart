import 'package:flutter/material.dart';

class ConfirmPopDialog extends StatelessWidget {
  const ConfirmPopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("Êtes-vous sûr de vouloir quitter ?"),
          content: const SingleChildScrollView(
              child: Text(
                  "Vous allez perdre les modifications que vous avez effectuées.")),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Non")),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Oui"))
          ],
        ));
  }
}
