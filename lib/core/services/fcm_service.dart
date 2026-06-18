import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// Sends FCM v1 push notifications directly from the Flutter app
/// using a Firebase Service Account for OAuth2 authentication.
///
/// ⚠️ SECURITY NOTE:
/// Embedding a Service Account private key in a client app is acceptable
/// ONLY for internal / admin-only apps that are NOT distributed publicly.
/// For public apps, always use a backend server.
class FCMService {
  FCMService._();
  static final FCMService instance = FCMService._();

  // ── Service Account credentials ────────────────────────────────────────
  // Replace these with YOUR values from serviceAccountKey.json.
  //
  // TIP: Copy the private_key value exactly as-is from the JSON file.
  //      The literal `\n` characters in the JSON string are actual newline
  //      escape sequences. Dart raw strings (r'...') would NOT interpret
  //      them, so we use a normal string and the `\n` are kept as-is.
  // ────────────────────────────────────────────────────────────────────────

  static const String _projectId = 'honest-academy';

  static const String _clientEmail =
      'firebase-adminsdk-fbsvc@honest-academy.iam.gserviceaccount.com';

  // Paste the private_key value from your serviceAccountKey.json.
  // IMPORTANT: Use a regular Dart string (NOT a raw string r'...') so that
  // the \n sequences are interpreted as real newlines, which is what the
  // PEM parser expects.
  static const String _privateKey =
      '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDb5L8EMDpzkIpf\nUkbfFEVoYcO2DJxWZPLhOl2GRejLeCjobfGeb3cTdi1Co5B6sdf/lxOTnxg57dM5\nl8gy1FX/n8I+kKKpzDk0lTH8UvsaRLgOYLLAvkkceozJEp/B7qYARxdoxgVjGB3f\nBkecbFYoDW6uYRhgpzqp9OvO4CQh+L2spUP9JLrcHRfSevzIjom9nIwxYQ6E5kF/\nGkGuNGNOEqoiqeU1AuIKv9ao43Iga/LywtKvct2DkXWQ2kF17JPixdekToDaQyPl\nJjfaSdGAVm6CVdd7zflG31bo7fL2kxossa+eT7PZ2dq1qmDOj6qnY2Yvdnzc2+ep\nwHPumABfAgMBAAECggEAbFB+7vc6s5YtMsr6cgQwNDyEBPatQ7kyElOHog5pn2Au\n9l7Bt8M8Km/512tuTaGwvguS7xJdApvtgd8MFE2XlvUA34SrO2yHeSlMl/fgDI5x\nA1QKePrCVK7hDmKIIyUEy/o4w7lXCfrlK+iR+bE7tzr2nBrjwShesz0bsqmh4sEU\nGDOPsP3bHgVSmpRCsv5D9b2wwuX2ASBHCovQly5zq2TMn18AX9m2SdsfKNrxqumM\n9PdEjrZFFk4bja7A3EPULjdEjnEI9AeB990jOde1V1oCYmCXovL+d1iXIsu5Igq3\nabCo5cMnlYqBGfKW5ML6XRaK6lDq5TC5uf8LExoJoQKBgQDw68AkHQn4bSX7N7Qw\n72XhYrKs0tf/Y2dOssNGX1IZF0IPiwHQfsGJbTgSve6oEJmx1gFSVW8kLqUnaOqM\n1ZDJg1OwdaJPY9H8kZqqKfguSnttql4UqAMm6rzzEFdv4CHftaBiPTldaDPzY+Nk\n+92Y3T3c86EEDgQ1al0YFAdImQKBgQDpqBOUebbnElJ6QpIpcgcnPKevDel/ffFl\nAE6VJP0icBkqEA34E9R27XyHOIsr//efQStPCtVt9Zf2MmLEakULHSud0bQEYSNX\n5TZsR4HPwNwVeYc7iw1gOhsTG0HuFSioAi1Wp3VsyRW2j77jZ0Z2+jY4k+AWshtZ\nSCcY6BXTtwKBgQCWTCy5Gtief9FDEPQ71w2y9vTKtlqD+8p2ITWLkGnSN11B/xFp\ntbodduKVZqIdfQW1GPIIID5Ozz6/AEfbBlzmKiSqoCha6MYWj+tyHu6ySksIFlHN\nBye4PpcT9+zkYWogetmMj+9ao2hNfdJdrHcJJ3Sxg9e+hNQBUtKy88O7eQKBgQCR\nMRQZqxhwtf3yYvOYNXckdphsOuThiE08SdiK7RUvFSFN9fP4N7pKvIApNoWkrcYd\ne82BrGW7kmT/Y4fkLXUB1vqHcwu9vO7Na21KE5Uil+Eqpv3Vji6doP25/bIWU6eT\n3uZ1dlGNa9bGPsSLYl1zCUAwIBObhslfzWoeG/mUOQKBgEDgNozRqriENOFXlYJe\ncVgCFVamvLlMFcbXcPEb1XxfmH5FaUp7y2AYQn7NfwFiBer8VrryP70q2OsSbcFx\no5ZM9NNKkp8yG7SBYhUIthgpHdu2XC72EIiC2GiEqer1JEhKAGuOqAMSDQjI18XK\n8PeCskyl7Gr/rX+pNDhqVcZd\n-----END PRIVATE KEY-----\n';

