// task_model.dart
import 'package:zifromania/features/task/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconUrl,
    required super.xpReward,
    required super.coinsReward,
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
