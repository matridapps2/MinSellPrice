part of 'competitor_bloc.dart';

abstract class CompetitorEvent extends Equatable {
  const CompetitorEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CompetitorItemsLoaded extends CompetitorEvent {
  final int vendorId;
  final String date;

  const CompetitorItemsLoaded({
    required this.vendorId,
    required this.date,
  });

  @override
  List<Object> get props => [
        vendorId,
        date,
      ];
}
