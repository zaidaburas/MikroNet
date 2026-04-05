import 'package:mikronet/services/response.dart';

import '/services/mikrotik_client.dart';

class SitesApi {

  static Future<AppResponse> getDnsData()async{
    try {
      var respone=await MikrotikClient.printData(commands: ["/ip/dns/print"]);
      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> setDns({String main="8.8.8.8",String secondary="8.8.4.4",bool allowRemoteRequests=true})async{
    try {
      String dns='$main,$secondary';
      await MikrotikClient.addData(
        command: "/ip/dns/set", 
        data: {'servers':dns,'allow-remote-requests':allowRemoteRequests?'yes':'no'}
      );
      return AppResponse(status: true, message: "done");
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> getDnsCache()async{
    try {
      var respone=await MikrotikClient.printData(commands: ["/ip/dns/cache/print"]);
      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }






  static Future<List> _getLayer7List()async{
    try {
      return await MikrotikClient.printData(commands: ["/ip/firewall/layer7-protocol/print"]);
    } catch (e) {
      throw e.toString();
    }
  }

  static List _getRegExp(List filterList,List layer7List){
    try {
      var newFilters=filterList.where((f)=>!f["layer7-protocol"].toString().startsWith("*")).toList();
      var result=[];
      // var result=filterList.map((filter){
      newFilters.map((filter){
      Map temp=layer7List.firstWhere((layer)=>layer["name"]==filter["layer7-protocol"]);
      var newMap=Map.from(filter);

      if(temp["name"]!=null && temp['regexp']!=null && temp['regexp']!='' && temp['.id']!=null  ){
        var r={
          'id':newMap['.id'],
          'name':temp["name"]??"",
          'interface':newMap['out-interface']??"",
          'content':temp['regexp']??"",
          'type':'layer7',
          'layer7-id':temp['.id']??"",
        };
        result.add(r);
      }

      // newMap["regexp"]=temp["regexp"]??"";
      // return newMap;  
      }).toList();

      // result.removeWhere((i)=>i["regexp"]=="");
      
      // return result;
      return result;
    }catch (e) {
      throw e.toString();
    }
  }
  // add action=drop chain=forward layer7-protocol=BLOCK_BLOGSPOT_COM out-outInterface=OUT comment="Block blogspot.com L7 [v6]"
  static Future<AppResponse> getLayer7BlockedSites()async{
    try {
      var layer7List=await _getLayer7List();
      var respone=await MikrotikClient.printData(
        commands: [
          '/ip/firewall/filter/print',
        ],
        conditions: [
          '?-layer7-protocol',
          '?#!', 
          '?action=drop',
          // '?disabled=no',
        ]
      );
      var result=_getRegExp(respone,layer7List);
      return AppResponse(status: true, message: "done",data: result);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> addBlockByLayer7({
    required String name,
    String outInterface="all-ethernet",
    required String content,
  })async{

    try {
      String comment="MikroNet_Block_$name";
      var layer7=await MikrotikClient.addData(
        command: "/ip/firewall/layer7-protocol/add",
        data: {'name':name,'regexp':content,'comment':comment}
      );

      var filter=await MikrotikClient.addData(
        command: "/ip/firewall/filter/add",
        data: {
          'action':'drop',
          'chain':'forward',
          'layer7-protocol':name,
          'out-interface':outInterface,
          'comment':comment
        }
      );
      return AppResponse(status: true, message: "${layer7.toString()} , ${filter.toString()}");
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

    // ==========================================
  // Layer7 Edit & Delete Methods
  // ==========================================

  static Future<AppResponse> editBlockByLayer7({
    required String filterId,   // id المرجع من دالة الجلب
    required String layer7Id,   // layer7-id المرجع من دالة الجلب
    required String name,
    required String outInterface,
    required String content,
  }) async {
    try {
      String comment = "MikroNet_Block_$name";
      
      // تعديل قاعدة Layer7
      await MikrotikClient.addData(
        command: "/ip/firewall/layer7-protocol/set",
        data: {
          '.id': layer7Id,
          'name': name,
          'regexp': content,
          'comment': comment
        }
      );

      // تعديل قاعدة الفلتر
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/set",
        data: {
          '.id': filterId,
          'layer7-protocol': name,
          'out-interface': outInterface,
          'comment': comment
        }
      );
      
      return AppResponse(status: true, message: "تم التعديل بنجاح");
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> deleteBlockByLayer7({
    required String filterId,
    required String layer7Id,
  }) async {
    try {
      // حذف الفلتر أولاً
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/remove",
        data: {'.id': filterId}
      );

      // حذف قاعدة Layer7
      await MikrotikClient.addData(
        command: "/ip/firewall/layer7-protocol/remove",
        data: {'.id': layer7Id}
      );

      return AppResponse(status: true, message: "تم الحذف بنجاح");
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }








  static Future<List> _getMangleList()async{
    try {
      return await MikrotikClient.printData(commands: ["/ip/firewall/mangle/print"]);
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<List> _getFilterList()async{
    try {
      return await MikrotikClient.printData(
        commands: [
          '/ip/firewall/filter/print',
        ],
        conditions: [
          // '?-layer7-protocol',
          // '?#!', 
          '?action=drop',
          // '?disabled=no',
        ]
      );
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<AppResponse> getSSLBlockedSites() async {
    try {
      List filterList = await _getFilterList();
      var mangleList = await _getMangleList();
      
      List tlsFilters = [];
      List dstAddressesFilters = [];
      List tlsMangle = [];

      // جلب رولات المانجل التي تحتوي على tls-host و address-list
      for (Map i in mangleList) {
        if (i.keys.contains("tls-host") && i.keys.contains("address-list")) {
          tlsMangle.add(i);
        }
      }

      // جلب رولات الفلتر التي تحتوي على tls-host
      for (Map i in filterList) {
        if (i.keys.contains("tls-host")) {
          tlsFilters.add(i);
        }
      }

      // جلب رولات الفلتر التي تحتوي على dst-address-list
      for (Map i in filterList) {
        if (i.keys.contains("dst-address-list")) {
          dstAddressesFilters.add(i);
        }
      }

      var result=[];
      // الانتباه هنا: استخدمنا tlsMangle بدلاً من mangleList
      var all = tlsMangle.map((m) {
        // استخدام where بدلاً من firstWhere لتجنب الكراش في حال عدم وجود الرول
        var matchingTls = tlsFilters.where((t) => t["tls-host"] == m["tls-host"]);
        var matchingDst = dstAddressesFilters.where((d) => d["dst-address-list"] == m["address-list"]);

        var a = Map.from(m);
        
        // نأخذ أول عنصر إذا وجد، أو نضع null
        a["tls"] = matchingTls.isNotEmpty ? matchingTls.first : null;
        a["dst"] = matchingDst.isNotEmpty ? matchingDst.first : null;

        if(a["tls"]!=null && a["dst"]!=null){
        var r={
          'id':m['.id'],
          'name':m['address-list'],
          'domain':m['tls-host'],
          'interface':a["tls"]['out-interface'],
          'type':'ssl',
          'filter-id':a["tls"]['.id'],
          'link-id':a["dst"]['.id'],
        };
        
        // return r;
          result.add(r);
        }
        
      }).toList();

      return AppResponse(status: true, message: "done", data: result);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> _addSSLMangle(String name,String domain,String comment)async{
    try {
      // name,domain,comment
      var respone=await MikrotikClient.addData(
        command: "/ip/firewall/mangle/add",
        data: {
          'action':'add-dst-to-address-list',
          'address-list':name,
          'address-list-timeout':'1d',
          'chain':'prerouting',
          'protocol':'tcp',
          'tls-host':'*$domain*',
          'comment':comment,
        }
      );
      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> _addSSLFilterTls(String outInterface,String domain,String comment)async{
    try {
      // domain,outInterface,comment
      var respone=await MikrotikClient.addData(
        command: "/ip/firewall/filter/add",
        data: {
          'action':'drop',
          'chain':'forward',
          'protocol':'tcp',
          'tls-host':'*$domain*',
          'out-interface':outInterface,
          'comment':comment,
        }
      );
      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> _linkFilterWithMangle(String name,String outInterface,String comment)async{
    try {
      // name,outInterface,comment
      var respone=await MikrotikClient.addData(
        command: "/ip/firewall/filter/add",
        data: {
          'action':'drop',
          'chain':'forward',
          'protocol':'tcp',
          'dst-address-list':name,
          'out-interface':outInterface,
          'comment':comment,
        }
      );
      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> addBlockBySSL({
    required String name,
    required String outInterface,
    required String domain,
  })async{
    try {
      String comment="MikroNet_Block_$name";
      var mangle=await _addSSLMangle(name,domain,comment);
      var tls=await _addSSLFilterTls(outInterface,domain,comment);
      var link=await _linkFilterWithMangle(name,outInterface,comment);
      var respone=[mangle,tls,link];
      return AppResponse(status: true, message: "${mangle.message} , ${tls.message} , ${link.message}",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

    // ==========================================
  // SSL Edit & Delete Methods
  // ==========================================

  static Future<AppResponse> editBlockBySSL({
    required String mangleId,     // id المرجع من دالة الجلب (Mangle)
    required String tlsFilterId,  // filter-id المرجع من دالة الجلب (TLS Filter)
    required String linkFilterId, // link-id المرجع من دالة الجلب (Link Filter)
    required String name,
    required String outInterface,
    required String domain,
  }) async {
    try {
      String comment = "MikroNet_Block_$name";

      // 1. تعديل المانجل (Mangle)
      await MikrotikClient.addData(
        command: "/ip/firewall/mangle/set",
        data: {
          '.id': mangleId,
          'address-list': name,
          'tls-host': '*$domain*',
          'comment': comment,
        }
      );

      // 2. تعديل فلتر الـ TLS
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/set",
        data: {
          '.id': tlsFilterId,
          'tls-host': '*$domain*',
          'out-interface': outInterface,
          'comment': comment,
        }
      );

      // 3. تعديل فلتر الربط (Link/Dst-Address-List)
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/set",
        data: {
          '.id': linkFilterId,
          'dst-address-list': name,
          'out-interface': outInterface,
          'comment': comment,
        }
      );

      return AppResponse(status: true, message: "تم التعديل بنجاح");
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }

  static Future<AppResponse> deleteBlockBySSL({
    required String mangleId,
    required String tlsFilterId,
    required String linkFilterId,
  }) async {
    try {
      // 1. حذف المانجل
      await MikrotikClient.addData(
        command: "/ip/firewall/mangle/remove",
        data: {'.id': mangleId}
      );

      // 2. حذف فلتر الـ TLS
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/remove",
        data: {'.id': tlsFilterId}
      );

      // 3. حذف فلتر الربط
      await MikrotikClient.addData(
        command: "/ip/firewall/filter/remove",
        data: {'.id': linkFilterId}
      );

      return AppResponse(status: true, message: "تم الحذف بنجاح");
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }


  static Future<AppResponse> getAllBlockedSites()async{
    try {
      var layer7List=await getLayer7BlockedSites();
      var sslList=await getSSLBlockedSites();
      if (!layer7List.status && !sslList.status) {
        return AppResponse(status: false, message: "${layer7List.message} , ${sslList.message}");
      }
      var result=sslList.data;
      result.addAll(layer7List.data);
      return AppResponse(status: true, message: "done",data: result);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }







}


// [
//   {
//     .id: *92, chain: prerouting, action: add-dst-to-address-list, 
//     protocol: tcp, address-list: BLOCK_BLOGSPOT_COM_IPs, 
//     address-list-timeout: 1d, bytes: 0, packets: 0, 
//     tls-host: *192.168.10.102*, invalid: false, dynamic: false, 
//     disabled: true, comment: Track blogspot.com [v6], 
//     tls: {
//       .id: *DB, chain: forward, action: drop, 
//       protocol: tcp, out-outInterface: LAN1, bytes: 0, 
//       packets: 0, tls-host: *192.168.10.102* invalid: false, 
//       dynamic: false, disabled: true, 
//       comment: Block blogspot.com TLS [v6]
//     }, 
//     dst: {
//       .id: *DC, chain: forward, action: drop, 
//       dst-address-list: BLOCK BLOGSPOT COM IPs, 
//       out-outInterface: LAN1, bytes: 0, packets: 0, 
//       invalid: false, dynamic: false, disabled: true, 
//       comment: Block blogspot.com IP
//     }
//   }
// ]

// الحظر

// /ip firewall layer7-protocol
// add name=BLOCK_BLOGSPOT_COM regexp="blogspot" comment="Block blogspot.com"

// /ip firewall filter
// add action=drop chain=forward layer7-protocol=BLOCK_BLOGSPOT_COM out-interface=OUT comment="Block blogspot.com L7 [v6]"


