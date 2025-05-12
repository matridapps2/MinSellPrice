import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shoppingmegamart/reposotory_services/database/database_functions.dart';
import 'package:sqflite/sqflite.dart';

part 'database_event.dart';

part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseInitEvent, DatabaseState> {
  DatabaseBloc() : super(DatabaseInitialState()) {
    on<DatabaseInitEvent>((event, emit) async {
      try {
        final db = await DatabaseHelper().initDatabase();

        emit(DatabaseLoadedState(database: db));
      } catch (e) {
        emit(
          DatabaseErrorState(
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}
