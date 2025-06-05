import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shoppingmegamart/model/vendor_price_analysis.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'vendor_price_analysis_event.dart';

part 'vendor_price_analysis_state.dart';

class VendorPriceAnalysisBloc
    extends Bloc<VendorPriceAnalysisEvent, VendorPriceAnalysisState> {
  VendorPriceAnalysisBloc() : super(VendorPriceAnalysisInitial()) {
    on<VendorPriceAnalysisLoadingEvent>(
      (event, emit) async {
        emit(VendorPriceAnalysisLoading());

        try {
          final VendorPriceAnalyisModel model =
              await NetworkCalls().getVendorPriceAnalysis(
            vendorId: event.vendorId,
            date: event.date,
          );
          emit(
            VendorPriceAnalysisLoaded(
              vendorModel: model,
            ),
          );
        } catch (e) {
          log("vendor >>> $e");
          emit(
            VendorPriceAnalysisError(
              errorMessage: 'No Data Available',
            ),
          );
        }
      },
    );
  }
}
