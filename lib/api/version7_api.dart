import '/models/profiles_model.dart';
import '/services/mikrotik_client.dart';
import '../models/response.dart';
import '../models/cards_model.dart';

class ProfilesApi7 {
  int version;
  ProfilesApi7({this.version=6});
  
  // final String _props="""username,password,actual-profile,uptime-used,download-used,upload-used,last-seen""";


  static Future<AppResponse<List<ProfilesModel>>> getProfiles({String profileName=""}) async {
  try {
     // {
    //   .id: *2, 
    //   name: 100, 
    //   owner: admin, 
    //   name-for-users: 100, 
    //   validity: 2d, 
    //   price: 80, 
    //   limitations: [
    //     {
    //       .id: *2, 
    //       name: 100,
    //       owner: admin, 
    //       transfer-limit:167772160, 
    //       uptime-limit: 2h, 
    //       group- name: 1
    //     }
    //   ],
    //   hotspot_settings: {
    //     .id: *14, 
    //     name: 1, 
    //     shared-users: unlimited
    //   }
    // }
    // List finalResult=[];

    List profiles=await MikrotikClient.printData(
      commands: [
        '/user-manager/profile/print',
      ]
    );
    List links=await MikrotikClient.printData(
      commands: [
        '/user-manager/profile-limitation/print',
      ]
    );
    List limitations=await MikrotikClient.printData(
      commands: [
        '/user-manager/limitation/print',
      ]
    );
    // List groups=await MikrotikClient.printData(
    //   commands: [
    //     '/user-manager/limitation/print',
    //   ]
    // );
    // List hotspot=await _getHotspotProfiles();
    List result=[];
    for (var profile in profiles) {
      var link=links.where((l)=>l['profile']==profile['name']).toList();
      var limit=limitations.where((li)=>li['name']==link[0]['limitation']).toList();
      Map d=Map.from(profile);
      d['limitations']=limit;
      d['uptime-limit']=limit.first['uptime-limit']??'0h';
      d['palance']=limit.first['transfer-limit']??'0';
      d["rate-limit"]=("${limit.first['rate-limit-tx']}/${limit.first['rate-limit-rx']}")??"0/0";
      print('\n\n\n\n\n');
      print(d);
      print('\n\n\n\n\n');
      result.add(d);
    }

    print('\n\n\n\n\n');
    print(result);
    print('\n\n\n\n\n');
    
    // List results=await MikrotikClient.printData(
    //   commands: [
    //     '/user-manager/profile/print',
    //   ]
    // );
    List<ProfilesModel> finalResult = result.map((e) => 
    // ProfilesModel.fromMikrotik(e)
      ProfilesModel(
        customer: 'default',
        id: e['.id'],
        name: e['name'],
        price: e['price'],
        palance: e['palance'],
        validity: e['validity']??'unlimited',
        speed: e['rate-limit'],
        uptime: e['uptime-limit']??'2h',
        users: '1'
      )
    ).toList();
    
    return AppResponse<List<ProfilesModel>>(
      status: true, 
      message: "done",
      data: finalResult
    );
    
    } catch (e) {
      return AppResponse<List<ProfilesModel>>(
        status: false, 
        message: e.toString(),
      );
    }
  }

  
  static Future<String>_addOneHotspotProfile({
    required String name,
    required String users,
    required String speed,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/ip/hotspot/user/profile/add", 
        data: {
          "name": 'MikroNet_${name}_profile' ,
          "shared-users": users ,
          "rate-limit": speed 
        }
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String>_addLimit({
    required String name,
    required String customer,
    required String palance,
    required String uptime,
    required String hotspotProfile,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/tool/user-manager/profile/limitation/add", 
        data: {
          "name": 'MikroNet_${name}_limit' ,
          "owner": customer ,
          "transfer-limit": palance ,
          "uptime-limit": uptime ,
          "group-name": hotspotProfile ,
        }
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String>_addProfile({
    required String name,
    required String customer,
    required String validity,
    required String price,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/tool/user-manager/profile/add", 
        data: {
          "name": name ,
          "owner": customer ,
          "name-for-users": name ,
          "validity": validity ,
          "price": price ,
          "starts-at": "logon"
        }
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String>_linkProfileLimits({
    required String profile,
    required String limitation,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/tool/user-manager/profile/profile-limitation/add", 
        data: {
          "profile": profile ,
          "limitation": limitation ,
        }
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
  }
  
  static Future<AppResponse<void>>addOneProfile(Map data)async{
    try {
      // add hotspot profile
      await _addOneHotspotProfile(
        name: data["name"], 
        users: data["users"], 
        speed: data["speed"]
      );

      // add limit
      await _addLimit(
        name: data["name"], 
        customer: data["customer"], 
        palance: data["palance"],
        uptime: data["uptime"],
        hotspotProfile: "MikroNet_${data["name"]}_profile"
      );

      // add profile
      await _addProfile(
        name: data["name"], 
        customer: data["customer"], 
        validity: data["validity"],
        price: data["price"],
      );

      // link
      await _linkProfileLimits(
        profile: data["name"], 
        limitation: "MikroNet_${data["name"]}_limit"
      );

      
      return AppResponse<void>(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString()
      );
    }
  }

  static Future<AppResponse<void>>profileEdit(String name,Map<String, String> data)async{
    try {
      var profileResponse=await getProfiles(profileName: name);
      if(!profileResponse.status || profileResponse.data == null || profileResponse.data!.isEmpty){
        return AppResponse<void>(status: false, message: "Profile not found");
      }
      ProfilesModel profile = profileResponse.data![0];
      
      String newProfileName='MikroNet_${data["name"]??profile.name}_profile';
      String newLimitName='MikroNet_${data["name"]??profile.name}_limit';

      // edit hotspot profile
      await MikrotikClient.editData(
        command: "/ip/hotspot/user/profile/set",
        data: {
          "name": newProfileName.toString() ,
          "shared-users": data["users"]??profile.users ,
          "rate-limit": data["speed"]??profile.speed 
        },
        condition: "?name=MikroNet_${name}_profile"
      );

      // edit limit
      await MikrotikClient.editData(
        command: "/tool/user-manager/profile/limitation/set",
        data: {
          "name": newLimitName ,
          "owner": data["customer"]??profile.customer ,
          "transfer-limit": data["palance"]??profile.palance ,
          "uptime-limit": data["uptime"]??profile.uptime ,
          "group-name": newProfileName ,
        },
        condition: "?name=MikroNet_${name}_limit"
      );
      

      // edit profile
      await MikrotikClient.editData(
        command: "/tool/user-manager/profile/set",
        data: {
          "name": data["name"]??profile.name ,
          "owner": data["customer"]??profile.customer ,
          "name-for-users": data["name"]??profile.name ,
          "validity": data["validity"]??profile.validity ,
          "price": data["price"]??profile.price ,
          // "starts-at": "logon"
        },
        condition: "?name=$name"
      );

      
      return AppResponse<void>(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString()
      );
    }
  }


  static Future<AppResponse<void>>deleteProfile(String name)async{
    
    try {
      
      String newProfileName='MikroNet_${name}_profile';
      String newLimitName='MikroNet_${name}_limit';

      
      // remove link
      await MikrotikClient.deleteData(
        command: "/tool/user-manager/profile/profile-limitation/remove",
        condition: "?profile=$name"
      );
      
      // remove profile
      await MikrotikClient.deleteData(
        command: "/tool/user-manager/profile/remove",
        condition: "?name=$name"
      );

      // remove limit
      await MikrotikClient.deleteData(
        command: "/tool/user-manager/profile/limitation/remove",
        condition: "?name=$newLimitName"
      );


      // remove hotspot profile
      await MikrotikClient.deleteData(
        command: "/ip/hotspot/user/profile/remove",
        condition: "?name=$newProfileName"
      );
      


      
      return AppResponse<void>(
        status: true,
        message: "done"
      );
    } catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString()
      );
    }
  }

  

}










class CardsApi7 {
  // int version;
  // CardsApi({this.version=6});
  Map commands={
    6:
    {
      'user_profiles':'/tool/user-manager/profile/print',
      'user_customers':'/tool/user-manager/customer/print',
      'user_adduser':'/tool/user-manager/user/add',
      'user_addprofile':'/tool/user-manager/user/create-and-activate-profile',
    },
    7:
    {
      'user_profiles':'/user-manager/profile/print',
      'user_customers':'/user-manager/user/group/print',
      'user_adduser':'/user-manager/user/add',
      'user_addprofile':'/user-manager/user-profile/add',
    },
  };
  // static const String _props=""".id,username,password,actual-profile,uptime-used,download-used,upload-used,last-seen,customer""";
  // List cards=[];

  static CardModel fromMikrotik7(Map card){
    String tempStatus="normal";
    // {
    //   .id: *5A4, name: zz7354, password:, otp-secret:, group: 1, 
    //   shared-users: unlimited, attributes:, disabled: false, 
    //   comment: jan/26/2025 23:02:59, 
    //   profile: {
    //     .id: *6F07, user: zz7354, profile: 2500, 
    //     state: running-active, 
    //     end-time: 2026-05-07 15:23:20
    //   }
    // },
    // String uptime="";

    // uptime=card.keys.toList().contains("uptime-used")?card["uptime-used"]:"";

    if(card["profile"].isNotEmpty && (card["profile"]["state"]=="used" || card["profile"]["state"]=="running")){
      tempStatus="expired";
    }
    else if(card["profile"].isNotEmpty && card["profile"]["state"]=="running-active"){
      tempStatus="active";
    }
    else{
      tempStatus="normal";
    }
    return CardModel(
      id: card[".id"]??'0',
      username: card["name"]??'nnn', 
      password: card["password"]??'', 
      profile: (card["profile"]["profile"]??"unknown").toString(), 
      status: tempStatus, 
      customer: card["group"]??'default',
    );
  }

  

  static Future<List> _getAllCards({List where = const ["=detail="]}) async {
    try {
      List myCardsProfiles = await MikrotikClient.printData(
          commands: ["/user-manager/user-profile/print"], /* fields: _props */);

      List myCards = await MikrotikClient.printData(
          commands: ["/user-manager/user/print"], /* fields: _props */);
      
      List result=[];
      for (var card in myCards) {
        var link=myCardsProfiles.where((profile)=>profile['user']==card['name']).toList();
        Map temp=Map.from(card);
        temp['profile']=link.isNotEmpty?link.last:{};
        result.add(temp);  
      }
      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<AppResponse<List<CardModel>>> getAllCards({List where = const ["=detail="]}) async {
    try {
      List myCards = await _getAllCards(where: where);


      List<CardModel> cards =
          myCards.map((e) => 
          // CardModel(
          //   id: e[".id"]??'0',
          //   username: e["name"]??'nnn', 
          //   password: e["password"]??'', 
          //   profile: (e["profile"]["profile"]??"unknown").toString(), 
          //   status: e, 
          //   customer: e["group"]??'default',
          // )).toList();
          
          fromMikrotik7(e)).toList();

      return AppResponse<List<CardModel>>(
          status: true, message: "done", data: cards);
    } catch (e) {
      return AppResponse<List<CardModel>>(
        status: false,
        message: e.toString(),
      );
    }
  }
  

  static Future<AppResponse<void>> addCardProfile({
    required String customer,
    required String username,
    required String profile,
  }) async {
    try {
      await MikrotikClient.addData(
          command: "/user-manager/user-profile/add",
          data: {
            // "customer": customer,
            "user": username,
            "profile": profile,
          });
      return AppResponse<void>(status: true, message: "done", data: null);
    } catch (e) {
      return AppResponse<void>(status: false, message: e.toString(), data: null);
    }
  }

  static Future<AppResponse<void>> addOneCard({
    required String group,
    required String username,
    String password = "",
    required String profile,
  }) async {
    try {
      await MikrotikClient.addData(command: "/user-manager/user/add", data: {
        "name": username,
        "group": group,
        "password": password,
        "shared-users": '',
      });

      await MikrotikClient.addData(
          command: "/user-manager/user-profile/add",
          data: {
            "user": username,
            "profile": profile,
          });
      return AppResponse<void>(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString(),
      );
    }
  }



  static Future<AppResponse<List<CustomerModel>>> getCustomers() async {
    try {
      List myCustomers = await MikrotikClient.printData(
          commands: ["/tool/user-manager/customer/print"],
          conditions: ["?disabled=no"]);
      List<CustomerModel> result =
          myCustomers.map((e) => CustomerModel.fromMikrotik(e)).toList();
      return AppResponse<List<CustomerModel>>(
          status: true, message: "done", data: result);
    } catch (e) {
      return AppResponse<List<CustomerModel>>(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse<void>> cardEdit({
    required String username,
    required Map<String, String> data,
  }) async {
    try {
      await MikrotikClient.editData(
          command: "/tool/user-manager/user/set",
          data: data,
          condition: "?username=$username");
      return AppResponse<void>(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse<void>> deleteCard(String username) async {
    try {
      await MikrotikClient.deleteData(
          command: "/tool/user-manager/user/remove",
          condition: "?username=$username");
      return AppResponse<void>(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse<void>> deleteCardsBatch(List idsList) async {
    try {
      String ids = idsList.join(',');
      await MikrotikClient.fetch(
        command: ["/tool/user-manager/user/remove", '=numbers=$ids'],
      );
      return AppResponse<void>(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse<void>(
        status: false,
        message: e.toString(),
      );
    }
  }

  static Future<AppResponse<List<String>>> getIdsByUsernames(List usernames) async {
    List<String> extractedIds = [];

    try {
      // 1. جلب المعرفات والأسماء فقط من الراوتر (سريع جداً)
      var allUsers = await MikrotikClient.printData(
          commands: [
            '/tool/user-manager/user/print',
          ],
          fields: ".id,username");

      // 2. المرور على الناتج واستخراج الـ id للكروت المطابقة
      for (var user in allUsers) {
        if (usernames.contains(user['username'])) {
          extractedIds.add(user['.id']!);
        }
      }

      return AppResponse<List<String>>(status: true, message: "done", data: extractedIds);
    } catch (e) {
      return AppResponse<List<String>>(status: false, message: e.toString());
    }
  }

  static Future<AppResponse<List<CardSessionModel>>> getCardSessions(
      String username) async {
    try {
      List sessions = await MikrotikClient.printData(
          commands: ["/tool/user-manager/session/print"],
          conditions: ["?user=$username"]);
      List<CardSessionModel> result = sessions
          .map((session) => CardSessionModel.fromMikrotik(session))
          .toList();
      return AppResponse<List<CardSessionModel>>(
          status: true, message: "done", data: result);
    } catch (e) {
      return AppResponse<List<CardSessionModel>>(
        status: false,
        message: e.toString(),
      );
    }
  }
  

  // Future<List> getCustomers()async{
  //   return await mikrotik.getAllProperties(command: commands[version]['user_customers']);
  // }

  // // 1. البحث عن الكروت المنتهية التي تم استخدامها مسبقاً
  // var expiredUsers = await client.talk([
  //   '/tool/user-manager/user/print',
  //   '?-actual-profile', 
  //   '?>uptime-used=0s'  
  // ]);

  // if (expiredUsers.isEmpty) {
  //   print('ممتاز! لا يوجد كروت منتهية لحذفها.');
  //   return; // إنهاء العملية إذا لم يكن هناك بيانات
  // }

  // // 2. استخراج المعرفات الداخلية (.id) من النتائج
  // List<String> idsToDelete = [];
  // for (var user in expiredUsers) {
  //   if (user.containsKey('.id')) {
  //     idsToDelete.add(user['.id']!);
  //   }
  // }

  // print('تم العثور على ${idsToDelete.length} كارت منتهي. جاري الحذف...');

  // // 3. تقسيم المعرفات إلى دفعات (50 كارت في كل دفعة) للحفاظ على استقرار الراوتر
  // int batchSize = 50;
  // for (var i = 0; i < idsToDelete.length; i += batchSize) {
  //   // تحديد بداية ونهاية الدفعة الحالية
  //   var end = (i + batchSize < idsToDelete.length) ? i + batchSize : idsToDelete.length;
  //   var batch = idsToDelete.sublist(i, end);

  //   // دمج المعرفات بفاصلة (مثال: *1,*2,*3A)
  //   String numbers = batch.join(',');

  //   try {
  //     // 4. إرسال أمر الحذف للدفعة الحالية
  //     await client.talk([
  //       '/tool/user-manager/user/remove',
  //       '=numbers=$numbers'
  //     ]);
      
  //     print('تم حذف الدفعة من ${i + 1} إلى $end بنجاح.');
  //   } catch (e) {
  //     print('حدث خطأ أثناء حذف الدفعة ${i + 1} إلى $end: $e');
  //     // الكود سيستمر في محاولة حذف الدفعات الأخرى حتى لو فشلت إحداها
  //   }
  // }

  // print('تم الانتهاء من تنظيف قاعدة البيانات بالكامل!');


}





