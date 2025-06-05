part of 'feature_category_bloc.dart';

class FeatureCategoryState extends Equatable {
  const FeatureCategoryState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FeatureCategoryInitial extends FeatureCategoryState {
  @override
  List<Object> get props => [];
}

class FeatureCategoryLoaded extends FeatureCategoryState {
  final List<FeaturedCategoryModel> data;

  const FeatureCategoryLoaded({required this.data});

  @override
  List<Object> get props => [];
}

class FeatureCategoryError extends FeatureCategoryState {
  final String errorMessage = 'Server under maintenance';
  @override
  List<Object> get props => [];
}
