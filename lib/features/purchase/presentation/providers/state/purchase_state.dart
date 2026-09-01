import 'package:zifromania/features/purchase/domain/entities/store_product_entity.dart';

class PurchaseState {
  final bool isLoading;
  final List<StoreProductEntity> products;
  final String? errorMessage;
  final String? successMessage;

  const PurchaseState({
    this.isLoading = false,
    this.products = const [],
    this.errorMessage,
    this.successMessage,
  });

  PurchaseState copyWith({
    bool? isLoading,
    List<StoreProductEntity>? products,
    String? errorMessage,
    String? successMessage,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
