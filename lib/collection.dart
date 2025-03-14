import 'package:flutter/material.dart';

class Collection extends StatefulWidget{
  // final List<String> fullDex;

  const Collection(/*this.fullDex,*/ {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  bool darkMode = false;
  Color mainColour = Colors.white;
  Color invertColour = Colors.black;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColour,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: Row(
          children: [
            Text("Collection"),
            Spacer(),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide()
                  ),
                  suffixIcon: Icon(Icons.search)
                )
              ),
            )
          ],
        )
      ),
      body: ListView(
        primary: true,
        children: [
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 10,
            children: _testGrid()
          ),
        ],
      ),
    );
  }

  List<Widget> _testGrid() {
    List<Widget> tiles = [];
    for (int i = 0; i < 151; i++) {
      tiles.add(
        Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: Center(child: Text('${i+1}', style: TextStyle(fontSize: MediaQuery.of(context).size.width / 50)))
        )
      );
    }
    return tiles;
  }

  Widget _regionGrid() {
    final tiles = [];
    return Container();
  }
}