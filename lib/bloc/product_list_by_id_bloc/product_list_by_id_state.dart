part of 'product_list_by_id_bloc.dart';

abstract class ProductListByIdState extends Equatable {
  const ProductListByIdState();
}

class ProductListByIdInitial extends ProductListByIdState {
  @override
  List<Object> get props => [];
}

class ProductListByIdLoading extends ProductListByIdState {
  @override
  List<Object> get props => [];
}

class ProductListByIdLoadedState extends ProductListByIdState {
  final List<ProductListModel> productList;

  const ProductListByIdLoadedState({required this.productList});

  @override
  List<Object> get props => [productList];
}

class ProductListByIdErrorState extends ProductListByIdState {
  final String errorMessage;

  const ProductListByIdErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
