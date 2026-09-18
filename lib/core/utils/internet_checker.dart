import 'dart:async';
import 'dart:io';

class InternetChecker {
  const InternetChecker._();

  static Future<bool> hasInternet({
    String host = 'cdn.islamic.network',
  }) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}