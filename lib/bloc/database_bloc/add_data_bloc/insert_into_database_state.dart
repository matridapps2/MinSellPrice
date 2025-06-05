part of 'insert_into_database_bloc.dart';

@immutable
abstract class InsertIntoDatabaseState {}

class InsertIntoDatabaseInitial extends InsertIntoDatabaseState {}

class InsertIntoDatabaseInsertedState extends InsertIntoDatabaseState {
  final int id;

  InsertIntoDatabaseInsertedState({required this.id});
}

class InsertIntoDatabaseErrorState extends InsertIntoDatabaseState {
  final String errorMessage;

  InsertIntoDatabaseErrorState({required this.errorMessage});
}
