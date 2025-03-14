import 'dart:ui';

import 'package:flutter/material.dart';
import 'models/dex_entry.dart';
import 'models/region.dart';

class Collection extends StatefulWidget{
  final List<DexEntry> fullDex;

  const Collection(this.fullDex, {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  bool darkMode = false;
  Color mainColour = Colors.white;
  Color invertColour = Colors.black;
  Color accentColourLight = Colors.black12;
  Color accentColourDark = Colors.black45;
  Color solidAccentColourLight = Color.fromARGB(255, 240, 240, 240);
  final double appBarHeight = 130;
  double screenWidth = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainColour,
      body: Stack(
        children: [
          ListView(
            primary: true,
            children: <Widget>[
              SizedBox(height: appBarHeight + 10),
              _regionHeader(Region.kanto),
              GridView.count(
                padding: EdgeInsets.only(left: screenWidth / 10, right: screenWidth / 10, bottom: 40),
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
          _appBar()
        ],
      ),
    );
  }

  Widget _appBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.only(left: screenWidth / 10 - 15, right: screenWidth / 10 - 15),
        padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
        width: double.infinity,
        height: appBarHeight,
        decoration: BoxDecoration(
          color: solidAccentColourLight,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    'NANO.D3X PROGRESS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  ),
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
              ),
            ),
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: accentColourLight
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Text('COMPLETE COLLECTION'),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                        decoration: BoxDecoration(
                          color: accentColourDark,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Text(
                          '1/1025',
                          style: TextStyle(
                            color: mainColour
                          ),
                        )
                      )
                    ],
                  )
                )
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _regionFilterButton(String region) {
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accentColourLight,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(child: Text(region))
      ),
    );
  }

  Widget _regionHeader(Region region) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: EdgeInsets.only(top: 10, bottom: 10, left: screenWidth / 10, right: screenWidth / 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: accentColourLight
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Text(region.name.toUpperCase()),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
            decoration: BoxDecoration(
              color: accentColourDark,
              borderRadius: BorderRadius.circular(100)
            ),
            child: Text(
              '1/${region.dexSize}',
              style: TextStyle(
                color: mainColour
              ),
            )
          )
        ],
      )
    );
  }

  List<Widget> _testGrid() {
    List<Widget> tiles = [];
    for (int i = 0; i < 151; i++) {
      tiles.add(
        Container(
          decoration: BoxDecoration(
            color: accentColourLight,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Center(child: Text('${i+1}', style: TextStyle(fontSize: screenWidth / 50, color: mainColour)))
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


class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}