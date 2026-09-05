import 'package:zifromania/features/title/domain/entities/title_entity.dart';

class TitleModel extends TitleEntity {
  const TitleModel({
    required super.id,
    required super.key,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.requirements,
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
      key: map['key'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      requirements: Map<String, dynamic>.from(map['requirements'] as Map<String, dynamic>? ?? {}),
    );
  }
}
