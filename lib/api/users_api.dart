import '/services/mikrotik_client.dart';
import '/services/response.dart';

class UsersApi {
  // UsersApi({});

  static const String _hostsFields=".id,mac-address,address,to-address,server,uptime,bytes-in,bytes-out,authorized,bypassed,comment";
  static const String _activeFields=".id,server,user,address,mac-address,uptime,session-time-left,bytes-in,bytes-out,limit-bytes-total,comment";

  static Future<AppResponse> getAllHosts({String where="=detail="})async{
    try {
      List usersData=await MikrotikClient.printData(
        commands: [
          "/ip/hotspot/host/print",
          where
        ],
        fields: _hostsFields
      );
      // List result=[];
      // for (Map user in usersData) {
      //   result.add(HostUserModel.fromMikrotik(user));
      // }
      return AppResponse(
        status: true,
        message: "done",
        data: usersData
      );
    } catch (e) {
      return AppResponse(
        status: true,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse> getAllActive({String where="=detail="})async{
    try {
      List usersData=await MikrotikClient.printData(
        commands: [
          "/ip/hotspot/active/print",
          where
        ],
        fields: _activeFields,
        // conditions: []
      );
      // List result=[];
      // for (var user in usersData) {
      //   result.add(ActiveUserModel.fromMikrotik(user));
      // }
      return AppResponse(
        status: true,
        message: "done",
        data: usersData
      );
    } catch (e) {
      return AppResponse(
        status: true,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse> removeOneActive(String username)async{
    try {
      await MikrotikClient.deleteData(
        command: "/ip/hotspot/active/remove",
        condition: "?user=$username"
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } catch (e) {
      return AppResponse(
        status: true,
        message: e.toString(),
      );
    }
    
  }
  
  static Future<AppResponse> removeOneHost(String srcAddress)async{
    try {
      await MikrotikClient.deleteData(
        command: "/ip/hotspot/host/remove",
        condition: "?address=$srcAddress"
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } catch (e) {
      return AppResponse(
        status: true,
        message: e.toString(),
      );
    }
    
  }

  static Future<AppResponse> insertCardToOne({
    required String username,
    String password="",
    required String loginIp,
    required String mac,
  })async{
    try {
      // Map userData=await getOneHostInfo(address);
      Map<String, String> userData={
        "user": username,
        "password":password ,
        "ip":loginIp,
        "mac-address":mac,
      };
      await MikrotikClient.addData(
        command: "/ip/hotspot/active/login", 
        data: userData
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } catch (e) {
      return AppResponse(
        status: true,
        message: e.toString(),
      );
    }
  }
  
  
  static Future<AppResponse> getAlISavedUsers({String where="=detail="})async{
    try {
      List usersData=await MikrotikClient.printData(
        commands: [
          "/ip/hotspot/ip-binding/print",
          where,
        ],
        // fields: ".id,address,to-address,mac-address,disabled,server,type,comment"
      );
      // List result=[];
      // for (Map user in usersData) {
      //   result.add(SavedUserModel.fromMikrotik(user));
      // }
      return AppResponse(
        status: true, 
        message: "done",
        data: usersData
      );
    } catch (e) {
      return AppResponse(
        status: false, 
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse> getBlockedDevices()async{
    return await getAlISavedUsers(where: "?type=blocked");
  }

  static Future<AppResponse> getBypassedDevices()async{
    return await getAlISavedUsers(where: "?type=bypassed");
  }

  static Future<AppResponse> labelDevice({
    required String macAddress,
    String srcAddress="0.0.0.0",
    String dstAddress="0.0.0.0",
    String label="labeled device",
    String server="all",
  })async{
    try {
      await MikrotikClient.addData(
        command: "/ip/hotspot/ip-binding/add", 
        data: {
          "address":srcAddress,
          "to-address":dstAddress,
          "mac-address":macAddress,
          "server":server,
          "comment":label,
          "type":"regular",
        }
      );
      return AppResponse(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<AppResponse> bypassDevice({
    required String macAddress,
    String srcAddress="0.0.0.0",
    String dstAddress="0.0.0.0",
    String label="bypassed device",
    String server="all",
  })async{
    try {
      await MikrotikClient.addData(
        command: "/ip/hotspot/ip-binding/add", 
        data: {
          "address":srcAddress,
          "to-address":dstAddress,
          "mac-address":macAddress,
          "server":server,
          "comment":label,
          "type":"bypassed",
        }
      );
      return AppResponse(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<AppResponse> blockDevice({
    required String macAddress,
    String srcAddress="0.0.0.0",
    String dstAddress="0.0.0.0",
    String label="blocked device",
    String server="all",
  })async{
    try {
      await MikrotikClient.addData(
        command: "/ip/hotspot/ip-binding/add", 
        data: {
          "address":srcAddress,
          "to-address":dstAddress,
          "mac-address":macAddress,
          "server":server,
          "comment":label,
          "type":"blocked",
        }
      );
      return AppResponse(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<AppResponse> removeDevice({
    required String id,
  })async{
    try {
      await MikrotikClient.removeById(
        command: "/ip/hotspot/ip-binding/remove", 
        id: id,
      );
      return AppResponse(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<AppResponse> editDevice(
    String id,{
    String macAddress="",
    String srcAddress="",
    String dstAddress="",
    String label="",
    String server="",
    String type="regular",
  })async{
    try {
      var data=await getAlISavedUsers(where: "=.id=$id");
      Map result=data.data[0].toMap();
      await MikrotikClient.fetch(
        command: [
          "/ip/hotspot/ip-binding/set", 
          "=.id=$id"
        ], 
        params: {
          "mac-address": macAddress==""?result["macAddress"]:macAddress,
          "address": srcAddress==""?result["srcAddress"]:srcAddress,
          "to-address": dstAddress==""?result["dstAddress"]:dstAddress,
          "comment": label==""?result["label"]:label,
          "server": server==""?result["server"]:server,
          "type": type==""?result["type"]:type,
        }
      );
      return AppResponse(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<String> getUserId(Map user)async{
    try {
      List usersData=await MikrotikClient.printData(
        commands: [
          "/ip/hotspot/ip-binding/print",
        ],
        conditions: [
          // '?address=${user["address"]}',
          // '?to-address=${user["to-address"]}',
          '?mac-address=${user["mac-address"]}',
          // '?server=${user["server"]}',
          '?comment=${user["comment"]}',
        ]

        // fields: ".id,address,to-address,mac-address,disabled,server,type,comment"
      );
      if(usersData.isEmpty){
        return "empty";
      }
      return usersData.first[".id"];
    } catch (e) {
      return e.toString();
    }
    // return {};
  }

}



