class ScrapbookItem {
  final String id;
  final String type; // photo, note, sticker
  final String content;
  final double xPosition;
  final double yPosition;
  final double rotation;
  final double width;
  final double height;
  final DateTime dateAdded;

  ScrapbookItem({
    required this.id,
    required this.type,
    required this.content,
    required this.xPosition,
    required this.yPosition,
    required this.rotation,
    required this.width,
    required this.height,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'xPosition': xPosition,
      'yPosition': yPosition,
      'rotation': rotation,
      'width': width,
      'height': height,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory ScrapbookItem.fromJson(Map<String, dynamic> json) {
    return ScrapbookItem(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      xPosition: (json['xPosition'] as num).toDouble(),
      yPosition: (json['yPosition'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );
  }
}
