import 'mikrotik_model.dart';


class ProfilesModel {
  MikrotikAdapter mikrotik;
  int version;
  ProfilesModel({required this.mikrotik,this.version=6});
  
  // final String _props="""username,password,actual-profile,uptime-used,download-used,upload-used,last-seen""";


  Future<List> _getHotspotProfiles({String whereName="=detail="})async{
    String props="name,shared-users,rate-limit";
    return await mikrotik.printData(
      commands: [
        "/ip/hotspot/user/profile/print",
        // "=detail="
      ],
      conditions: [whereName],
      fields: props
    );
  }

  Future<List> _getLimitations({String whereNane="=detail="})async{
    String props="name,owner,transfer-limit,uptime-limit,group-name";
    return await mikrotik.printData(
      commands: [
        "/tool/user-manager/profile/limitation/print",
        // "=detail="
      ],
      conditions: [whereNane],
      fields: props
    );
  }

  Future<List> getProfilesNames({String whereName="=detail="})async{
    String props= ".id,name,owner,name-for-users,validity,price";
    return await mikrotik.printData(
      commands: [
        "/tool/user-manager/profile/print",
        // "=detail="
      ],
      conditions: [whereName],
      fields: props,
    );
  }

  Future<List> _getLimitationsLinks({String whereProfile="=detail="})async{
    String props= "profile,limitation";
    return await mikrotik.printData(
      commands: [
        "/tool/user-manager/profile/profile-limitation/print",
        // "=detail="
        ],
      conditions: [whereProfile],
      fields: props,
    );
  }

  Future<List> _getProfilesData({String profileName=""})async{
    List<dynamic> results = [];

    if(profileName!=""){
      List links = await _getLimitationsLinks(whereProfile: "?profile=$profileName");
      Map link=links[0];

      List limits = await _getLimitations(whereNane: "?name=${link["limitation"]}");
      Map limit=limits[0];

      List hotspot = await _getHotspotProfiles(whereName: "?name=${limit["group-name"]}");
      Map hots=hotspot[0];

      List profiles = await getProfilesNames(whereName: "?name=$profileName");
      Map profile=profiles[0];

      results.addAll([[hots],[limit],[profile],[link]]);
      return results;
    }

    List hotspot = await _getHotspotProfiles();
    List limits = await _getLimitations();
    List profiles = await getProfilesNames();
    List links = await _getLimitationsLinks();

    results.addAll([hotspot,limits,profiles,links]);
    return results;
  }

