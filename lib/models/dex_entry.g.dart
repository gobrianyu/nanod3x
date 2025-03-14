// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dex_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DexEntry _$DexEntryFromJson(Map<String, dynamic> json) => DexEntry(
      dexNum: (json['dex number'] as num).toInt(),
      forms: (json['forms'] as List<dynamic>)
          .map((e) => Form.fromJson(e as Map<String, dynamic>))
          .toList(),
      expGroup: json['experience group'] as String,
      expYield: (json['base experience yield'] as num).toInt(),
      minSpawnLvl: (json['minimum spawn level'] as num).toInt(),
      genderKnown: json['gendered'] as bool,
      genderRatio: (json['male:female ratio'] as num?)?.toDouble(),
      catchRate: (json['catch rate'] as num).toInt(),
      fleeRate: (json['flee rate'] as num).toInt(),
    );

Map<String, dynamic> _$DexEntryToJson(DexEntry instance) => <String, dynamic>{
      'dex number': instance.dexNum,
      'forms': instance.forms,
      'experience group': instance.expGroup,
      'base experience yield': instance.expYield,
      'minimum spawn level': instance.minSpawnLvl,
      'gendered': instance.genderKnown,
      'male:female ratio': instance.genderRatio,
      'catch rate': instance.catchRate,
      'flee rate': instance.fleeRate,
    };

Form _$FormFromJson(Map<String, dynamic> json) => Form(
      key: (json['key'] as num).toDouble(),
      unlockStatus: (json['unlockStatus'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      type: (json['type'] as List<dynamic>)
          .map((e) => $enumDecode(_$TypeEnumMap, e))
          .toList(),
      category: json['category'] as String,
      region: $enumDecode(_$RegionEnumMap, json['region']),
      specialForm: json['special form'] as String?,
      validSpawn: json['valid'] as bool,
      evolutions: (json['evolution'] as List<dynamic>)
          .map((e) => Evolutions.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: (json['base stats'] as List<dynamic>)
          .map((e) => Stats.fromJson(e as Map<String, dynamic>))
          .toList(),
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      entry: json['entry'] as String,
      imageAssetM: json['image asset m'] as String,
      imageAssetF: json['image asset f'] as String,
      imageAssetMShiny: json['image asset m shiny'] as String,
      imageAssetFShiny: json['image asset f shiny'] as String,
    );

Map<String, dynamic> _$FormToJson(Form instance) => <String, dynamic>{
      'key': instance.key,
      'unlockStatus': instance.unlockStatus,
      'name': instance.name,
      'type': instance.type.map((e) => _$TypeEnumMap[e]!).toList(),
      'category': instance.category,
      'region': _$RegionEnumMap[instance.region]!,
      'special form': instance.specialForm,
      'valid': instance.validSpawn,
      'evolution': instance.evolutions,
      'base stats': instance.stats,
      'height': instance.height,
      'weight': instance.weight,
      'entry': instance.entry,
      'image asset m': instance.imageAssetM,
      'image asset f': instance.imageAssetF,
      'image asset m shiny': instance.imageAssetMShiny,
      'image asset f shiny': instance.imageAssetFShiny,
    };

const _$TypeEnumMap = {
  MonType.water: 'Water',
  MonType.grass: 'Grass',
  MonType.fire: 'Fire',
  MonType.normal: 'Normal',
  MonType.ground: 'Ground',
  MonType.rock: 'Rock',
  MonType.flying: 'Flying',
  MonType.psychic: 'Psychic',
  MonType.poison: 'Poison',
  MonType.fairy: 'Fairy',
  MonType.steel: 'Steel',
  MonType.bug: 'Bug',
  MonType.dragon: 'Dragon',
  MonType.dark: 'Dark',
  MonType.fighting: 'Fighting',
  MonType.electric: 'Electric',
  MonType.ice: 'Ice',
  MonType.ghost: 'Ghost',
};

const _$RegionEnumMap = {
  Region.kanto: 'Kanto',
  Region.johto: 'Johto',
  Region.hoenn: 'Hoenn',
  Region.sinnoh: 'Sinnoh',
  Region.unova: 'Unova',
  Region.kalos: 'Kalos',
  Region.alola: 'Alola',
  Region.galar: 'Galar',
  Region.hisui: 'Hisui',
  Region.paldea: 'Paldea',
  Region.unknown: 'Unknown',
};

Evolutions _$EvolutionsFromJson(Map<String, dynamic> json) => Evolutions(
      next: (json['next'] as List<dynamic>)
          .map((e) => NextEvo.fromJson(e as Map<String, dynamic>))
          .toList(),
      prevKey: (json['prev'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EvolutionsToJson(Evolutions instance) =>
    <String, dynamic>{
      'next': instance.next,
      'prev': instance.prevKey,
    };

NextEvo _$NextEvoFromJson(Map<String, dynamic> json) => NextEvo(
      key: (json['key'] as num).toDouble(),
      level: (json['level'] as num?)?.toInt(),
      item: (json['item'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$NextEvoToJson(NextEvo instance) => <String, dynamic>{
      'key': instance.key,
      'level': instance.level,
      'item': instance.item,
    };

Stats _$StatsFromJson(Map<String, dynamic> json) => Stats(
      hp: (json['hp'] as num).toInt(),
      atk: (json['atk'] as num).toInt(),
      def: (json['def'] as num).toInt(),
      spAtk: (json['sp.atk'] as num).toInt(),
      spDef: (json['sp.def'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
    );

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'hp': instance.hp,
      'atk': instance.atk,
      'def': instance.def,
      'sp.atk': instance.spAtk,
      'sp.def': instance.spDef,
      'speed': instance.speed,
    };
