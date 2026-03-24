import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Base URL for the standalone backend service.
  // Android Emulator: 10.0.2.2 maps to the host machine's localhost
  // iOS Simulator:    localhost works directly
  // Web (browser):    localhost works directly
  // Production:       replace with your deployed backend URL
  static String get apiBaseUrl {
    return 'https://chatbackend-drab.vercel.app';

    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    // iOS simulator, macOS, Windows, Linux — localhost works fine
    return 'http://localhost:3000';
  }
}
