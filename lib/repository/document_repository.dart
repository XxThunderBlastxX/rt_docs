import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/document_model.dart';
import '../models/error_model.dart';

final documentRepoProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;

  DocumentRepository({required Client client}) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error =
        ErrorModel(err: 'Opps Something went wrong!!!', data: null);

    try {
      var resBody = jsonEncode({
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      });

      var res = await _client.post(
        Uri.parse(
            '${defaultTargetPlatform == TargetPlatform.android ? kHostAndroid : kHostWeb}/doc/create'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: resBody,
      );

      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            err: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          error = ErrorModel(err: res.body, data: null);
      }
    } catch (err) {
      error = ErrorModel(err: err.toString(), data: null);
      print(err);
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token) async {
    ErrorModel error =
        ErrorModel(err: 'Opps Something went wrong!!!', data: null);

    try {
      var res = await _client.get(
        Uri.parse(
            '${defaultTargetPlatform == TargetPlatform.android ? kHostAndroid : kHostWeb}/docs/me'),
        headers: {
          'x-auth-token': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> docs = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            docs.add(
                DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          error = ErrorModel(
            err: null,
            data: docs,
          );
          break;
        default:
          error = ErrorModel(err: res.body, data: null);
      }
    } catch (err) {
      error = ErrorModel(err: err.toString(), data: null);
      print(err);
    }
    return error;
  }
}
