import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'all_brand_event.dart';

part 'all_brand_state.dart';

class AllBrandBloc extends Bloc<AllBrandLoadingEvent, AllBrandState> {
  AllBrandBloc() : super(AllBrandInitialState()) {
    on<AllBrandLoadingEvent>((event, emit) async {
      emit(AllBrandLoadingState());
      try {
        final receivedData = await NetworkCalls().returnAllBrandData(
          vendorId: event.vendorId,
          date: event.date,
        );

        // if (kDebugMode) {
        //   print();
        // }

        // List<AllBrandModel> data = List<AllBrandModel>.from(
        //   receivedData.values.toList().map(
        //         (e) => AllBrandModel.fromJson(e),
        //       ),
        // );
        emit(AllBrandLoadedState(data: jsonDecode(receivedData)));
      } catch (e) {
        log(e.toString());
        emit(const AllBrandErrorState(errorMessage: 'No Brands Found'));
      }
    });
  }
}
