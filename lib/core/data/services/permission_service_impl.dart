import 'microphone_permission.dart';

import 'package:voya/core/domain/interview/services/permission_service.dart';

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestMicrophone() async {
    if (await MicrophonePermission.isGranted()) return true;
    return MicrophonePermission.request();
  }
}
