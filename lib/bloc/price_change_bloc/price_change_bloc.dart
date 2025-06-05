import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/model/price_change_model.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'price_change_event.dart';

part 'price_change_state.dart';

class PriceChangeBloc extends Bloc<PriceChangeEvent, PriceChangeState> {
  PriceChangeBloc() : super(PriceChangeInitialState()) {
    on<PriceChangeLoadingEvent>((event, emit) async {
      emit(PriceChangeLoadingState());
      try {
        final priceChangeModel = await NetworkCalls()
            .getPriceChangeDetails(vendorId: event.vendorId, date: event.date);
        emit(PriceChangeLoadedState(priceChangeModel: priceChangeModel));
      } catch (e) {
        emit(
          PriceChangeErrorState(
            errorMessage: e.toString(),
          ),
        );
      }
      // TODO: implement event handler
    });
  }
}
