import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/error_model.dart';
import '../models/user_model.dart';
import 'local_storage_repository.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepo: LocalStorageRepo(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepo _localStorageRepo;

  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepo localStorageRepo,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepo = localStorageRepo;

  Future<ErrorModel> googleSignIn() async {
    ErrorModel error =
        ErrorModel(err: 'Opps Something went wrong!!!', data: null);

    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final userAcc = UserModel(
            uid: '',
            email: user.email,
            name: user.displayName ?? '',
            profilePic: user.photoUrl ?? '',
            token: '');

        var res = await _client.post(
          Uri.parse(
              '${defaultTargetPlatform == TargetPlatform.android ? kHostAndroid : kHostWeb}/api/signup'),
          body: userAcc.toJson(),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
                uid: jsonDecode(res.body)['user']['_id'],
                token: jsonDecode(res.body)['token']);

            _localStorageRepo.setToken(newUser.token);
            error = ErrorModel(err: null, data: newUser);
            break;
        }
      }
    } catch (err) {
      error = ErrorModel(err: err.toString(), data: null);
      print(err);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(err: 'Opps Something went wrong!!!', data: null);

    try {
      String? token = await _localStorageRepo.getToken();

      if (token != null) {
        var res = await _client.get(
          Uri.parse(
              '${defaultTargetPlatform == TargetPlatform.android ? kHostAndroid : kHostWeb}/'),
          headers: {'x-auth-token': token},
        );

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(jsonDecode(res.body)['user']),
            ).copyWith(token: token);

            _localStorageRepo.setToken(newUser.token);
            error = ErrorModel(err: null, data: newUser);
            break;
        }
      }
    } catch (err) {
      error = ErrorModel(err: err.toString(), data: null);
      print(err);
    }
    return error;
  }
}
