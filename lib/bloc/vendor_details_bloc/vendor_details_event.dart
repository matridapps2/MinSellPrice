part of 'vendor_details_bloc.dart';

abstract class VendorDetailsEvent extends Equatable {
  const VendorDetailsEvent();
}


class VendorDetailsFetchingEvent extends VendorDetailsEvent{
  final String vendorId,date;


  const VendorDetailsFetchingEvent({required this.vendorId, required this.date});

  @override
  // TODO: implement props
  List<Object?> get props => [vendorId,date];
}