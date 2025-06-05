import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'brand_price_analysis_event.dart';

part 'brand_price_analysis_state.dart';

class BrandPriceAnalysisBloc
    extends Bloc<BrandPriceAnalysisEvent, BrandPriceAnalysisState> {
  BrandPriceAnalysisBloc() : super(BrandPriceAnalysisInitial()) {
    on<BrandPriceAnalysisLoadingEvent>((event, emit) async {
      // TODO: implement event handler
      emit(BrandPriceAnalysisLoadingState());
      try {
        final Map<String, dynamic> data =
            await NetworkCalls().getBrandPriceAnalysis(
          vendorId: event.vendorId,
          date: event.date,
        );

        emit(
          BrandPriceAnalysisLoadedState(
            brandModel: data,
          ),
        );
      } catch (e) {
        emit(
          BrandPriceAnalysisErrorState(
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
