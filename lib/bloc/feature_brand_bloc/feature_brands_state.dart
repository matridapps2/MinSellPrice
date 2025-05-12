part of 'feature_brands_bloc.dart';

 class FeatureBrandsState extends Equatable {
  const FeatureBrandsState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

 class FeatureBrandsInitial extends FeatureBrandsState {
  @override
  List<Object> get props => [];
}
 class FeatureBrandsLoaded extends FeatureBrandsState {
   final List<FeaturedBrandModel> data;


   const FeatureBrandsLoaded({required this.data});

  @override
  List<Object> get props => [];
}
 class FeatureBrandsError extends FeatureBrandsState {
  @override
  List<Object> get props => [];
}
