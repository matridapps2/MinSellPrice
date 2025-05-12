import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:sqflite/sqflite.dart';

part 'insert_into_database_event.dart';

part 'insert_into_database_state.dart';

class InsertIntoDatabaseBloc
    extends Bloc<InsertQueryEvent, InsertIntoDatabaseState> {
  InsertIntoDatabaseBloc() : super(InsertIntoDatabaseInitial()) {
    on<InsertQueryEvent>((event, emit) async {
      try {

      await DatabaseHelper().insertLogin(event.database, event.data);
        emit(InsertIntoDatabaseInsertedState(id: 0));

      } catch (e) {
        print(e.toString());
        emit(
          InsertIntoDatabaseErrorState(
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
