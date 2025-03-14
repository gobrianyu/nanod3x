enum Region { 
  kanto('Kanto'),
  johto('Johto'),
  hoenn('Hoenn'),
  sinnoh('Sinnoh'),
  unova('Unova'),
  kalos('Kalos'),
  alola('Alola'),
  galar('Galar'),
  hisui('Hisui'),
  paldea('Paldea'),
  unknown('Unknown');

  const Region(this.region);
  final String region;

  int get dexSize {
    switch (region.toLowerCase()) {
      case 'kanto': return 151;
      case 'johto': return 100;
      case 'hoenn': return 135;
      case 'sinnoh': return 107;
      case 'unova': return 156;
      case 'kalos': return 72;
      case 'alola': return 86;
      case 'galar': return 89;
      case 'hisui': return 7;
      case 'paldea': return 120;
      case 'unknown': return 2;
    }
    throw Exception('Invalid region');
  }

  int get dexFirst {
    switch (region.toLowerCase()) {
      case 'kanto': return 1;
      case 'johto': return 152;
      case 'hoenn': return 252;
      case 'sinnoh': return 387;
      case 'unova': return 494;
      case 'kalos': return 650;
      case 'alola': return 722;
      case 'galar': return 810;
      case 'hisui': return 899;
      case 'paldea': return 906;
      case 'unknown': return 808;
    }
    throw Exception('Invalid region');
  }
}