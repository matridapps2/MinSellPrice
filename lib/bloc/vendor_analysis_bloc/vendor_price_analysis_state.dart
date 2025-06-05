part of 'vendor_price_analysis_bloc.dart';

@immutable
abstract class VendorPriceAnalysisState extends Equatable {
  @override
  List<Object> get props {
    return [];
  }
}

class VendorPriceAnalysisInitial extends VendorPriceAnalysisState {}

class VendorPriceAnalysisLoading extends VendorPriceAnalysisState {}

class VendorPriceAnalysisLoaded extends VendorPriceAnalysisState {
  final VendorPriceAnalyisModel vendorModel;

  VendorPriceAnalysisLoaded({required this.vendorModel});
  @override
  // TODO: implement props
  List<Object> get props => [vendorModel];
}

class VendorPriceAnalysisError extends VendorPriceAnalysisState {
  final String errorMessage;

  VendorPriceAnalysisError({required this.errorMessage});
  @override
  // TODO: implement props
  List<Object> get props => [errorMessage];
}
