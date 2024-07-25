import 'package:apple_auth/core/widgets/apple_id_auth/apple_sign_in.dart';
import 'package:apple_auth/login/bloc/login_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RealizationType { dart, native }

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
              const SnackBar(
                content: Text(
                  'Authentication Failure',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10))),
                padding: EdgeInsets.only(bottom: 60, top: 10),
              ),
            );
        }
      },
      builder: (context, state) {
        final workStatus = (state.status == SubmissionStatus.success)
            ? (state.serverAnswer?.workStatus as WorkStatus)
            : null;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select auth implementaion: ',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<RealizationType>(
                        segments: segments,
                        selected: {state.realization},
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          backgroundColor: WidgetStateColor.resolveWith(
                              (Set<WidgetState> states) {
                            return states.contains(WidgetState.selected)
                                ? Colors.black26
                                : Colors.black12;
                          }),
                          foregroundColor: WidgetStateColor.resolveWith(
                              (Set<WidgetState> states) {
                            return states.contains(WidgetState.selected)
                                ? Colors.white
                                : Colors.black;
                          }),
                        ),
                        onSelectionChanged: (selection) {
                          context
                              .read<LoginBloc>()
                              .add(LoginRealizationChanged(selection.first));
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  workStatus?.udid ?? state.serverAnswer?.errorStatus ?? '',
                  style: const TextStyle(color: Colors.black),
                ),
                _LoginButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  static List<ButtonSegment<RealizationType>> get segments => [
        const ButtonSegment(
          label: Text('Dart', style: TextStyle(fontSize: 16)),
          value: RealizationType.dart,
        ),
        const ButtonSegment(
          label: Text('Native', style: TextStyle(fontSize: 16)),
          value: RealizationType.native,
        ),
      ];
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Center(
          child: Column(
            children: [
              (state.status == SubmissionStatus.inProgress)
                  ? const CircularProgressIndicator()
                  : AppleSignInButton(
                      key: const Key('loginForm_continue_raisedButton'),
                      onPressed: () async {
                        context.read<LoginBloc>().add(const LoginSubmitted());
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
