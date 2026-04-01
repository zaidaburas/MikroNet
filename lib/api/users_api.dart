import '/services/mikrotik_client.dart';
import '/services/response.dart';

class UsersApi {
  // UsersApi({});

  static const String _hostsFields=".id,mac-address,address,to-address,server,uptime,bytes-in,bytes-out,authorized,bypassed,comment";
  static const String _activeFields=".id,server,user,address,mac-address,uptime,session-time-left,bytes-in,bytes-out,limit-bytes-total,comment";

  static Future<AppResponse<List> > getAllHosts({String where="=detail="})async{
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

  static Future<AppResponse<List> > getAllActive({String where="=detail="})async{
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

  static Future<AppResponse<List> > removeOneActive(String username)async{
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
  
  static Future<AppResponse<List> > removeOneHost(String srcAddress)async{
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

  static Future<AppResponse<List> > insertCardToOne({
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
  
  static Future<AppResponse<List> > getArpList({String where="=detail="})async{
    try {
      List response= await MikrotikClient.printData(
        commands: [
          "/ip/arp/print",
          where
        ],
        conditions: [
          "?dynamic=yes"
        ]
      );
      return AppResponse(status: true, message: "done",data: response);
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse<List> > getBlockedHosts({String mac="=detail="})async{
    try {
      AppResponse<List> blockRes = await getBlockedDevices(); 
      AppResponse<List> arpRes = await getArpList(
        where: mac == "=detail=" ? "=detail=" : "?mac-address=$mac"
      ); 

      // التأكد من أن القوائم ليست null لتجنب الأخطاء
      List blockedList = blockRes.data ?? [];
      List arpList = arpRes.data ?? [];

      // 1. تجميع عناوين الماك المحظورة في Set (تتميز بسرعة البحث العالية جداً)
      // Set<String> blockedMacs = blockedList
      //     .map((device) => device["mac-address"].toString())
      //     .toSet();

      // // 2. جلب كل عناصر الـ ARP التي يطابق الماك الخاص بها أحد الماكات المحظورة
      // List response = arpList
      //     .where((arpItem) => blockedMacs.contains(arpItem["mac-address"]))
      //     .toList();

      Set<String> arpMacs =arpList.map((arpItem) => arpItem["mac-address"].toString())
      .toSet();

      List response = blockedList
          .where((device) => arpMacs.contains(device["mac-address"]))
          .toList();

      return AppResponse(status: true, message: "done", data: response);

      // AppResponse<List> blockRes=await getBlockedDevices();
      // AppResponse<List> arpRes=await getArpList(
      //   where: mac=="=detail="?"=detail=":"?mac-address=$mac"
      // );
      // List response=[];
      // for (var i in blockRes.data??[]) {
      //   List device=arpRes.data??[].where((a)=>a["mac-address"]==i["mac-address"]).toList();
      //   response.addAll(device);
      // }
      // return AppResponse(status: true, message: "done",data: response);
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  

  
  static Future<AppResponse<List>> getAlISavedUsers({String where="=detail="})async{
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

  static Future<AppResponse<List> > getBlockedDevices()async{
    return await getAlISavedUsers(where: "?type=blocked");
  }

  static Future<AppResponse<List> > getBypassedDevices()async{
    return await getAlISavedUsers(where: "?type=bypassed");
  }

  static Future<AppResponse<List> > saveDevice({
    required String macAddress,
    String srcAddress="0.0.0.0",
    String dstAddress="0.0.0.0",
    String label="saved device",
    String server="all",
    String type="regular"
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
          "type":type,
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

  static Future<AppResponse<List> > labelDevice({
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

  static Future<AppResponse<List> > bypassDevice({
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

  static Future<AppResponse<List> > blockDevice({
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

  static Future<AppResponse<List> > removeDevice({
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

  static Future<AppResponse<List>> editDevice(String id,Map<String, String> data)async{
    try {
      var response=await getAlISavedUsers(where: "?.id=$id");
      if (response.data!.isEmpty) {
        return AppResponse(
          status: false,
          message: "empty"
        );
      }
      // Map result=response.data!.first;
      // Map result={};
      await MikrotikClient.fetch(
        command: [
          "/ip/hotspot/ip-binding/set", 
          "=.id=$id"
        ], 
        params: data
        // {
        //   "mac-address": macAddress==""?result["mac-address"]:macAddress,
        //   "address": srcAddress==""?result["address"]:srcAddress,
        //   "to-address": dstAddress==""?result["to-address"]:dstAddress,
        //   "comment": label==""?result["comment"]:label,
        //   "server": server==""?result["server"]:server,
        //   "type": type==""?result["type"]:type,
        // }
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



