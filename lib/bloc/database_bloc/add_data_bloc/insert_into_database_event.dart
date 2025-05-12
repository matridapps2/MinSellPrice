part of 'insert_into_database_bloc.dart';

@immutable
abstract class InsertIntoDatabaseEvent {}


class InsertQueryEvent extends InsertIntoDatabaseEvent{

  final Database database;

  final Map<String , dynamic> data;


  InsertQueryEvent({required this.database, required this.data});
}
