part of 'discount_bloc.dart';

abstract class DiscountState extends Equatable {
  const DiscountState();
}

class DiscountInitial extends DiscountState {
  @override
  List<Object> get props => [];
}
class DiscountLoading extends DiscountState {
  @override
  List<Object> get props => [];
}
class DiscountLoaded extends DiscountState {
  final List<Discount> discountList;

  const DiscountLoaded({required this.discountList});

  @override
  List<Object> get props => [discountList];
}
class DiscountError extends DiscountState {
  final String errorMessage;

  const DiscountError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
