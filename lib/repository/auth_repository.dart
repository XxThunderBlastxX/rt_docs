import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/error_model.dart';
import '../models/user_model.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
  })  : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> googleSignIn() async {
    ErrorModel error =
        ErrorModel(err: 'Opps Something went wrong!!!', data: null);

    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final userAcc = UserModel(
            uid: '',
            email: user.email,
            name: user.displayName!,
            profilePic: user.photoUrl!,
            token: '');

        var res = await _client.post(
          Uri.parse('$kHost/api/signup'),
          body: userAcc.toJson(),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['_id'],
            );
            error = ErrorModel(err: null, data: newUser);
            break;
          // default:
          //   throw UnsupportedError('Opps!! Something went wrong');
        }
      }
    } catch (err) {
      error = ErrorModel(err: err.toString(), data: null);
      print(err);
    }
    return error;
  }
}
