class TaskEntity {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int xpReward;
  final int coinsReward;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.xpReward,
    required this.coinsReward,
  });
}
