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
  List<int> loaded = [];
  int totalComplete = 0;
  final totalFinale = 1025;
  final _paneAnimationTime = 200;
  bool _displayMale = true;

  final regions = [
    Region.kanto,
    Region.johto,
    Region.hoenn,
    Region.sinnoh,
  ];

  dex.DexEntry? selectedEntry; // Track selected entry
  bool isPaneOpen = false; // Track panel visibility

  double get paneWidth => (screenWidth * 0.8 - 90) * 0.4 + 30;

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
          _appBar(),
          _slidingPane(),
        ],
      ),
    );
  }

  Widget _slidingPane() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: _paneAnimationTime),
      curve: Curves.easeInOut,
      right: isPaneOpen ? screenWidth / 10 : -paneWidth,  // pos logic
      top: appBarHeight + 20,
      bottom: 0,
      width: paneWidth,
      child: GestureDetector(
        onTap: () {/* prevents tapping from closing */},
        child: Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: solidAccentColourLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), 
              topRight: Radius.circular(10)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(-5, 0),
              )
            ],
          ),
          child: selectedEntry != null
              ? Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 15, right: 15), // TODO: change from const to dynamic
                      child: _paneContent(),
                    ),
                    _paneHeader(),
                  ],
                )
              : _paneFallback(),
        ),
      ),
    );
  }

  Widget _paneHeader() {
    dex.DexEntry currEntry = selectedEntry!;
    String dexNumAsString = dexNumFormatted(currEntry.dexNum);
    bool genderKnown = currEntry.genderKnown;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.only(left: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 30),
                Icon(Icons.catching_pokemon, color: Colors.red, size: 30),
                Icon(Icons.circle_outlined, color: Colors.black, size: 30),
                Icon(Icons.circle_outlined, color: Colors.black, size: 32)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '#$dexNumAsString',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white
              )
            ),
          ),
          Text(
            currEntry.forms[0].name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white
            )
          ),
          currEntry.dexNum == 29 ? Icon(Icons.female, color: Colors.white, size: 18) : SizedBox(),
          currEntry.dexNum == 32 ? Icon(Icons.male, color: Colors.white, size: 18) : SizedBox(),
          const Spacer(),
          if (genderKnown) _nameHeaderButtons(currEntry.genderRatio)
        ]
      ),
    );
  }

  Widget _nameHeaderButtons(double? ratio) { // TODO: hide buttons if entry still locked
    if (ratio != null && ratio == 0) {
      setState(() {
        _displayMale = false;
      });
    } else if (ratio != null && ratio == 100) {
      setState(() {
        _displayMale = true;
      });
    }
    return Row(
      children: [
        (ratio != null && ratio != 0)
              ? _maleButton()
              : SizedBox(),
        (ratio != null && ratio != 100)
              ? _femaleButton()
              : SizedBox(),
      ],
    );
  }

  Widget _femaleButton() {
    return SizedBox(
      width: 35,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _displayMale = false;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.pink,
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.all(_displayMale? 3 : 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        child: Icon(Icons.female, color: Colors.white, size: _displayMale ? 15 : 20)
      ),
    );
  }

  Widget _maleButton() {
    return SizedBox(
      width: 35,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _displayMale = true;
          });
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.all(_displayMale? 6 : 3),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        child: Icon(Icons.male, color: Colors.white, size: _displayMale ? 20 : 15)
      ),
    );
  }

  Widget _paneContent() {
    if (selectedEntry == null) return _paneFallback();
    int index = 0; // TODO: change
    dex.Form initForm = selectedEntry!.forms[index];

    String imageUrl = shinyToggle
        ? (_displayMale ? initForm.imageAssetMShiny : initForm.imageAssetFShiny)
        : (_displayMale ? initForm.imageAssetM : initForm.imageAssetF);

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15)
            ),
            child: FutureBuilder<Widget>(
              future: _paneImage(selectedEntry!.dexNum, imageUrl), // Fetch image asynchronously
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: accentColourLight)); // Show loading indicator
                } else if (snapshot.hasError) {
                  return _paneFallback(); // Show fallback if there's an error
                } else {
                  return snapshot.data ?? _paneFallback(); // Display the loaded image
                }
              },
            ),
          ),
        ),
      ],
    );
  }


  Future<Widget> _paneImage(int dexNum, String key) async {
    String? url = await getImageUrl(dexNum, key, selectedEntry!.forms[0].region);
    if (url == null || url == 'error') {
      return _paneFallback();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (context, url) => 
          Center(child: CircularProgressIndicator(color: accentColourLight)), // Loading state
      errorWidget: (context, url, error) => _paneFallback(), // Error case
    );
  }

  Widget _paneFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported, size: 50),
        const SizedBox(height: 10),
        Text('No image available.')
      ]
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
    return StatefulBuilder(builder: (context, setLocalState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setLocalState(() => _isShinyButtonHovered = true),
        onExit: (_) => setLocalState(() => _isShinyButtonHovered = false),
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
                  color: invertColour,
                ),
                const SizedBox(width: 5),
                Text(
                  shinyToggle ? 'Classic' : 'Shiny',
                  style: TextStyle(color: invertColour),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
  // Widget _shinyToggleButton() {
  //   return MouseRegion(
  //     cursor: SystemMouseCursors.click,
  //     onEnter: (_) => setState(() => _isShinyButtonHovered = true),
  //     onExit: (_) => setState(() => _isShinyButtonHovered = false),
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() => shinyToggle = !shinyToggle);
  //       },
  //       child: Container(
  //         padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 15),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: invertColour),
  //           borderRadius: BorderRadius.circular(100),
  //           color: _isShinyButtonHovered ? accentColourLight : Colors.transparent,
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(
  //               shinyToggle ? Icons.draw : Icons.auto_awesome,
  //               size: 15,
  //               color: invertColour
  //             ),
  //             const SizedBox(width: 5),
  //             Text(
  //               shinyToggle ? 'Classic' : 'Shiny',
  //               style: TextStyle(
  //                 color: invertColour,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  bool _isDarkModeButtonHovered = false;
  Widget _darkModeButton() {
    return StatefulBuilder(builder: (context, setLocalState) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setLocalState(() => _isDarkModeButtonHovered = true),
        onExit: (_) => setLocalState(() => _isDarkModeButtonHovered = false),
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
    });
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
      padding: EdgeInsets.only(left: screenWidth / 10, right: isPaneOpen ? screenWidth * 0.42 + 4.2 : screenWidth / 10, bottom: 40),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      primary: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: isPaneOpen ? 6 : 10,
      children: _regionTiles(region)
    );
  }

  Widget _regionHeader(Region region) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: EdgeInsets.only(top: 10, bottom: 10, left: screenWidth / 10, right: isPaneOpen ? screenWidth * 0.42 + 4.2 : screenWidth / 10),
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

  final _imageCacheManager = _ImageCacheManager(); // Store globally or in the widget state

  List<Widget> _regionTiles(Region region) {
    return List.generate(region.dexSize, (index) {
      int dexIndex = region.dexFirst - 1 + index;
      dex.Form form = widget.fullDex[dexIndex].forms[0];
      String imageAssetLocation = shinyToggle ? form.imageAssetMShiny : form.imageAssetM;

      return ValueListenableBuilder<String?>( // Use imageAssetLocation as the key
        valueListenable: _imageCacheManager.getNotifier(
          imageAssetLocation, region, (path, reg) => getImageUrl(dexIndex, path, reg)
        ),
        builder: (context, imageUrl, child) {
          if (imageUrl == null) {
            return _loadingTile(); // Show loading only while fetching
          } else if (imageUrl == 'error') {
            return _fallbackTile(dexIndex); // Show fallback if fetching fails
          } else {
            return HoverImageTile(
              imageUrl: imageUrl,
              isDarkMode: darkMode,
              onTap: () {
                setState(() {
                  dex.DexEntry newEntry = widget.fullDex[dexIndex];
                  if (selectedEntry == newEntry) {
                    isPaneOpen = false;
                    Future.delayed(Duration(milliseconds: _paneAnimationTime), () {
                      selectedEntry = null;
                    });
                  } else {
                    selectedEntry = widget.fullDex[dexIndex];
                    isPaneOpen = true;
                  }
                });
              }
            );
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

  Future<String?> getImageUrl(int dexNum, String path, Region region, {bool update = true}) async {
    if (imageCache.containsKey(path) && imageCache[path] != 'error' && imageCache[path] != null) {
      return imageCache[path];  // Return cached URL if available
    }

    imageCache[path] = null;  // Indicate it's still loading

    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      String url = await storageRef.getDownloadURL();

      imageCache[path] = url; // Store the fetched URL
      if (!loaded.contains(dexNum)) {
        setState(() {
          totalComplete++;
          loaded.add(dexNum);
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
  final bool isDarkMode;
  final VoidCallback onTap;

  HoverImageTile({required this.imageUrl, required this.onTap, required this.isDarkMode, Key? key}) : super(key: key);

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
                ? widget.isDarkMode
                  ? [BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1)]
                  : [BoxShadow(color: Color.fromARGB(26, 255, 255, 255), blurRadius: 3, spreadRadius: 1)]
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


String dexNumFormatted(int num) {
  switch (num) {
    case > 0 && < 10: return '000$num';
    case > 10 && < 100: return '00$num';
    case > 100 && < 1000: return '0$num';
    case > 1000 && < 10000: return '$num';
    default: return 'Error: invalid dex num';
  }
}