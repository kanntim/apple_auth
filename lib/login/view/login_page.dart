import 'package:apple_auth/login/bloc/login_bloc.dart';
import 'package:apple_auth/login/view/login_form.dart';
import 'package:apple_id_auth_repository/apple_id_auth_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black54,
          centerTitle: true,
          title: const Text('Apple auth',
              style: TextStyle(fontSize: 30, color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocProvider(
          create: (context) {
            return LoginBloc(
              appleIdAuthRepository:
                  RepositoryProvider.of<AppleIdAuthRepository>(context),
              authenticationRepository:
                  RepositoryProvider.of<AuthenticationRepository>(context),
              userRepository: RepositoryProvider.of<UserRepository>(context),
            );
          },
          child: const LoginForm(),
        ),
      ),
    );
  }
}
