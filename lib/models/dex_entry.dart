import 'package:json_annotation/json_annotation.dart';
import 'type.dart';
import 'region.dart';

part 'dex_entry.g.dart';

@JsonSerializable()
class DexEntry {
  @JsonKey(name: 'dex number')
  final int dexNum;
  final List<Form> forms;
  // @JsonKey(name: 'gimmick forms')
  // final List<dynamic> gimmickForms; // TODO
  @JsonKey(name: 'experience group')
  final String expGroup;
  @JsonKey(name: 'base experience yield')
  final int expYield;
  @JsonKey(name: 'minimum spawn level')
  final int minSpawnLvl;
  @JsonKey(name: 'gendered')
  final bool genderKnown;
  @JsonKey(name: 'male:female ratio')
  final double? genderRatio;
  @JsonKey(name: 'catch rate')
  final int catchRate;
  @JsonKey(name: 'flee rate')
  final int fleeRate;

  DexEntry({
    required this.dexNum,
    required this.forms,
    // required this.gimmickForms,
    required this.expGroup,
    required this.expYield,
    required this.minSpawnLvl,
    required this.genderKnown,
    this.genderRatio,
    required this.catchRate,
    required this.fleeRate,
  });

  factory DexEntry.fromJson(Map<String, dynamic> json) => _$DexEntryFromJson(json);
  Map<String, dynamic> toJson() => _$DexEntryToJson(this);
}

@JsonSerializable()
class Form {
  final double key;
  int unlockStatus;
  final String name;
  final List<MonType> type;
  final String category;
  final Region region;
  @JsonKey(name: 'special form')
  final String? specialForm;  // can be null
  @JsonKey(name: 'valid')
  final bool validSpawn;
  @JsonKey(name: 'evolution')
  final List<Evolutions> evolutions;
  @JsonKey(name: 'base stats')
  final List<Stats> stats;
  final double height;
  final double weight;
  final String entry;
  @JsonKey(name: 'image asset m')
  final String imageAssetM;
  @JsonKey(name: 'image asset f')
  final String imageAssetF;
  @JsonKey(name: 'image asset m shiny')
  final String imageAssetMShiny;
  @JsonKey(name: 'image asset f shiny')
  final String imageAssetFShiny;

  Form({
    required this.key,
    this.unlockStatus = 0,
    required this.name,
    required this.type,
    required this.category,
    required this.region,
    this.specialForm,
    required this.validSpawn,
    required this.evolutions,
    required this.stats,
    required this.height,
    required this.weight,
    required this.entry,
    required this.imageAssetM,
    required this.imageAssetF,
    required this.imageAssetMShiny,
    required this.imageAssetFShiny,
  });

  factory Form.fromJson(Map<String, dynamic> json) => _$FormFromJson(json);
  Map<String, dynamic> toJson() => _$FormToJson(this);

  set status(int newStatus) {
    if (newStatus < 0 || newStatus > 3) {
      throw Exception('Invalid status');
    }
    unlockStatus = newStatus;
  }
}

@JsonSerializable()
class Evolutions {
  final List<NextEvo> next;
  @JsonKey(name: 'prev')
  final double? prevKey;

  Evolutions({required this.next, this.prevKey});

  factory Evolutions.fromJson(Map<String, dynamic> json) => _$EvolutionsFromJson(json);
  Map<String, dynamic> toJson() => _$EvolutionsToJson(this);
}

@JsonSerializable()
class NextEvo {
  final double key;
  final int? level;
  final List<String> item;

  NextEvo({required this.key, this.level, required this.item});

  factory NextEvo.fromJson(Map<String, dynamic> json) => _$NextEvoFromJson(json);
  Map<String, dynamic> toJson() => _$NextEvoToJson(this);
}

@JsonSerializable()
class Stats {
  final int hp;
  final int atk;
  final int def;
  @JsonKey(name: 'sp.atk')
  final int spAtk;
  @JsonKey(name: 'sp.def')
  final int spDef;
  final int speed;

  Stats({
    required this.hp,
    required this.atk,
    required this.def,
    required this.spAtk,
    required this.spDef,
    required this.speed,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatsToJson(this);
}