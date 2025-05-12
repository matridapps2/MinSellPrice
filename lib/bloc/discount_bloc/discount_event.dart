part of 'discount_bloc.dart';

abstract class DiscountEvent extends Equatable {
  const DiscountEvent();
}

class DiscountLoadingEvent extends DiscountEvent {
  final String vendorId, date;

  const DiscountLoadingEvent({
    required this.date,
    required this.vendorId,
    // required this.dataId,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [date, vendorId];
}
