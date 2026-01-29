import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ResponsiveHelper {
  // Check if running on actual mobile device
  static bool get isMobileDevice {
    if (kIsWeb) {
      // On web, check screen size
      return false; // Will be checked in widget with MediaQuery
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  // Check if running on desktop
  static bool get isDesktopDevice {
    if (kIsWeb) {
      return false; // Will be checked in widget with MediaQuery
    }
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  // Check if web on mobile screen size
  static bool isMobileWeb(double width) {
    return kIsWeb && width < 768;
  }

  // Check if web on desktop screen size
  static bool isDesktopWeb(double width) {
    return kIsWeb && width >= 768;
  }
}
