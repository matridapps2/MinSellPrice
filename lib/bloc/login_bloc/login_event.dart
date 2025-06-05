part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginUserEvent extends LoginEvent {
  final String loginDataAsMap, fcmToken;
  final Database database;

  const LoginUserEvent(
      {required this.database,
      required this.loginDataAsMap,
      required this.fcmToken});

  @override
  // TODO: implement props
  List<Object?> get props => [loginDataAsMap];
}
