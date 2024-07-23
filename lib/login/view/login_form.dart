import 'package:apple_auth/apple_sign_in.dart';
import 'package:apple_auth/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == SubmissionStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
      },
      builder: (context, state) {
        return Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.serverAnswer?.workStatus?.udid ??
                    state.serverAnswer?.errorStatus ??
                    '-',
                style: const TextStyle(color: Colors.black),
              ),
              MaterialButton(
                onPressed: () async {
                  context.read<LoginBloc>().add(const LoginTestCrypto());
                  /*final result = await requestFunc3();
                setState(() {
                  serverAnswerModel = result;
                });*/
                },
                color: Colors.red,
                child: const Text('Generate RSA Key Pair'),
              ),
              _LoginButton(),
            ],
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return (state.status == SubmissionStatus.inProgress)
            ? const CircularProgressIndicator()
            : AppleSignInButton(
                key: const Key('loginForm_continue_raisedButton'),
                onPressed: () async {
                  context.read<LoginBloc>().add(const LoginSubmitted());
                },
              );
      },
    );
  }
}
