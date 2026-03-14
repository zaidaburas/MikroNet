
import 'package:mikronet/models/mikrotik_model.dart';

class DevicesManagerModel {
  final MikrotikAdapter mikrotik;
  DevicesManagerModel({required this.mikrotik});

// blocked   comment   mac-address  to-address
// .id    address  bypassed  disabled  server       type
  Future<List> getAlIDevices()async{
    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/ip-binding/print",
        "=detail="
      ]
    );
  }

}




// 

// getDevicesWith(String)

// getBlockedDevices()

// getBybassedDevices()

// bybassDevice(Map)

// blockDevice(Map)

// deviceLabel(Map, String)

// . جلب قائمة الاجهزه

// جلب قائمة الاجهزه بشرط معين

// . جلب الأجهزة المحظورة

// . جلب الأجهزه المجانيه

// . إضافة جهاز مجان

// حظر جهاز

// تسمية جهاز

// . ازالة جهاز من القائمة

// removeDevice(String)

// . تحویل جهاز من حالة لأخرى محظور الى مجان والعكس

// convertDeviceStatus(Map, String, String)


