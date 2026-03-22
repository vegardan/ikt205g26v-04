class Note {
  final int id;
  String title;
  String text;
  String image;
  DateTime updatedAt;

  Note(this.id, this.title, this.text, this.image, this.updatedAt);

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(json['id'] as int, json['title'] as String, json['text'] as String, json['image'] as String, DateTime.parse(json['updated_at'] as String));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'text': text, 'image': image, 'updated_at': updatedAt.toIso8601String()};
  }
}
