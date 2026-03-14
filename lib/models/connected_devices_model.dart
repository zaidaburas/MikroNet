import 'package:mikronet/models/mikrotik_model.dart';

class ConnectedDevicesModel {
  final MikrotikAdapter mikrotik;
  ConnectedDevicesModel({required this.mikrotik});

  final String _hostsFields=".id,mac-address,address,to-address,server,uptime,bytes-in,bytes-out,authorized,bypassed,comment";
  final String _activeFields=".id,server,user,address,mac-address,uptime,session-time-left,bytes-in,bytes-out,limit-bytes-total,comment";

  Future<List> getAllConnectedDevices()async{
    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/host/print",
        "=detail="
      ],
      fields: _hostsFields
    );
  }

  Future<List> getConnectedWith(String where)async{
    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/host/print",
        "=detail="
      ],
      fields: _hostsFields,
      conditions: [where]
    );
  }

  Future<List> getConnectedByCard()async{
    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/active/print",
        "=detail="
      ],
      fields: _activeFields,
      // conditions: []
    );
  }

  Future<Map> getOneHostInfo(String address)async{
    try {
      List result= await mikrotik.printData(
        commands: [
          "/ip/hotspot/host/print",
          "=detail="
        ],
        fields: _hostsFields,
        conditions: [
          "?address=$address",
          "?to-address=$address",
          "?#|"
        ]
      );
      return result.isEmpty?{}:result[0];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map> getOneActiveInfo(String username)async{
    try {
      // String userId=await mikrotik.ge
      List result= await mikrotik.printData(
        commands: [
          "/ip/hotspot/active/print",
          "=detail="
        ],
        fields: _activeFields,
        conditions: [
          "?user=$username",
        ]
      );
      return result.isEmpty?{}:result[0];
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> removeOneActive(String username)async{
    try {
      await mikrotik.deleteData(
        command: "/ip/hotspot/active/remove",
        condition: "?user=$username"
      );
      return "done";
    } catch (e) {
      throw Exception(e.toString());
    }
    
  }
  
  Future<String> removeOneHost(String address)async{
    try {
      await mikrotik.deleteData(
        command: "/ip/hotspot/host/remove",
        condition: "?address=$address"
      );
      return "done";
    } catch (e) {
      throw Exception(e.toString());
    }
    
  }

  Future<String> insertCardToOne({
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
      await mikrotik.addData(
        command: "/ip/hotspot/active/login", 
        data: userData
      );
      return "done";
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  



}


// . جلب الأجهزة المتصلة بكروت
// 
// . جلب معلومات جهاز متصل
// 
// قطع الاتصال عن جهاز معين
// (String)


