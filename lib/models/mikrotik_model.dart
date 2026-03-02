import '../services/router_os_client.dart';

class MikrotikAdapter extends RouterOSClient {
  MikrotikAdapter({required super.address,super.user,super.password,super.port,super.timeout,super.useSsl,super.verbose,super.context});
  // int version=0;
  

  Future<List> getProperties({required String command ,required String props,String detail="=detail=",int timeout=15})async{
    return await talk([command,detail],{".proplist":props}).timeout(Duration(seconds: timeout));
  }

  Future<List> getAllProperties({required String command ,String detail="=detail=",int timeout=15})async{
    return await talk([command,detail]).timeout(Duration(seconds: timeout));
  }

  Future<List> addData({required String command,required Map<String, String> data})async{
    return await talk(command,data);
  }

  Future<int> getVersion()async{
    // List result =await getProperties(command: "/system/resource/print", props: "version",detail: "");
    List result =await talk("/system/resource/print");
    try {
      return int.parse(result[0]["version"].split('.')[0]);
    } catch (e) {
      return 0;
    }
  }
}