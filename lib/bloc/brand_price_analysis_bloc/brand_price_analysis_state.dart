part of 'brand_price_analysis_bloc.dart';

abstract class BrandPriceAnalysisState extends Equatable {
  const BrandPriceAnalysisState();
}

class BrandPriceAnalysisLoadingState extends BrandPriceAnalysisState {
  @override
  List<Object> get props => [];
}
class BrandPriceAnalysisLoadedState extends BrandPriceAnalysisState {

  final Map<String ,dynamic> brandModel;


  const BrandPriceAnalysisLoadedState({required this.brandModel});

  @override
  List<Object> get props => [
    brandModel
  ];
}
class BrandPriceAnalysisErrorState extends BrandPriceAnalysisState {

  final String errorMessage;


  const BrandPriceAnalysisErrorState({required this.errorMessage});

  @override
  List<Object> get props => [
    errorMessage
  ];
}
class BrandPriceAnalysisInitial extends BrandPriceAnalysisState{
  @override
  // TODO: implement props
  List<Object?> get props => [];

}
