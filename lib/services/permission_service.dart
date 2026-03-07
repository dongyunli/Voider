import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class PermissionService {
  final Logger _logger = Logger();  // ✅ 添加 Logger

  /// 请求录音所需的权限
  /// 返回 true 表示权限已授予，false 表示权限被拒绝
  Future<bool> requestRecordingPermissions() async {
    // 请求麦克风权限
    var micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      // ✅ 记录详细的权限状态
      _logger.e("Microphone permission denied. Status: $micStatus");
      
      // 检查权限是否被永久拒绝
      if (micStatus == PermissionStatus.permanentlyDenied) {
        _logger.w("Microphone permission is permanently denied");
      }
      
      // Android 10+ 不需要显式的存储权限来写入应用私有目录，
      // 但如果需要导出或为了兼容旧版本，可以检查存储权限。
      // 这里我们主要依赖 path_provider 获取应用目录。
      
      return false;
    }

    _logger.i("Microphone permission granted successfully");
    return true;
  }

  /// 检查麦克风权限状态
  /// 返回 true 表示已授予，false 表示未授予
  Future<bool> checkPermission() async {
    final isGranted = await Permission.microphone.isGranted;
    
    if (isGranted) {
      _logger.i("Microphone permission check: granted");
    } else {
      _logger.i("Microphone permission check: not granted");
    }
    
    return isGranted;
  }
  
  /// 打开应用设置页面
  Future<void> openSettings() async {
    try {
      await openAppSettings();
      _logger.i("Opened app settings successfully");
    } catch (e) {
      _logger.e("Failed to open app settings: $e");
      rethrow;
    }
  }
}
