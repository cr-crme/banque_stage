import 'package:crcrme_banque_stages/screens/ref_sst/sst_cards/sst_cards_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/job_list_risks_and_skills/Job_list_homme_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/search_bar.dart';
import '/common/widgets/main_drawer.dart';

class HomeSSTScreen extends StatefulWidget {
  const HomeSSTScreen({Key? key}) : super(key: key);

  static const route = "/home-sst";

  @override
  State<HomeSSTScreen> createState() => _HomeSSTScreenState();
}

class _HomeSSTScreenState extends State<HomeSSTScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Référentiel SST"),
        ),
        drawer: const MainDrawer(),
        body: Column(
          children: [
            //Button for "Consulter les fiches"
            Center(
                child: Container(
              margin: const EdgeInsets.only(top: 35.0),
              child: InkWell(
                onTap: () {
                  print("Clicked on sst cards list");
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SSTCardsScreen(),
                  ));
                },
                child: Ink(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey, spreadRadius: 1, blurRadius: 15)
                    ],
                  ),
                  width: 300,
                  height: 260,
                  child: const Padding(
                    padding: EdgeInsets.all(45.0),
                    child: Center(
                      child: Text(
                        "Consulter les fiches de risques",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: "Noto Sans"),
                      ),
                    ),
                  ),
                ),
              ),
            )),
            //Container for the search bar
            Center(
                child: Container(
              margin: const EdgeInsets.only(top: 50.0),
              width: 300,
              height: 260,
              padding: const EdgeInsets.all(17.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
                ],
              ),
              child: InkWell(
                  onTap: () {
                    print("Clicked on jod list risks and skills");
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => JobListScreen(),
                    ));
                  },
                  child: Column(
                    children: [
                      const Text("Analyse des risques par métier",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.white,
                              fontFamily: "Noto Sans")),
                      Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: SearchBar(controller: _searchController))
                    ],
                  )),
            )),
          ],
        ));
  }
}
