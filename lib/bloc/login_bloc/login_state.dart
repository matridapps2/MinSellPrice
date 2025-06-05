part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitialState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginLoadingState extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginLoadedState extends LoginState {
  final String loginData;

  const LoginLoadedState({required this.loginData});

  @override
  List<Object> get props => [loginData];
}

class LoginErrorState extends LoginState {
  final String errorMsg;

  const LoginErrorState({required this.errorMsg});

  @override
  List<Object> get props => [errorMsg];
}
