// title_model.dart
class TitleModel {
  final String id;
  final String key;
  final String name;
  final String description;
  final String iconUrl;
  final Map<String, dynamic> requirements;

  TitleModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requirements,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'requirements': requirements,
    };
  }

  factory TitleModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TitleModel(
      id: documentId,
      key: map['key'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      requirements: Map<String, dynamic>.from(map['requirements'] ?? {}),
    );
  }
}