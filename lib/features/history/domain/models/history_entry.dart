/// Immutable domain model representing a single AI interaction record.
class HistoryEntry {
  final String id;
  final String provider;
  final String promptPreview;
  final int tokensUsed;
  final DateTime timestamp;

  const HistoryEntry({
    required this.id,
    required this.provider,
    required this.promptPreview,
    required this.tokensUsed,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'HistoryEntry(id: $id, provider: $provider, tokens: $tokensUsed)';
}
