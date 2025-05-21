import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class AccessTokenService {
  Future<String?> getAccessToken() async {
    try {
      // Load the service account credentials JSON from a file
      final serviceAccountFilePath = dotenv.env['SERVICE_ACCOUNT_KEY_PATH'];
      if (serviceAccountFilePath == null) {
        throw Exception('Service account key path is not set in .env file.');
      }

      final file = File(serviceAccountFilePath);
      if (!await file.exists()) {
        throw Exception('Service account key file not found at $serviceAccountFilePath');
      }

      final fileContent = await file.readAsString();
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