  Future<List> getAllProfiles({String profileName=""}) async {
  try {

    List results=await _getProfilesData(profileName: profileName);

    List hotspot = results[0];
    List limits = results[1];
    List profiles = results[2];
    List links = results[3];

    // القائمة النهائية التي سنرجعها
    List<Map<String, dynamic>> finalProfiles = [];

    // 2. المرور على كل بروفايل في اليوزر منجر لدمج بياناته
    for (var profile in profiles) {
      // إنشاء نسخة جديدة قابلة للتعديل من البروفايل
      Map<String, dynamic> mergedProfile = Map<String, dynamic>.from(profile);

      // --- أ: دمج القيود (Limitations) ---
      var profileLinks = links.where((link) => link['profile'] == profile['name']).toList();
      List<Map<String, dynamic>> profileLimits = [];

      for (var link in profileLinks) {
        // جلب بيانات القيد (Limitation) الفعلي بناءً على اسمه في الرابط
        var limitData = limits.cast<Map<String, dynamic>?>().firstWhere(
          (l) => l != null && l['name'] == link['limitation'],
          orElse: () => null,
        );

        if (limitData != null) {
          profileLimits.add(limitData);
        }
      }
      
      // إضافة قائمة القيود داخل البروفايل
      mergedProfile['limitations'] = profileLimits;

      // --- ب: دمج خصائص الهوتسبوت (Hotspot Settings) ---
      // عادةً اسم البروفايل في اليوزر منجر يطابق اسم بروفايل الهوتسبوت، أو يتم تحديده عبر name-for-users
      String targetHotspotName = profile['name-for-users'] ?? profile['name'];
      
      var hotspotData = hotspot.cast<Map<String, dynamic>?>().firstWhere(
        (h) => h != null && h['name'] == targetHotspotName,
        orElse: () => null,
      );

      // إذا لم نجده بالاسم، أحياناً يكون مربوطاً عبر group-name داخل الـ limitation
      if (hotspotData == null && profileLimits.isNotEmpty) {
        String? groupName = profileLimits.first['group-name'];
        if (groupName != null) {
          hotspotData = hotspot.cast<Map<String, dynamic>?>().firstWhere(
            (h) => h != null && h['name'] == groupName,
            orElse: () => null,
          );
        }
      }

      // إضافة خصائص الهوتسبوت إذا وجدت
      mergedProfile['hotspot_settings'] = hotspotData ?? {};

      // 3. إضافة البروفايل المدمج للقائمة النهائية
      finalProfiles.add(mergedProfile);
    }

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
    List finalResult=[];

    for (var profile in finalProfiles) {
      finalResult.add({
        ".id":profile[".id"],
        "name":profile["name"],
        "price":profile["price"]??"??",
        "palance":profile["limitations"][0]["transfer-limit"]??"??",
        "validity":profile["validity"]??"??",
        "uptime":profile["limitations"][0]["uptime-limit"]??"??",
        "speed":profile["hotspot_settings"]["rate-limit"]??"??",
        "users":profile["hotspot_settings"]["shared-users"]??"??",
      });
    }
    // return finalProfiles;
    return finalResult;
    
    } catch (e) {
      throw Exception("فشل في دمج بيانات البروفايلات: $e");
    }
  }

  
  Future<String>_addOneHotspotProfile({
    required String name,
    required String users,
    required String speed,
  })async{
    try {
      await mikrotik.addData(
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

  Future<String>_addLimit({
    required String name,
    required String customer,
    required String palance,
    required String uptime,
    required String hotspotProfile,
  })async{
    try {
      await mikrotik.addData(
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

  Future<String>_addProfile({
    required String name,
    required String customer,
    required String validity,
    required String price,
  })async{
    try {
      await mikrotik.addData(
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

  Future<String>_linkProfileLimits({
    required String profile,
    required String limitation,
  })async{
    try {
      await mikrotik.addData(
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
  
  Future<String>addOneProfile(Map data)async{
    // {
    //   ".id":,
    //   "name":, 
    //   "price":,
    //   "palance":,
    //   "validity":,
    //   "uptime":,
    //   "speed":,
    //   "users":
    // }
    
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

      
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String>profileEdit(String name,Map<String, String> data)async{
    // {
    //   "name":, p,h,l
    //   "price":, p
    //   "palance": l
    //   "validity": p
    //   "uptime": l
    //   "speed": h
    //   "users": h
    // }
    
    try {
      // first try find

      // List profileTemp=await getAllProfiles(profileName: name);
      // Map profile=profileTemp[0];
      
      String newProfileName='MikroNet_${data["name"]}_profile';
      String newLimitName='MikroNet_${data["name"]}_limit';

      // edit hotspot profile
      await mikrotik.editData(
        command: "/ip/hotspot/user/profile/set",
        data: {
          "name": newProfileName.toString() ,
          "shared-users": data["users"].toString() ,
          "rate-limit": data["speed"].toString() 
        },
        condition: "?name=MikroNet_${name}_profile"
      );

      // edit limit
      await mikrotik.editData(
        command: "/tool/user-manager/profile/limitation/set",
        data: {
          "name": newLimitName ,
          "owner": data["customer"].toString() ,
          "transfer-limit": data["palance"].toString() ,
          "uptime-limit": data["uptime"].toString() ,
          "group-name": newProfileName ,
        },
        condition: "?name=MikroNet_${name}_limit"
      );
      

      // edit profile
      await mikrotik.editData(
        command: "/tool/user-manager/profile/set",
        data: {
          "name": data["name"].toString() ,
          "owner": data["customer"].toString() ,
          "name-for-users": data["name"].toString() ,
          "validity": data["validity"].toString() ,
          "price": data["price"].toString() ,
          // "starts-at": "logon"
        },
        condition: "?name=$name"
      );

      
      return "done";
    } catch (e) {
      return e.toString();
    }
  }


  Future<String>deleteProfile(String name)async{
    // {
    //   "name":, p,h,l
    //   "price":, p
    //   "palance": l
    //   "validity": p
    //   "uptime": l
    //   "speed": h
    //   "users": h
    // }
    
    try {
      
      String newProfileName='MikroNet_${name}_profile';
      String newLimitName='MikroNet_${name}_limit';

      
      // remove link
      await mikrotik.deleteData(
        command: "/tool/user-manager/profile/profile-limitation/remove",
        condition: "?profile=$name"
      );
      
      // remove profile
      await mikrotik.deleteData(
        command: "/tool/user-manager/profile/remove",
        condition: "?name=$name"
      );

      // edit limit
      await mikrotik.deleteData(
        command: "/tool/user-manager/profile/limitation/remove",
        condition: "?name=$newLimitName"
      );


      // edit hotspot profile
      await mikrotik.deleteData(
        command: "/ip/hotspot/user/profile/remove",
        condition: "?name=$newProfileName"
      );
      


      
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  // Future<Map> getOneLimit(String profileName)async{
  //   String props= "profile,limitation";
  //   List result=await mikrotik.printData(
  //     commands: [
  //       "/tool/user-manager/profile/profile-limitation/print",
  //       "=detail="
  //     ],
  //     conditions: ["?profile=$profileName"],
  //     fields: props
  //   );
  //   return result.first;
  // }
  // Future<Map> getOneProfile()async{}
  // Future<Map> getOneProfile()async{}
  // Future<Map> getOneProfile()async{}

  
  

}





