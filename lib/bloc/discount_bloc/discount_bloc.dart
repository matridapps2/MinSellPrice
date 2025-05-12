

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoppingmegamart/model/discount_model.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'discount_event.dart';

part 'discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  DiscountBloc() : super(DiscountInitial()) {
    on<DiscountLoadingEvent>(
      (event, emit) async {
        emit(DiscountLoading());
        try {
          final List<Discount> discountList =
              await NetworkCalls().returnDiscountTableData(
            vendorId: event.vendorId,
            date: event.date,
            // dataId: event.dataId,
          );

          emit(
            DiscountLoaded(
              discountList: discountList,
            ),
          );
        } catch (e) {
          emit(
            DiscountError(
              errorMessage: e.toString(),
            ),
          );
        }

        // TODO: implement event handler
      },
    );
  }
}
