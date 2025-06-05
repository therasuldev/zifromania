import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:zifromania/domain/entities/global.dart';

class FirebaseAuthService {
  Future<String?> getServiceAccountToken() async {
    try {
      // Reading from assets
      final String fileContent = await rootBundle.loadString('assets/zifromania-service-account.json');
      final Map<String, dynamic> serviceAccountCredentials = jsonDecode(fileContent);

      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/firebase.database',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/cloud-platform'
      ];

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountCredentials),
        scopes,
      );

      final accessServerKey = client.credentials.accessToken.data;
      return accessServerKey;
    } catch (e) {
      log.e('Error getting service account token: $e');
      return null;
    }
  }
}
