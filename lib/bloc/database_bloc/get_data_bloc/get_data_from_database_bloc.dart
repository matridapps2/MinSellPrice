
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'get_data_from_database_event.dart';
part 'get_data_from_database_state.dart';

class GetDataFromDatabaseBloc extends Bloc<GetDataFromDatabaseEvent, GetDataFromDatabaseState> {
  GetDataFromDatabaseBloc() : super(GetDataFromDatabaseInitial()) {
    on<GetDataFromDatabaseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
