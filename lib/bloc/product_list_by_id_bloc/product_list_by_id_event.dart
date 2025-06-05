part of 'product_list_by_id_bloc.dart';

abstract class ProductListByIdEvent extends Equatable {
  const ProductListByIdEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ProductListByIdLoadingEvent extends ProductListByIdEvent {
  final String vendorId, date, dataId;
  final String? brandKey, productMpn, productName;
  final bool featuredProducts,
      fromSearchScreen,
      brandProductsEnabled,
      isCategory;
  final Map<String, String>? aiEngineData;

  const ProductListByIdLoadingEvent({
    required this.vendorId,
    required this.date,
    required this.dataId,
    this.brandKey,
    this.aiEngineData,
    this.productMpn,
    this.productName,
    required this.featuredProducts,
    required this.isCategory,
    required this.fromSearchScreen,
    required this.brandProductsEnabled,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        vendorId,
        date,
        dataId,
        featuredProducts,
        brandKey,
        fromSearchScreen,
        productMpn,
        productName,
        brandProductsEnabled,
        aiEngineData,
      ];
}

class ProductListByIdSortEvent extends ProductListByIdEvent {
  final List<String> filterVendor;
  final int? priceSortingOption;

  const ProductListByIdSortEvent(
      {required this.filterVendor, this.priceSortingOption});
}
