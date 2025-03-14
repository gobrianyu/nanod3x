import 'dart:convert';

import 'dex_entry.dart';

class DexDB{
  final List<DexEntry> _entries;
  
  List<DexEntry> get all{
    return List<DexEntry>.from(_entries, growable: false);
  }

  DexDB.initializeFromJson(String jsonString) : _entries = _decodeDexListJson(jsonString);

  static List<DexEntry> _decodeDexListJson(String jsonString){
    final list = (jsonDecode(jsonString) as List).map((entry) {
      return DexEntry.fromJson(entry);
    }).toList();
    return list;
  }
}