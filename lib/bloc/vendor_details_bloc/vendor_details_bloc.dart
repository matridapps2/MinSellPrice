
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/model/vendor_dashboard_model.dart';
import 'package:shoppingmegamart/reposotory_services/network_reposotory.dart';

part 'vendor_details_event.dart';

part 'vendor_details_state.dart';

class VendorDetailsBloc extends Bloc<VendorDetailsEvent, VendorDetailsState> {
  VendorDetailsBloc() : super(VendorDetailsInitialState()) {
    on<VendorDetailsFetchingEvent>((event, emit) async {
      // TODO: implement event handler

      emit(VendorDetailsLoadingState());

      try {
        final data = await NetworkCalls()
            .getVendorDetails(vendorId: event.vendorId, date: event.date);

        emit(
          VendorDetailsLoadedState(
            dashboardModel: data,
          ),
        );
      } catch (e) {
        emit(VendorDetailsErrorState(errorMessage: e.toString()));
      }
    });
  }
}
