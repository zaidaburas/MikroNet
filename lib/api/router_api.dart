import 'package:mikronet/models/response.dart';
import 'package:mikronet/services/mikrotik_client.dart';

class RouterApi {
  static Future<AppResponse<void>> rebootSystem()async{
    try{
      await MikrotikClient.printData(commands: ["/system/reboot"]);
      return AppResponse(status: true, message: "سيتم اعادة التشغيل الان");
    }catch(e){
      return AppResponse(status: false, message: e.toString());
    }
  }
}