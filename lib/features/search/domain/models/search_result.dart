import 'package:flutter/foundation.dart';

enum SearchSourceType { prompt, history }

@immutable
class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String preview;
  final SearchSourceType sourceType;
  final String provider;
  final DateTime createdAt;
  final String? matchedField;

  const SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.sourceType,
    required this.provider,
    required this.createdAt,
    this.matchedField,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResult &&
        other.id == id &&
        other.sourceType == sourceType;
  }

  @override
  int get hashCode => id.hashCode ^ sourceType.hashCode;

  @override
  String toString() {
    return 'SearchResult(id: $id, title: $title, sourceType: $sourceType)';
  }
}
