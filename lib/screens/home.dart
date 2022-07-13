import 'package:flutter/material.dart';

import '/screens/enterprises/add.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  static const route = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddEnterprise.route),
        child: const Icon(Icons.add),
      ),
    );
  }
}
