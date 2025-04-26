import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokellection/models/type.dart';
import 'models/dex_entry.dart' as dex;
import 'models/region.dart';

const copyrightText = 'This website is a fan-made project and is not affiliated with or endorsed by The Pokémon Company, Nintendo, or any related entities. All Pokémon names, logos, and trademarks are the property of their respective owners. The artwork featured on this site is fan-created and is presented solely as a portfolio, with no intention of profit. All rights to the fan art are held by the respective artists. No copyright infringement is intended.';

class Collection extends StatefulWidget{
  final List<dex.DexEntry> fullDex;

  const Collection(this.fullDex, {super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool darkMode = false;
  bool shinyToggle = false;
  Color get mainColour => darkMode ? Colors.black : Colors.white;
  Color get invertColour => darkMode ? const Color.fromARGB(255, 225, 229, 240) : Colors.black;
  Color get accentColourLight => darkMode ? Colors.black12 : Colors.black12;
  Color get accentColourDark => darkMode ? Colors.black45 : Colors.black45;
  Color get solidAccentColourLight => darkMode ? const Color.fromARGB(255, 20, 20, 20) : const Color.fromARGB(255, 240, 240, 240);
  Color get solidAccentColourDark => darkMode ? const Color.fromARGB(255, 100, 100, 100) : const Color.fromARGB(255, 180, 180, 180);

  final double appBarHeight = 130;
  double screenWidth = 100;

  Map<String, String?> imageCache = {};
  Map<String, String?> shinyCache = {};
  Future<Widget>? _cachedPaneImageFuture;
  int? _cachedDexNum;
  String? _cachedImageKey;

  int formIndex = 0;

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
    Region.unova,
    Region.kalos,
    Region.alola,
    Region.unknown
  ];

  final TextEditingController _searchController = TextEditingController();

  dex.DexEntry? selectedEntry; // Track selected entry
  bool isPaneOpen = false; // Track panel visibility

  double get paneWidth => (screenWidth * 0.8 - 90) * 0.4 + 30;

  @override
  void initState() {
    if (completed.isEmpty) {
      initCompletionMap();
    }
    _searchController.addListener(_onSearchChanged);
    _focusNode.requestFocus();
    super.initState();
    _updatePaneImageFuture();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape && isPaneOpen) {
      _closePane();
    }
  }

  void _closePane() {
    isPaneOpen = false;
    Future.delayed(Duration(milliseconds: _paneAnimationTime), () {
      setState(() {
        selectedEntry = null;
      });
    });
  }

  void _updatePaneImageFuture() {
    formIndex = 0;
    if (selectedEntry == null) {
      _cachedPaneImageFuture = null;
      _cachedDexNum = null;
      _cachedImageKey = null;
      return;
    }
    dex.Form initForm = selectedEntry!.forms[formIndex];
    String imageUrl = shinyToggle
        ? (_displayMale ? initForm.imageAssetMShiny : initForm.imageAssetFShiny)
        : (_displayMale ? initForm.imageAssetM : initForm.imageAssetF);

    // Only update the future if the parameters changed
    if (_cachedDexNum != selectedEntry!.dexNum || _cachedImageKey != imageUrl) {
      _cachedPaneImageFuture = _paneImage(selectedEntry!.dexNum, imageUrl);
      _cachedDexNum = selectedEntry!.dexNum;
      _cachedImageKey = imageUrl;
    }
  }

  void initCompletionMap() {
    completed = { for (var region in regions) region : 0 };
  }

