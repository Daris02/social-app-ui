enum Direction {
  DD('DD', 'Direction de la Décentralisation'),
  DF('DF', 'Direction Financière'),
  DLP('DLP', 'Direction de la Logistique et du Patrimoine'),
  DLE('DLE', 'Direction de la Législation et des Etudes'),
  DARH('DARH', 'Direction Administrative et des Ressources Humaines'),
  DSIC('DSIC', 'Direction du Système d\'Information et de la Communication');

  final String code;
  final String description;

  const Direction(this.code, this.description);

  @override
  String toString() => code;

  static Direction? fromCode(String code) {
    try {
      return Direction.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }
}
