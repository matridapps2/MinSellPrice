part of 'brand_price_analysis_bloc.dart';

abstract class BrandPriceAnalysisEvent extends Equatable {
  const BrandPriceAnalysisEvent();
}

class BrandPriceAnalysisLoadingEvent extends BrandPriceAnalysisEvent {
  final int vendorId;
  final String date;

  const BrandPriceAnalysisLoadingEvent(
      {required this.vendorId, required this.date});

  @override
  // TODO: implement props
  List<Object?> get props => [vendorId, date];
}
