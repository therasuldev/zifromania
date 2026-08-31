class TitleEntity {
  final String id;
  final String key;
  final String name;
  final String description;
  final String iconUrl;
  final Map<String, dynamic> requirements;

  const TitleEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requirements,
  });
}
