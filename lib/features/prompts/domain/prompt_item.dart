import 'package:flutter/foundation.dart';

/// Represents a prompt in the local prompt library.
@immutable
class PromptItem {
  final String id;
  final String title;
  final String contentPreview;
  final String provider;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool favorite;
  final List<String> tags;
  final int estimatedTokens;

  const PromptItem({
    required this.id,
    required this.title,
    required this.contentPreview,
    required this.provider,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.favorite = false,
    this.tags = const [],
    this.estimatedTokens = 0,
  });

  PromptItem copyWith({
    String? id,
    String? title,
    String? contentPreview,
    String? provider,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? favorite,
    List<String>? tags,
    int? estimatedTokens,
  }) {
    return PromptItem(
      id: id ?? this.id,
      title: title ?? this.title,
      contentPreview: contentPreview ?? this.contentPreview,
      provider: provider ?? this.provider,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favorite: favorite ?? this.favorite,
      tags: tags ?? this.tags,
      estimatedTokens: estimatedTokens ?? this.estimatedTokens,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromptItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
