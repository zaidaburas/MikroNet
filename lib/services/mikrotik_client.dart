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

  static Future<List> fetch({
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

  static Future<int> getVersion() async {
    _checkConnection();
    List result = await _client!.talk("/system/resource/print");
    try {
      return int.parse(result[0]["version"].split('.')[0]);
    } catch (e) {
      return 0;
    }
  }
}




