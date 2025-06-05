import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

class FirebaseAuthService {
  Future<String?> getServiceAccountToken() async {
    try {
      // Asset-dən oxuyuruq, File sistem-dən deyil
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
      print('Error fetching access token: $e');
      return null;
    }
  }
}
