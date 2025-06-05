part of 'database_bloc.dart';

@immutable
abstract class DatabaseState {}

class DatabaseInitialState extends DatabaseState {}

class DatabaseLoadedState extends DatabaseState {
  final Database database;

  DatabaseLoadedState({required this.database});
}

class DatabaseErrorState extends DatabaseState {
  final String errorMessage;
  DatabaseErrorState({required this.errorMessage});
}
