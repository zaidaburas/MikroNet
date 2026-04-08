import 'dart:convert';

import 'package:charset/charset.dart';

import 'router_os_client.dart';

class MikrotikClient {
  // متغير ثابت يحفظ جلسة الاتصال
  static RouterOSClient? _client;

  // دالة ثابتة لتهيئة الاتصال مرة واحدة فقط في بداية التطبيق
  static void init({
    required String address,
    required String user,
    required String password,
    required int port,
    int timeout=60,
    bool useSsl=true,
    bool verbose=true,
    // dynamic context,
  }) {
    _client = RouterOSClient(
      address: address,
      user: user,
      password: password,
      port: port,
      timeout: Duration(seconds: timeout),
      useSsl: useSsl,
      verbose: verbose,
      // context: context,
    );
  }

  static Future<bool> login()async{
    return await _client!.login();
  }

  // التأكد من أن الاتصال تم تهيئته قبل أي عملية
  static void _checkConnection() {
    if (_client == null) {
      throw Exception("empty socket connection");
    }
  }
  static String decode(String text) {
    // String word = utf8.decode(
    //     _buffer.sublist(offset + bytesUsedForLength, offset + bytesUsedForLength + length),allowMalformed: true
    //   );
    // String word = windows1256.decode(
    //     _buffer.sublist(offset + bytesUsedForLength, offset + bytesUsedForLength + length),allowInvalid: true
    //   );
    try {
      // نحول النص الغريب إلى بايتات بترميز latin1 ثم نعيد قراءته كـ utf8
      return utf8.decode(windows1256.encode(text), allowMalformed: true);
    } catch (e) {
      return text; // إذا فشل التحويل يرجع النص كما هو
    }
  }
  static String encode(String text) {
    try {
      // نأخذ النص العربي (UTF-8) ونحوله إلى بايتات، ثم نجبره على التحول إلى نص بترميز windows1256
      return windows1256.decode(utf8.encode(text), allowInvalid: true);
    } catch (e) {
      return text; // إذا فشل التحويل يرجع النص كما هو لتجنب انهيار التطبيق
    }
  }

  static Future<List> fetch1  ({
    required dynamic command,
    Map<String, String>? params,
    // int timeout = 60,
  }) async {
    
    _checkConnection();
    return await _client!.talk(
      command,
      params,
    );
  }
  static Future<List> fetch({
    required dynamic command,
    Map<String, String>? params,
    // int timeout = 60,
  }) async {
    _checkConnection();

    Map<String, String>? encodedParams;
    if (params != null) {
      encodedParams = {};
      params.forEach((key, value) {
        // غالباً مفاتيح المايكروتك بالإنجليزية فلا تحتاج تشفير، لكن القيمة تحتاج
        encodedParams![key] = encode(value); 
      });
    }

    // 3. إرسال الطلب واستقبال الناتج الخام
    List rawResult = await _client!.talk(
      command,
      encodedParams,
    );

    // 4. فك التشفير للنتائج (Result Decoding)
    List decodedResult = [];
    for (var item in rawResult) {
      if (item is Map) {
        // إذا كان العنصر خريطة (Map) كما هو المعتاد في المايكروتك
        Map<String, dynamic> decodedMap = {};
        item.forEach((key, value) {
          if (value is String) {
            decodedMap[key] = decode(value);
          } else {
            decodedMap[key] = value;
          }
        });
        decodedResult.add(decodedMap);
      } else if (item is String) {
        // إذا كان العنصر نصاً مباشراً
        decodedResult.add(decode(item));
      } else {
        // أي نوع آخر (أرقام أو غيره) نتركه كما هو
        decodedResult.add(item);
      }
    }

    return decodedResult;
  }
  
  static Future<List> printData({
    required List<String> commands,
    List<String> conditions = const [],
    String fields = "",
  }) async {
    if (conditions.isNotEmpty) {
      commands.addAll(conditions);
    }
    Map<String, String> params = {};
    if (fields != "") {
      params = {".proplist": fields};
    }
    return await fetch(
      command: commands,
      params: params,
    );
  }

  static Future<List> addData({
    required String command,
    required Map<String, String> data,
  }) async {
    return await fetch(command: command, params: data);
  }

  static Future<String> _getElementId(String setCmd, String cond) async {
    List cmd = setCmd.split("/");
    String printCmd = "";
    int loop = (cmd.length - 1);
    for (var i = 0; i < loop; i++) {
      printCmd += "${cmd[i]}/";
    }
    printCmd += "print";
    List result = await printData(
      commands: [printCmd],
      conditions: [cond],
      fields: ".id",
    );
    return result[0]['.id'];
  }

  static Future<List> editData({
    required String command,
    required Map<String, String> data,
    required String condition,
  }) async {
    String userId = await _getElementId(command, condition);
    return await fetch(command: [command, "=.id=$userId"], params: data);
  }

  static Future<List> deleteData({
    required String command,
    required String condition,
  }) async {
    String userId = await _getElementId(command, condition);
    return await fetch(command: [command, "=.id=$userId"]);
  }

  static Future<List> removeById({
    required String command,
    required String id,
  }) async {
    return await fetch(command: [command, "=.id=$id"]);
  }

  static Future<int> getVersion() async {
    _checkConnection();
    List result = await _client!.talk("/system/resource/print");
    try {
      return int.parse(result[0]["version"].split('.')[0]);
    } catch (e) {
      return 0;
    }
  }

  // static Future<void> cancel(String tag)async{
  //   await _client!.cancelCommand(tag);
  // }

  // static Future<void> close()async{
  //   _client!.close();
  // }
}




