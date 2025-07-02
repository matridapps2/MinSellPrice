import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:minsellprice/model/featured_category_model.dart';
import 'package:minsellprice/reposotory_services/network_reposotory.dart';

part 'feature_category_event.dart';
part 'feature_category_state.dart';

class FeatureCategoryBloc
    extends Bloc<FeatureCategoryEvent, FeatureCategoryState> {
  FeatureCategoryBloc() : super(FeatureCategoryInitial()) {
    on<FeatureCategoryEvent>((event, emit) async {
      try {
        final data = await NetworkCalls().returnFeaturedCategory();

        List<FeaturedCategoryModel> dataList = List<FeaturedCategoryModel>.from(
          (data).map(
            (e) => FeaturedCategoryModel.fromJson(e),
          ),
        );
        emit(
          FeatureCategoryLoaded(
            data: dataList,
          ),
        );
      } catch (e) {
        emit(
          FeatureCategoryError(),
        );
      }
    });
  }
}
