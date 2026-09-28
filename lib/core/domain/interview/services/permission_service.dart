/// Abstraction over OS permission prompts so the bloc is testable without a
/// real platform channel.
abstract class PermissionService {
  /// Returns true once the microphone permission is granted (requesting it
  /// if not already granted).
  Future<bool> requestMicrophone();
}
