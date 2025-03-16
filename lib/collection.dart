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
  Color get mainColour => darkMode ? Colors.black : Colors.white;
  Color get invertColour => darkMode ? Color.fromARGB(255, 225, 229, 240) : Colors.black;
  Color get accentColourLight => darkMode ? Colors.black12 : Colors.black12;
  Color get accentColourDark => darkMode ? Colors.black45 : Colors.black45;
  Color get solidAccentColourLight => darkMode ? const Color.fromARGB(255, 20, 20, 20) : const Color.fromARGB(255, 240, 240, 240);

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
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Text(
                    'NANO.D3X PROGRESS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: invertColour
                    )
                  ),
                  const Spacer(),
                  const Expanded(
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
                          Text(
                            'COMPLETE COLLECTION',
                            style: TextStyle(
                              color: invertColour
                            )
                          ),
                          const Spacer(),
                          _shinyToggleButton(),
                          _darkModeButton()
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
                            color: Colors.white
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

  bool _isShinyButtonHovered = false;
  Widget _shinyToggleButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isShinyButtonHovered = true),
      onExit: (_) => setState(() => _isShinyButtonHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => shinyToggle = !shinyToggle);
        },
        child: Container(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 15),
          decoration: BoxDecoration(
            border: Border.all(color: invertColour),
            borderRadius: BorderRadius.circular(100),
            color: _isShinyButtonHovered ? accentColourLight : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                shinyToggle ? Icons.draw : Icons.auto_awesome,
                size: 15,
                color: invertColour
              ),
              const SizedBox(width: 5),
              Text(
                shinyToggle ? 'Classic' : 'Shiny',
                style: TextStyle(
                  color: invertColour,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDarkModeButtonHovered = false;
  Widget _darkModeButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isDarkModeButtonHovered = true),
      onExit: (_) => setState(() => _isDarkModeButtonHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() => darkMode = !darkMode);
        },
        child: Container(
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 15),
          decoration: BoxDecoration(
            border: Border.all(color: invertColour),
            borderRadius: BorderRadius.circular(100),
            color: _isDarkModeButtonHovered ? accentColourLight : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                darkMode ? Icons.light_mode : Icons.dark_mode,
                size: 15,
                color: invertColour
              ),
              SizedBox(width: 5),
              Text(
                darkMode ? 'Light' : 'Dark',
                style: TextStyle(
                  color: invertColour,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return GridView.count(
      padding: EdgeInsets.only(left: screenWidth / 10, right: screenWidth / 10, bottom: 40),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 10,
      children: _regionTiles(region)
    );
  }

  Widget _regionHeader(Region region) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: EdgeInsets.only(top: 10, bottom: 10, left: screenWidth / 10, right: screenWidth / 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: solidAccentColourLight
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Text(
                region.name.toUpperCase(),
                style: TextStyle(
                  color: invertColour
                )
              ),
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
                color: Colors.white
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

      return ValueListenableBuilder<String?>( // Use imageAssetLocation as the key
        valueListenable: _imageCacheManager.getNotifier(
          imageAssetLocation, region, getImageUrl
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
        color: solidAccentColourLight,
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
        color: solidAccentColourLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(fontSize: screenWidth / 50, color: Colors.white),
        ),
      ),
    );
  }

  Future<String?> getImageUrl(String path, Region region) async {
    if (imageCache.containsKey(path) && imageCache[path] != 'error' && imageCache[path] != null) {
      return imageCache[path];  // Return cached URL if available
    }

    imageCache[path] = null;  // Indicate it's still loading

    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      String url = await storageRef.getDownloadURL();

      imageCache[path] = url; // Store the fetched URL
      if (!shinyToggle) {
        setState(() {
          totalComplete++;
          completed.update(region, (val) => val + 1, ifAbsent:() => 1);
        });
      }
      return url;
    } on FirebaseException catch (_) {
      imageCache[path] = 'error'; // Explicitly mark as failed
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
  final Map<String, ValueNotifier<String?>> imageUrlNotifiers = {};

  ValueNotifier<String?> getNotifier(String path, Region region, Future<String?> Function(String, Region) fetchUrl) {
    if (!imageUrlNotifiers.containsKey(path)) {
      final notifier = ValueNotifier<String?>(null);
      imageUrlNotifiers[path] = notifier;

      fetchUrl(path, region).then((url) {
        notifier.value = url; // Update notifier instead of calling setState
      });
    }
    return imageUrlNotifiers[path]!;
  }
}
