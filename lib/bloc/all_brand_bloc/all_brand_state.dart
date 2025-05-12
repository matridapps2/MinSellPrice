part of 'all_brand_bloc.dart';

abstract class AllBrandState extends Equatable {
  const AllBrandState();
}

class AllBrandInitialState extends AllBrandState {
  @override
  List<Object> get props => [];
}
class AllBrandLoadingState extends AllBrandState {
  @override
  List<Object> get props => [];
}
class AllBrandLoadedState extends AllBrandState {
  final Map<String,dynamic> data;

  const AllBrandLoadedState({required this.data});

  @override
  List<Object> get props => [data];
}
class AllBrandErrorState extends AllBrandState {
  final String  errorMessage;

  const AllBrandErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
