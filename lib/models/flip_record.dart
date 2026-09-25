class FlipRecord {
  final int index;
  final bool isKepala;
  final DateTime timestamp;
  final bool? guessedKepala;

  const FlipRecord({
    required this.index,
    required this.isKepala,
    required this.timestamp,
    this.guessedKepala,
  });

  String get sideName => isKepala ? 'Kepala' : 'Ekor';
  String get sideEnName => isKepala ? 'Heads' : 'Tails';

  bool? get isGuessedCorrectly {
    if (guessedKepala == null) return null;
    return guessedKepala == isKepala;
  }

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
