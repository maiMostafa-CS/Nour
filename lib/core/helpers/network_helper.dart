import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  // ═══════════════════════════════════════════════════════════
  // Check whether there is an internet connection
  // ═══════════════════════════════════════════════════════════
  static Future<bool> hasInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // connectivity_plus 6.x returns a List
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('❌ No internet connection');
        return false;
      }

      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet)) {
        debugPrint('✅ Internet available: $connectivityResult');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Network check failed: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Connection type name
  // ═══════════════════════════════════════════════════════════
  static Future<String> getConnectionType() async {
    final result = await Connectivity().checkConnectivity();

    if (result.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    } else if (result.contains(ConnectivityResult.mobile)) {
      return 'بيانات الجوال';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (result.contains(ConnectivityResult.none)) {
      return 'لا يوجد اتصال';
    }

    return 'غير معروف';
  }
}