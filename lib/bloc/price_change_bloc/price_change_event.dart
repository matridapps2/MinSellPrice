part of 'price_change_bloc.dart';

abstract class PriceChangeEvent extends Equatable {
  const PriceChangeEvent();
}


class PriceChangeLoadingEvent extends PriceChangeEvent{


  final String vendorId,date;


  const PriceChangeLoadingEvent({required this.vendorId, required this.date});

  @override
  // TODO: implement props
  List<Object?> get props => [vendorId,date];
}