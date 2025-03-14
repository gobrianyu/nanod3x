import 'package:flutter/material.dart';

enum MonType { 
  water('Water'),
  grass('Grass'),
  fire('Fire'), 
  normal('Normal'), 
  ground('Ground'), 
  rock('Rock'),
  flying('Flying'), 
  psychic('Psychic'), 
  poison('Poison'), 
  fairy('Fairy'), 
  steel('Steel'), 
  bug('Bug'), 
  dragon('Dragon'), 
  dark('Dark'), 
  fighting('Fighting'), 
  electric('Electric'), 
  ice('Ice'), 
  ghost('Ghost');

  const MonType(this.type);
  final String type;
  
  List<MonType> get weaknesses {
    switch(type.toLowerCase()) {
      case 'water': return [grass, electric];
      case 'grass': return [fire, ice, poison, flying, bug];
      case 'fire': return [water, ground, rock];
      case 'normal': return [fighting];
      case 'ground': return [water, grass, ice];
      case 'rock': return [ground, water, grass, fighting, steel];
      case 'flying': return [rock, electric, ice];
      case 'psychic': return [bug, ghost, dark];
      case 'poison': return [ground, psychic];
      case 'fairy': return [steel, poison];
      case 'steel': return [fire, ground, fighting];
      case 'bug': return [fire, rock, flying];
      case 'dragon': return [fairy, dragon, ice];
      case 'dark': return [fighting, fairy, bug];
      case 'fighting': return [psychic, fairy, flying];
      case 'electric': return [ground];
      case 'ice': return [fire, fighting, rock, steel];
      case 'ghost': return [ghost, dark];
    }
    throw Exception('Invalid type');
  }

  List<MonType> get resistances {
    switch(type.toLowerCase()) {
      case 'water': return [fire, water, ice, steel];
      case 'grass': return [water, grass, electric, ground];
      case 'fire': return [fire, grass, ice, bug, steel, fairy];
      case 'normal': return [];
      case 'ground': return [poison, rock];
      case 'rock': return [normal, fire, poison, flying];
      case 'flying': return [grass, fighting, bug];
      case 'psychic': return [fighting, psychic];
      case 'poison': return [grass, fighting, poison, bug, fairy];
      case 'fairy': return [fighting, bug, dark];
      case 'steel': return [normal, grass, ice, flying, psychic, bug, rock, dragon, steel, fairy];
      case 'bug': return [grass, fighting, ground];
      case 'dragon': return [fire, water, grass, electric];
      case 'dark': return [ghost, dark];
      case 'fighting': return [bug, rock, dark];
      case 'electric': return [electric, steel];
      case 'ice': return [ice];
      case 'ghost': return [poison, bug];
    }
    throw Exception('Invalid type');
  }

  List<MonType> get immunities {
    switch(type.toLowerCase()) {
      case 'normal': return [ghost];
      case 'ground': return [electric];
      case 'flying': return [ground];
      case 'ghost': return [normal, fighting];
      case 'dark': return [psychic];
      case 'steel': return [poison];
      case 'fairy': return [dragon];
      default: return [];
    }
  }

  Color get colour {
    switch(type.toLowerCase()) {
      case 'water': return const Color.fromARGB(255, 95, 145, 232);
      case 'grass': return const Color.fromARGB(255, 127, 205, 103);
      case 'fire': return const Color.fromARGB(255, 243, 89, 62);
      case 'normal': return const Color.fromARGB(255, 168, 168, 168);
      case 'ground': return const Color.fromARGB(255, 148, 120, 59);
      case 'rock': return const Color.fromARGB(255, 193, 169, 97);
      case 'flying': return const Color.fromARGB(255, 193, 205, 210);
      case 'psychic': return const Color.fromARGB(255, 231, 101, 161);
      case 'poison': return const Color.fromARGB(255, 157, 115, 223);
      case 'fairy': return const Color.fromARGB(255, 230, 154, 179);
      case 'steel': return const Color.fromARGB(255, 150, 190, 192);
      case 'bug': return const Color.fromARGB(255, 172, 202, 73);
      case 'dragon': return const Color.fromARGB(255, 57, 85, 176);
      case 'dark': return const Color.fromARGB(255, 59, 59, 59);
      case 'fighting': return const Color.fromARGB(255, 158, 66, 66);
      case 'electric': return const Color.fromARGB(255, 223, 203, 24);
      case 'ice': return const Color.fromARGB(255, 142, 211, 230);
      case 'ghost': return const Color.fromARGB(255, 101, 87, 177);
    }
    throw Exception('Invalid type');
  }
}