part of 'vendor_details_bloc.dart';

abstract class VendorDetailsState extends Equatable {
  const VendorDetailsState();
}

class VendorDetailsInitialState extends VendorDetailsState {
  @override
  List<Object> get props => [];
}

class VendorDetailsLoadingState extends VendorDetailsState {
  @override
  List<Object> get props => [];
}

class VendorDetailsLoadedState extends VendorDetailsState {
  final VendorDashboardModel dashboardModel;

  const VendorDetailsLoadedState({required this.dashboardModel});

  @override
  List<Object> get props => [];
}

class VendorDetailsErrorState extends VendorDetailsState {
  final String errorMessage;

  const VendorDetailsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
