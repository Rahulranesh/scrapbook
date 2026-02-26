import 'scrapbook_item.dart';

class ScrapbookBoard {
  final String id;
  final String title;
  final String theme; // cork, felt, album
  final List<ScrapbookItem> items;
  final DateTime createdDate;
  final bool isFavorite;

  ScrapbookBoard({
    required this.id,
    required this.title,
    required this.theme,
    required this.items,
    required this.createdDate,
    this.isFavorite = false,
  });

  ScrapbookBoard copyWith({
    String? id,
    String? title,
    String? theme,
    List<ScrapbookItem>? items,
    DateTime? createdDate,
    bool? isFavorite,
  }) {
    return ScrapbookBoard(
      id: id ?? this.id,
      title: title ?? this.title,
      theme: theme ?? this.theme,
      items: items ?? this.items,
      createdDate: createdDate ?? this.createdDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'theme': theme,
      'items': items.map((item) => item.toJson()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory ScrapbookBoard.fromJson(Map<String, dynamic> json) {
    return ScrapbookBoard(
      id: json['id'] as String,
      title: json['title'] as String,
      theme: json['theme'] as String,
      items: (json['items'] as List)
          .map((item) => ScrapbookItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdDate: DateTime.parse(json['createdDate'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
