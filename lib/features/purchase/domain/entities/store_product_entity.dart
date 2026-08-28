class StoreProductEntity {
  final String id;
  final String title;
  final String description;
  final String price;
  final bool isSubscription;

  const StoreProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isSubscription,
  });
}