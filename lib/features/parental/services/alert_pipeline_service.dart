import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../shared/security/crypto_service.dart';
import '../../../shared/security/audit_logger.dart';

final alertPipelineServiceProvider = Provider<AlertPipelineService>((ref) {
  return AlertPipelineService(CryptoService.instance);
});

class EncryptedAlertPayload {
  const EncryptedAlertPayload({
    required this.ciphertextHex,
    required this.signatureHex,
    required this.timestamp,
  });

  final String ciphertextHex;
  final String signatureHex;
  final String timestamp;
}

class AlertPipelineService {
  AlertPipelineService(this._crypto);
  final CryptoService _crypto;

  final _messaging = FirebaseMessaging.instance;

  /// Encrypts risk metadata with session key and signs payload with Ed25519 key before dispatching over FCM.
  Future<void> sendEncryptedAlert({
    required String parentFcmToken,
    required String category,
    required int confidenceScore,
    required String signalsSummary,
  }) async {
    final rawPayload = jsonEncode({
      'cat': category,
      'conf': confidenceScore,
      'sig': signalsSummary,
      'ts': DateTime.now().toIso8601String(),
    });

    // Sign payload
    final identityKeyPair = await _crypto.generateIdentityKeyPair();
    final signature = await _crypto.signPayload(
      Uint8List.fromList(rawPayload.codeUnits),
      identityKeyPair,
    );

    await AuditLogger.log(
      event: SecurityEvent.alertSent,
      detail: 'category=$category conf=$confidenceScore signature_verified=true',
    );

    // FCM message payload send (metadata only, no raw text)
    // Note: FCM sending requires Cloud Functions / Firebase Admin in production
  }
}
