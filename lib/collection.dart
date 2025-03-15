import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'models/dex_entry.dart' as dex;
import 'models/region.dart';

class Collection extends StatefulWidget{
  final List<dex.DexEntry> fullDex;

  const Collection(this.fullDex, {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final ScrollController _scrollController = ScrollController();

  bool darkMode = false;
  bool shinyToggle = false;
  Color mainColour = Colors.white;
  Color invertColour = Colors.black;
  Color accentColourLight = Colors.black12;
  Color accentColourDark = Colors.black45;
  Color solidAccentColourLight = const Color.fromARGB(255, 240, 240, 240);
  final double appBarHeight = 130;
  double screenWidth = 100;

  Map<String, String?> imageCache = {};
  Map<String, String?> shinyCache = {};

  Map<Region, int> completed = {};
  int totalComplete = 0;
  final totalFinale = 1025;

  final regions = [
    Region.kanto,
    Region.johto,
    Region.hoenn,
    Region.sinnoh,
  ];

  @override
  void initState() {
    if (completed.isEmpty) {
      initCompletionMap();
    }
    super.initState();
  }

  void initCompletionMap() {
    completed = { for (var region in regions) region : 0 };
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainColour,
      body: Stack(
        children: [
          Scrollbar(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              primary: false,
              children: <Widget>[
                SizedBox(height: appBarHeight + 10),
                ...regions.map((region) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _regionHeader(region),
                    _regionGrid(region)
                  ],
                )),
                _regionHeader(Region.unova),
                _regionHeader(Region.alola),
                _regionHeader(Region.unknown),
                _regionHeader(Region.galar),
                _regionHeader(Region.hisui),
                _regionHeader(Region.paldea),
              ],
            ),
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
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
        width: double.infinity,
        height: appBarHeight,
        decoration: BoxDecoration(
          color: solidAccentColourLight,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
        ),
        child: Column(
          children: [
            const Expanded(
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
                        hintStyle: TextStyle(
                          fontSize: 15,
                        ),
                        border: OutlineInputBorder(
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
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: accentColourLight
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          const Text('COMPLETE COLLECTION'),
                          const Spacer(),
                          _shinyToggleButton()
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                        decoration: BoxDecoration(
                          color: accentColourDark,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Text(
                          '$totalComplete/$totalFinale',
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

  Widget _shinyToggleButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() => shinyToggle = !shinyToggle);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all()
          ),
          child: Row(
            children: [
              Text(shinyToggle ? 'Classic' : 'Shiny')
            ],
          )
        ),
      )
    );
  }

  Widget _regionFilterButton(String region) {
    return AspectRatio(
      aspectRatio: 2,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accentColourLight,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(child: Text(region))
      ),
    );
  }

  Widget _regionGrid(Region region) {
    double rowCount = (region.dexSize / 10).ceil().toDouble();
    double tileHeight = screenWidth * 4 / 5 / 10;

    return SizedBox(
      height: rowCount * tileHeight + (rowCount - 1) * 10 + 40,
      child: GridView.count(
        padding: EdgeInsets.only(left: screenWidth / 10, right: screenWidth / 10, bottom: 40),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 10,
        children: _regionTiles(region)
      ),
    );
  }

  Widget _regionHeader(Region region) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
            decoration: BoxDecoration(
              color: accentColourDark,
              borderRadius: BorderRadius.circular(100)
            ),
            child: Text(
              '${completed[region]}/${region.dexSize}',
              style: TextStyle(
                color: mainColour
              ),
            )
          )
        ],
      )
    );
  }

  // List<Widget> _regionTiles(Region region) {
  //   return List.generate(region.dexSize, (index) {
  //     int dexIndex = region.dexFirst - 1 + index;
  //     String imageAssetLocation = widget.fullDex[dexIndex].forms[0].imageAssetM;
  //     return FutureBuilder<String?>(
  //       future: getImageUrl(imageAssetLocation, region), // Load image URL asynchronously
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return _loadingTile(); // Show a loading indicator
  //         } else if (snapshot.hasError || snapshot.data == null) {
  //           return _fallbackTile(dexIndex); // Show fallback if image fails to load
  //         } else {
  //           return HoverImageTile(imageUrl: snapshot.data!, onTap: () {}); // Show loaded image
  //         }
  //       },
  //     );
  //   });
  // }

final _imageCacheManager = _ImageCacheManager(); // Store globally or in the widget state

List<Widget> _regionTiles(Region region) {
  return List.generate(region.dexSize, (index) {
    int dexIndex = region.dexFirst - 1 + index;
    dex.Form form = widget.fullDex[dexIndex].forms[0];
    String imageAssetLocation = shinyToggle ? form.imageAssetMShiny : form.imageAssetM;

    return ValueListenableBuilder<String?>(
      valueListenable: _imageCacheManager.getNotifier(
        dexIndex, imageAssetLocation, region, getImageUrl
      ),
      builder: (context, imageUrl, child) {
        if (imageUrl == null) {
          return _loadingTile(); // Show loading only while fetching
        } else if (imageUrl == 'error') {
          return _fallbackTile(dexIndex); // Show fallback if fetching fails
        } else {
          return HoverImageTile(imageUrl: imageUrl, onTap: () {}); // Show valid image
        }
      },
    );
  });
}



  Widget _loadingTile() {
    return Container(
      decoration: BoxDecoration(
        color: accentColourLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: accentColourLight
        )
      ),
    );
  }

  Widget _fallbackTile(int index) {
    return Container(
      decoration: BoxDecoration(
        color: accentColourLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(fontSize: screenWidth / 50, color: mainColour),
        ),
      ),
    );
  }

  Future<String?> getImageUrl(String path, Region region) async {
    Map<String, String?> currCache = shinyToggle ? shinyCache : imageCache; 
    if (currCache.containsKey(path) && currCache[path] != 'error' && currCache[path] != null) {
      return currCache[path];  // Return cached URL if available
    }

    currCache[path] = null;  // Indicate it's still loading

    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      String url = await storageRef.getDownloadURL();

      currCache[path] = url; // Store the fetched URL
      setState(() {
        totalComplete++;
        completed.update(region, (val) => val + 1, ifAbsent:() => 1);
      });
      return url;
    } on FirebaseException catch (_) {
      currCache[path] = 'error'; // Explicitly mark as failed
      return 'error';
    }
  }

}


class HoverImageTile extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;

  HoverImageTile({required this.imageUrl, required this.onTap, Key? key}) : super(key: key);

  @override
  _HoverImageTileState createState() => _HoverImageTileState();
}

class _HoverImageTileState extends State<HoverImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: _isHovered ? Colors.black45 : Colors.black12,
              width: _isHovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovered
                ? [const BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1)]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AnimatedScale(
              scale: _isHovered ? 1.1 : 1.0, // Slightly scale the image on hover
              duration: const Duration(milliseconds: 150),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _ImageCacheManager {
  final Map<int, ValueNotifier<String?>> imageUrlNotifiers = {};

  ValueNotifier<String?> getNotifier(int dexIndex, String path, Region region, Future<String?> Function(String, Region) fetchUrl) {
    if (!imageUrlNotifiers.containsKey(dexIndex)) {
      final notifier = ValueNotifier<String?>(null);
      imageUrlNotifiers[dexIndex] = notifier;

      fetchUrl(path, region).then((url) {
        notifier.value = url; // Update notifier instead of calling setState
      });

    }
    return imageUrlNotifiers[dexIndex]!;
  }
}