import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shoppingmegamart/model/competitor_model.dart';

part 'competitor_event.dart';

part 'competitor_state.dart';

class CompetitorBloc extends Bloc<CompetitorEvent, CompetitorState> {
  CompetitorBloc() : super(CompetitorInitial()) {
    on<CompetitorItemsLoaded>((event, emit) async {
      // TODO: implement event handler
      emit(CompetitorLoading());

      try {
        // final List<CompetitorModel> list =
        //     await ApiRepository(networkCalls: NetworkCalls()).getCompetitors(
        //   vendorId: event.vendorId,
        //   date: event.date,
        // );
        //
        // print(list.length);
        // emit(CompetitorLoaded(competitorsList: list));
      } catch (e) {
        emit(CompetitorError(errorMsg: e.toString()));
      }
    });
  }
}
