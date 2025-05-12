import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/bloc/feature_brand_bloc/model/feature_brands_model.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'feature_brands_event.dart';
part 'feature_brands_state.dart';

class FeatureBrandsBloc extends Bloc<FeatureBrandsEvent, FeatureBrandsState> {
  FeatureBrandsBloc() : super(FeatureBrandsInitial()) {
    on<FeatureBrandsEvent>((event, emit) async {
      try {
        final data = await NetworkCalls().returnFeaturedBrands();

        List<FeaturedBrandModel> dataList = List<FeaturedBrandModel>.from(
          (data).map(
                (e) => FeaturedBrandModel.fromJson(e),
          ),
        );
        emit(
          FeatureBrandsLoaded(
            data: dataList,
          ),
        );
      } catch (e) {
        emit(
          FeatureBrandsError(),
        );
      }
    });
  }
}
