import '../services/router_os_client.dart';

class MikrotikAdapter extends RouterOSClient {
  MikrotikAdapter({required super.address,super.user,super.password,super.port,super.timeout,super.useSsl,super.verbose,super.context});
  // int version=0;
  
  Future<List> fetch({
    required dynamic command,
    Map<String, String>? params,
    int timeout=60
    })async{
    return await talk(
      command,params
      ).timeout(Duration(seconds: timeout));
  }
  
  
  Future<List> printData({
    required List<String> commands,
    List<String> conditions=const[],
    String fields="",
    int timeout=60
  })async{
    if(conditions.isNotEmpty){
      // conditions.first="?${conditions[0]}";
      commands.addAll(conditions);
    }
    Map<String, String> params={};
    if(fields!="" ){
      params={".proplist":fields};
    }
    return await fetch(
      command: commands,
      params: params,
      timeout: timeout
      );
  }

  // Future<List> getProperties({required String command ,required String props,String detail="=detail=",int timeout=15})async{
  //   return await talk([command,detail],{".proplist":props}).timeout(Duration(seconds: timeout));
  // }

  // Future<List> getAllProperties({required String command ,String detail="=detail=",int timeout=15})async{
  //   return await talk([command,detail]).timeout(Duration(seconds: timeout));
  // }

  Future<List> addData({required String command,required Map<String, String> data})async{
    return await fetch(command: command,params: data);
  }

  Future<String> _getElementId(String setCmd,String cond)async{
    List cmd=setCmd.split("/");
    String printCmd="";
    int loop=(cmd.length-1);
    for (var i = 0; i < loop; i++) {
      printCmd+="${cmd[i]}/";
    }
    printCmd+="print";
    List result=await printData(commands: [printCmd],conditions: [cond],fields: ".id");
    return result[0]['.id'];
  }

  Future<List> editData({
    required String command,
    required Map<String, String> data,
    required String condition 
  })async{
    // to get .id 
    String userId = await _getElementId(command, condition) ;
    return await fetch(command: [command,"=.id=$userId"],params: data);
  }

  Future<List> deleteData({
    required String command,
    required String condition 
  })async{
    // to get .id 
    String userId = await _getElementId(command, condition) ;
    return await fetch(command: [command,"=.id=$userId"]);
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