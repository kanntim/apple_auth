part of 'login_bloc.dart';

sealed class LoginEvent {
  const LoginEvent();
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

final class LoginTestCrypto extends LoginEvent {
  const LoginTestCrypto();
}
