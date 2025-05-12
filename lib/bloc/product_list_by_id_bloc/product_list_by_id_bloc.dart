import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/app.dart';
import 'package:shoppingmegamart/model/product_list_model.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';
import 'package:shoppingmegamart/services/extra_functions.dart';

part 'product_list_by_id_event.dart';
part 'product_list_by_id_state.dart';

class ProductListByIdBloc
    extends Bloc<ProductListByIdEvent, ProductListByIdState> {
  ProductListByIdBloc() : super(ProductListByIdInitial()) {
    on<ProductListByIdLoadingEvent>((event, emit) async {
      print(
          'ProductListByIdBloc: Loading event received with vendorId: ${event.vendorId}');
      emit(ProductListByIdLoading());
      try {
        final List<ProductListModel> list = [];

        event.fromSearchScreen == true
            ? await NetworkCalls().getProductListBySearch(
                afSku: '',
                vendorId: event.vendorId,
                hpSku: '',
                productMpn: event.productMpn ?? '',
                productName: event.productName ?? '',
              )
            : event.brandProductsEnabled == true
                ? await NetworkCalls().getProductListByBrandId(
                    brandId: event.productName!,
                    vendorId: '${AppInfo.kVendorId}',
                    date: event.date)
                : event.featuredProducts == true
                    ? await NetworkCalls()
                        .getFeaturedProduct(vendorId: event.vendorId)
                    : await NetworkCalls()
                        .getProductListByCategoryId(categoryId: event.dataId);

        print(
            'ProductListByIdBloc: Data loaded successfully. Product count: ${list.length}');
        emit(ProductListByIdLoadedState(
            productList: list
                .where((element) => !element.firstVendorPrice.contains('--'))
                .toList()));
      } catch (e) {
        print('ProductListByIdBloc Error: $e');
        emit(ProductListByIdErrorState(errorMessage: e.toString()));
      }
    });

    on<ProductListByIdSortEvent>((event, emit) async {
      if (state is ProductListByIdLoadedState) {
        try {
          final List<ProductListModel> sortedList =
              List.of((state as ProductListByIdLoadedState).productList);

          if (event.priceSortingOption != null) {
            if (event.priceSortingOption == 1) {
              sortedList.sort((a, b) =>
                  extractDoubleFromString(a.vendorPriceFinalPrice).compareTo(
                      extractDoubleFromString(b.vendorPriceFinalPrice)));
            } else {
              sortedList.sort((a, b) =>
                  extractDoubleFromString(b.vendorPriceFinalPrice).compareTo(
                      extractDoubleFromString(a.vendorPriceFinalPrice)));
            }
          }
          emit(ProductListByIdLoadedState(productList: sortedList));
        } catch (e) {
          emit(ProductListByIdErrorState(errorMessage: e.toString()));
        }
      }
    });
  }
}
