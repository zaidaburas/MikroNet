import 'package:mikronet/models/mikrotik_model.dart';

class ConnectedDevicesModel {
  final MikrotikAdapter mikrotik;
  ConnectedDevicesModel({required this.mikrotik});

  Future<List> getAllConnectedDevices()async{
//     Flags: S - static, H - DHCP, D - dynamic, A - authorized, P - bypassed
//  0 DA mac-address=04:5E:A4:70:06:21 address=4.0.0.21 to-address=4.0.0.15
//       server=hs-vlan-4 uptime=2h9m31s keepalive-timeout=2m bridge-port=vlan4
//       found-by="ARP reply to 4.0.0.1"

// {.id: *8FE, mac-address:
// 04:5E:A4:70:06:21, address: 4.0.0.21,
// to-address: 4.0.0.15, server: hs-vlan-4,
// uptime: 2h13m1s, idle-time: 0s,
// keepalive-timeout: 2m, host-dead-time:
// Os, bridge-port: vlan4, bytes-in:
// 5651637, bytes-out: 25657451,
// packets-in: 35884, packets-out: 36948,
// found-by: ARP reply to 4.0.0.1, dynamic:
// true, authorized: true, bypassed: false},

    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/host/print",
        "=detail="
      ]
    );
  }
}




// . جلب كل الأجهزه المتصلة
// 
// . جلب الاجهزة بشرط معين
// getConnectedWith(String)
// . جلب الأجهزة المتصلة بكروت
// getConnectedByCard()
// . جلب معلومات جهاز متصل
// getOneInfo(String)
// قطع الاتصال عن جهاز معين
// removeOne(String)


