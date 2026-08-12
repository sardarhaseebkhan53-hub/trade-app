import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Securely tracks first-launch safety/privacy + policy acknowledgement.
/// Supports simple versioned completion for future policy updates.
class FirstLaunchStore {
  static const _safetyFlowCompletedKey = 'safety_privacy_flow_completed_v1';
  static const _policyVersionKey = 'acknowledged_policy_version';

  // Increment this when material policy changes require renewed acknowledgement
  static const currentPolicyVersion = '2026.08';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> hasCompletedSafetyFlow() async {
    final value = await _storage.read(key: _safetyFlowCompletedKey);
    if (value != 'true') return false;

    // Optional future policy version gate (currently always pass for v1)
    final ver = await _storage.read(key: _policyVersionKey);
    return ver == currentPolicyVersion || ver == null; // allow old installs
  }

  Future<void> markSafetyFlowCompleted({String? policyVersion}) async {
    await _storage.write(key: _safetyFlowCompletedKey, value: 'true');
    await _storage.write(key: _policyVersionKey, value: policyVersion ?? currentPolicyVersion);
  }

  Future<String?> getAcknowledgedPolicyVersion() async {
    return _storage.read(key: _policyVersionKey);
  }

  Future<void> resetSafetyFlowForTesting() async {
    await _storage.delete(key: _safetyFlowCompletedKey);
    await _storage.delete(key: _policyVersionKey);
  }
}
