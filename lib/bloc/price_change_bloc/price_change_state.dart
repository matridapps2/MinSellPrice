part of 'price_change_bloc.dart';

abstract class PriceChangeState extends Equatable {
  const PriceChangeState();
}

class PriceChangeInitialState extends PriceChangeState {
  @override
  List<Object> get props => [];
}
class PriceChangeLoadingState extends PriceChangeState {
  @override
  List<Object> get props => [];
}
class PriceChangeLoadedState extends PriceChangeState {

  final PriceChangeModel priceChangeModel;


  const PriceChangeLoadedState({required this.priceChangeModel});

  @override
  List<Object> get props => [];
}
class PriceChangeErrorState extends PriceChangeState {
  final String errorMessage;

  const PriceChangeErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
