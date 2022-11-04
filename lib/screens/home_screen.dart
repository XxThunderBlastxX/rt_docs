import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../colors.dart';
import '../repository/auth_repository.dart';
import '../repository/document_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepoProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errModel = await ref.read(documentRepoProvider).createDocument(token);

    if (errModel.data != null) {
      navigator.push('/document/${errModel.data.id}');
    } else {
      snackbar.showSnackBar(
        SnackBar(
          content: Text(errModel.err!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTealColor,
        actions: [
          IconButton(
            onPressed: () => createDocument(ref, context),
            icon: const Icon(Icons.add_box_rounded),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(
              Icons.logout_rounded,
              color: kRed,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(ref.watch(userProvider)!.uid),
      ),
    );
  }
}
