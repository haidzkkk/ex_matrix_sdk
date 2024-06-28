
import 'package:flutter/services.dart';

class FlutterOverlay{
  static const _overlayMethodChanel = MethodChannel("com.example.method_chanel/showOverlay");


  static void showOverlay(String title, String body) async {
    var params = {
      "title": title,
      "body": body,
    };
    await _overlayMethodChanel.invokeMethod('runService', params);
  }

  static void closeOverlay() async {
      await _overlayMethodChanel.invokeMethod('stopService');
  }

}