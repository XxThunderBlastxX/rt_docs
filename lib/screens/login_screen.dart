import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../colors.dart';
import '../repository/auth_repository.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signinWithGoogle(WidgetRef ref, BuildContext context) async {
    final snackBar = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errModel = await ref.read(authRepoProvider).googleSignIn();

    if (errModel.err == null) {
      ref.read(userProvider.notifier).update((state) => errModel.data);
      navigator.replace('/');
    } else {
      snackBar.showSnackBar(
        SnackBar(
          content: Text(errModel.err!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signinWithGoogle(ref, context),
          icon: Image.asset(
            'assets/images/g-logo.png',
            height: 25,
            width: 25,
          ),
          label: const Text(
            'Sign In with Google',
            style: TextStyle(
              color: kBlackColor,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 50),
            backgroundColor: kWhiteColor,
          ),
        ),
      ),
    );
  }
}