  @override
  void didUpdateWidget(Collection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePaneImageFuture();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _updatePaneImageFuture();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: mainColour,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
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
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth / 10 + 20, right: isPaneOpen ? screenWidth * 0.42 + 24.2 : screenWidth / 10 + 20, bottom: 5),
                      child: Text(
                        copyrightText,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          color: solidAccentColourDark,
                          fontSize: 10,
                        )
                      ),
                    ),
                  ],
                ),
              ),
              _appBar(),
              _slidingPane(),
            ],
          ),
        ),
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
          padding: const EdgeInsets.only(top: 15),
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
                offset: const Offset(-2, 0),
              )
            ],
          ),
          child: selectedEntry != null
              ? Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60, left: 15, right: 15), // TODO: change from const to dynamic
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
      padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(200), 
          bottomRight: Radius.circular(200)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 40),
                Icon(Icons.catching_pokemon, color: Colors.red, size: 40),
                Icon(Icons.circle_outlined, color: Colors.black, size: 40),
                Icon(Icons.circle_outlined, color: Colors.black, size: 42),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              '#$dexNumAsString',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  currEntry.forms[0].name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis
                  ),
                  maxLines: 1,
                ),
                if (currEntry.dexNum == 29) 
                  const Icon(Icons.female, color: Colors.white, size: 18),
                if (currEntry.dexNum == 32) 
                  const Icon(Icons.male, color: Colors.white, size: 18),
                const Spacer(),
                if (genderKnown) _nameHeaderButtons(currEntry.genderRatio),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _nameHeaderButtons(double? ratio) {
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
              : const SizedBox(),
        (ratio != null && ratio != 100)
              ? _femaleButton()
              : const SizedBox(),
      ],
    );
  }

  Widget _femaleButton() {
    return SizedBox(
      width: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _displayMale = false;
            });
          },
          child: Container(
            padding: EdgeInsets.all(_displayMale ? 3 : 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink,
            ),
            child: Icon(Icons.female, color: Colors.white, size: _displayMale ? 20 : 28)
          )
        )
      )
    );
  }

  Widget _maleButton() {
    return SizedBox(
      width: 40,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _displayMale = true;
            });
          },
          child: Container(
            padding: EdgeInsets.all(_displayMale ? 6 : 3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Icon(Icons.male, color: Colors.white, size: _displayMale ? 28 : 20)
          )
        )
      )
    );
  }

  Widget _paneTypes(List<MonType> types) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 15),
      child: Row(
        children: types.map((type) => _typeContainer(type)).toList()
      ),
    );
  }

  Widget _stats(dex.Stats stats) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Base Stats',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: invertColour
            )
          ),
          const SizedBox(height: 8),
          _statLine('HP', stats.hp),
          _statLine('Atk', stats.atk),
          _statLine('Def', stats.def),
          _statLine('S.Atk', stats.spAtk),
          _statLine('S.Def', stats.spDef),
          _statLine('Spd', stats.speed)
        ]
      ),
    );
  }

  Widget _statLine(String statName, int amount) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            statName,
            style: TextStyle(color: invertColour)
          )
        ),
        SizedBox(
          width: 30,
          child: Text(
            '$amount',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: invertColour
            ),
          )
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: invertColour),
                borderRadius: BorderRadius.circular(6)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: amount,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: invertColour,
                        border: const Border(bottom: BorderSide(), top: BorderSide())
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 255 - amount,
                    child: const SizedBox()
                  )
                ],
              )
            ),
          ),
        ),
      ],
    );
  }


  Widget _typeContainer(MonType type) {
    return Container(
      width: 100,
      height: 30,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: type.colour
      ),
      child: Text(
        type.type,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      )
    );
  }

  Widget _measurements(double height, double weight) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: invertColour),
          bottom: BorderSide(color: invertColour)
        )
      ),
      child: Row(
        children: [
          const Spacer(),
          Icon(Icons.scale, color: invertColour),
          const SizedBox(width: 7),
          Text(
            '$weight kg',
            style: TextStyle(
              color: invertColour
            )
          ),
          const Spacer(),
          const Spacer(),
          Icon(Icons.straighten, color: invertColour),
          const SizedBox(width: 7),
          Text(
            '${height/100} m',
            style: TextStyle(
              color: invertColour
            )
          ),
          const Spacer()
        ]
      ),
    );
  }

  Widget _flavourText(String category, String entryText) {
     return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(top: 5, left: 6, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 15),
            child: Text(
              '$category Pokémon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: invertColour
              )
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.search, color: invertColour),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  entryText,
                  softWrap: true,
                  style: TextStyle(
                    color: invertColour
                  )
                ),
              ),
            ],
          )
        ]
       ),
     );
  }

  Widget _paneContent() {
    if (selectedEntry == null) return _paneFallback();
    dex.Form initForm = selectedEntry!.forms[formIndex];

    _updatePaneImageFuture();

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
              future: _cachedPaneImageFuture, // Fetch image asynchronously
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
        _paneTypes(initForm.type),
        _flavourText(initForm.category, initForm.entry),
        _measurements(initForm.height, initForm.weight),
        _stats(initForm.stats[0]),
        const SizedBox(height: 40)
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
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported, size: 50),
        SizedBox(height: 10),
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
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
                          style: const TextStyle(
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
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 15),
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
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 15),
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
                const SizedBox(width: 5),
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
              style: const TextStyle(
                color: Colors.white
              ),
            )
          )
        ],
      )
    );
  }

  bool _filterTile(dex.Form form) {
    String query = _searchController.text.toLowerCase();
    return form.name.toLowerCase().contains(query) || query == form.key.round().toString();
  }

  final _imageCacheManager = _ImageCacheManager();

  List<Widget> _regionTiles(Region region) {
    final filteredDexIndexes = List.generate(region.dexSize, (index) {
      int dexIndex = region.dexFirst - 1 + index;
      dex.Form form = widget.fullDex[dexIndex].forms[0];
      if (_searchController.text.isNotEmpty && !_filterTile(form)) {
        return null;
      }
      return dexIndex;
    }).where((index) => index != null).toList();

    return filteredDexIndexes.map((dexIndex) {
      dex.Form form = widget.fullDex[dexIndex!].forms[0];
      String imageAssetLocation = shinyToggle ? form.imageAssetMShiny : form.imageAssetM;

      return ValueListenableBuilder<String?>(
        valueListenable: _imageCacheManager.getNotifier(
          imageAssetLocation, region, (path, reg) => getImageUrl(dexIndex, path, reg),
        ),
        builder: (context, imageUrl, child) {
          dex.DexEntry entry = widget.fullDex[dexIndex];
          if (imageUrl == null) {
            return _loadingTile();
          } else if (imageUrl == 'error') {
            return _fallbackTile(dexIndex);
          } else {
            return HoverImageTile(
              imageUrl: imageUrl,
              isDarkMode: darkMode,
              isSelected: selectedEntry == entry,
              onTap: () {
                setState(() {
                  if (selectedEntry == entry) {
                    _closePane();
                  } else {
                    selectedEntry = widget.fullDex[dexIndex];
                    isPaneOpen = true;
                  }
                });
              },
            );
          }
        },
      );
    }).toList();
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
      return imageCache[path];  // return cached url if available
    }

    imageCache[path] = null;  // state when still loading

    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      String url = await storageRef.getDownloadURL();

      imageCache[path] = url;  // store fetched url
      if (!loaded.contains(dexNum)) {
        setState(() {
          totalComplete++;
          loaded.add(dexNum);
          completed.update(region, (val) => val + 1, ifAbsent:() => 1);
        });
      }
      return url;
    } on FirebaseException catch (_) {
      imageCache[path] = 'error';  // mark as failed
      return 'error';
    }
  }

}


class HoverImageTile extends StatefulWidget {
  final String imageUrl;
  final bool isDarkMode;
  final VoidCallback onTap;
  final bool isSelected;

  const HoverImageTile({required this.imageUrl, required this.onTap, required this.isSelected, required this.isDarkMode, super.key});

  @override
  HoverImageTileState createState() => HoverImageTileState();
}

class HoverImageTileState extends State<HoverImageTile> {
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
              color: widget.isSelected ? Colors.black : _isHovered ? Colors.black45 : Colors.black12,
              width: widget.isSelected ? 2 : _isHovered ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovered
                ? widget.isDarkMode
                  ? [const BoxShadow(color: Colors.black26, blurRadius: 3, spreadRadius: 1)]
                  : [const BoxShadow(color: Color.fromARGB(26, 255, 255, 255), blurRadius: 3, spreadRadius: 1)]
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
    case >= 10 && < 100: return '00$num';
    case >= 100 && < 1000: return '0$num';
    case >= 1000 && < 10000: return '$num';
    default: return 'Error: invalid dex num';
  }
}