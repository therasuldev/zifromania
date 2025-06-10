
// task_model.dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int xpReward;
  final int coinsReward;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.xpReward,
    required this.coinsReward,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'xpReward': xpReward,
      'coinsReward': coinsReward,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      xpReward: map['xpReward'] ?? 0,
      coinsReward: map['coinsReward'] ?? 0,
    );
  }
}
