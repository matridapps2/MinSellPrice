part of 'competitor_bloc.dart';

abstract class CompetitorState extends Equatable {
  const CompetitorState();

  @override
  List<Object> get props => [];
}

class CompetitorInitial extends CompetitorState {}

class CompetitorLoading extends CompetitorState {
  @override
  List<Object> get props => [];
}

class CompetitorLoaded extends CompetitorState {
  final List<CompetitorModel> competitorsList;

  const CompetitorLoaded({
    required this.competitorsList,
  });

  @override
  // TODO: implement props
  List<Object> get props => [competitorsList];
}

class CompetitorError extends CompetitorState {
  final String errorMsg;

  const CompetitorError({
    required this.errorMsg,
  });

  @override
  List<Object> get props => [errorMsg];
}