  // ── OAuth2 scopes required for FCM v1 ──────────────────────────────────
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  // ── Cached access token ────────────────────────────────────────────────
  AccessCredentials? _cachedCredentials;

  /// Obtains (or refreshes) an OAuth2 access token using service account
  /// credentials. The token is cached and automatically refreshed when it
  /// expires.
  Future<String> _getAccessToken() async {
    // Return cached token if still valid (with 60-second buffer).
    if (_cachedCredentials != null &&
        _cachedCredentials!.accessToken.expiry
            .isAfter(DateTime.now().toUtc().add(const Duration(seconds: 60)))) {
      return _cachedCredentials!.accessToken.data;
    }

    final serviceAccountCredentials = ServiceAccountCredentials(
      _clientEmail,
      ClientId('', ''),
      _privateKey,
    );

    final httpClient = http.Client();
    try {
      _cachedCredentials = await obtainAccessCredentialsViaServiceAccount(
        serviceAccountCredentials,
        _scopes,
        httpClient,
      );
      return _cachedCredentials!.accessToken.data;
    } finally {
      httpClient.close();
    }
  }

  /// Sends an FCM v1 push notification to a single device.
  ///
  /// - [deviceToken] – the target device's FCM registration token.
  /// - [title] – notification title.
  /// - [body] – notification body text.
  /// - [data] – optional data payload (key-value pairs of strings).
  Future<bool> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
      );

      final message = <String, dynamic>{
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
          },
          // Android-specific: high priority ensures immediate delivery.
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'high_importance_channel',
              'sound': 'default',
            },
          },
          // APNs (iOS) config.
          'apns': {
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
              },
            },
          },
          if (data != null && data.isNotEmpty) 'data': data,
        },
      };

      debugPrint('[FCM DIAGNOSTIC] Sending request to FCM v1 API: $url');
      debugPrint('[FCM DIAGNOSTIC] Request payload: ${jsonEncode(message)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      debugPrint('[FCM DIAGNOSTIC] HTTP Response Status Code: ${response.statusCode}');
      debugPrint('[FCM DIAGNOSTIC] HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('[FCM] ✅ Push notification sent successfully');
        return true;
      } else {
        debugPrint(
          '[FCM] ❌ Failed to send push notification: '
          '${response.statusCode} – ${response.body}',
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('[FCM] ❌ Exception sending push notification: $e');
      debugPrint('$stack');
      return false;
    }
  }

  /// Sends a push notification to multiple devices.
  ///
  /// Returns a list of booleans indicating success/failure for each token.
  Future<List<bool>> sendToMultipleDevices({
    required List<String> deviceTokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final results = <bool>[];
    for (final token in deviceTokens) {
      final success = await sendPushNotification(
        deviceToken: token,
        title: title,
        body: body,
        data: data,
      );
      results.add(success);
    }
    return results;
  }
}
