import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionHelper {
  // ✅ Location permission
  static Future<bool> requestLocationPermission() async {
    final status = await ph.Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    final status = await ph.Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  //  Notification permission (Android 13+ / API 33+)
  static Future<bool> checkNotificationPermission() async {
    final status = await ph.Permission.notification.status;
    if (status.isDenied) {
      final result = await ph.Permission.notification.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // ✅ Exact alarm permission (Android 12+ / API 31+)
  static Future<bool> checkExactAlarmPermission() async {
    final status = await ph.Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      final result = await ph.Permission.scheduleExactAlarm.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // Bug fix:
  static Future<void> openSettings() async {
    await ph.openAppSettings();
  }
}