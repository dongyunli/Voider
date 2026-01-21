import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestRecordingPermissions() async {
    // 请求麦克风权限
    var micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      return false;
    }

    // Android 10+ 不需要显式的存储权限来写入应用私有目录，
    // 但如果需要导出或为了兼容旧版本，可以检查存储权限。
    // 这里我们主要依赖 path_provider 获取应用目录。
    
    return true;
  }

  Future<bool> checkPermission() async {
    return await Permission.microphone.isGranted;
  }
  
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
