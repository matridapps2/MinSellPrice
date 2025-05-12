part of 'vendor_price_analysis_bloc.dart';

@immutable
abstract class VendorPriceAnalysisEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class VendorPriceAnalysisLoadingEvent extends VendorPriceAnalysisEvent{

  final int vendorId;
  final String date;

  VendorPriceAnalysisLoadingEvent({required this.vendorId, required this.date});

@override
  // TODO: implement props
  List<Object?> get props => [vendorId,date];
}