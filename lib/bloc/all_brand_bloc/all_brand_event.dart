part of 'all_brand_bloc.dart';

abstract class AllBrandEvent extends Equatable {
  const AllBrandEvent();
}

class AllBrandLoadingEvent extends AllBrandEvent {
  final String date, vendorId;

  const AllBrandLoadingEvent({required this.date, required this.vendorId});

  @override
  // TODO: implement props
  List<Object?> get props => [vendorId, date];
}
