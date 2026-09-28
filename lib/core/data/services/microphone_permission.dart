import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper so no other file imports `permission_handler` directly.
class MicrophonePermission {
  const MicrophonePermission._();

  static Future<bool> isGranted() async => Permission.microphone.status.isGranted;

  /// Requests access. Returns true if granted, false if denied or
  /// permanently denied (caller should offer to open app settings).
  static Future<bool> request() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> isPermanentlyDenied() async =>
      Permission.microphone.status.isPermanentlyDenied;

  static Future<void> openSettings() => openAppSettings();
}
