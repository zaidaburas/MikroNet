import 'mikrotik_model.dart';


class CardsModel {
  MikrotikAdapter mikrotik;
  int version;
  CardsModel({required this.mikrotik,this.version=6});
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
    // 'hotspot_profiles':'',
    // 'hotspot_servers':'',
  };
  final String _props="""username,password,actual-profile,uptime-used,download-used,upload-used,last-seen""";
  // List cards=[];

  Future<int> getCardsCount()async{
    final result = await mikrotik.printData(
      commands: [
        "/tool/user-manager/user/print",
        "=count-only="
        ]
    );
    int count=int.parse(result.first.values.first) ;
    return count;

  }

  Future<List> getAllCards()async{
    // try {
    //   int count=await getCardsCount();
    //   if(cards.isEmpty || count==cards.length){
    //     cards=await mikrotik.printData(
    //       commands: ["/tool/user-manager/user/print"],
    //       fields: props
    //     );
    //   }
    //   return cards;
    // } catch (e) {
    //   return [{"error":e.toString()}];
    // }
    return await mikrotik.printData(
      commands: ["/tool/user-manager/user/print"],
      fields: _props
    );
  }

  Future<List> getCardsWith(
    List<String> conditions,
    {List<String> command=const[],
    String fields=""
  })async{
    if(command.isEmpty)command=["/tool/user-manager/user/print"];
    return await mikrotik.printData(
      commands: command ,
      conditions: conditions,
      fields: fields
      );
  }
  
  Future<List> getExpiredCards()async{
    List<String> cond=[
      "?actual-profile",
      "?#!",
      "?>uptime-used=0"
    ];
    return await getCardsWith(cond,fields: _props);
  }

  Future<Map> getCardInfo(String username)async{
    try {
      List result = await getCardsWith(["?username=$username"],fields: _props);
      return result[0];
    } catch (e) {
      return {
        "error":e.toString()
      };
    }
  }

  Future<List> getActiveCards()async{
    List<String> cond=[
      "?-actual-profile",
      "?#!",
      "?>uptime-used=0"
    ];
    return await getCardsWith(cond,fields: "username,actual-profile");
  }

  Future<List> addCardProfile({
    required String customer,
    required String username,
    // required String password,
    required String profile,
  })async{
    return await mikrotik.addData(
      command: "/tool/user-manager/user/create-and-activate-profile", 
      data: {
        "customer":customer,
        "numbers":username,
        "profile":profile,
      }
    );
  }

  Future<String> addOneCard({
    required String customer,
    required String username,
    String password="",
    required String profile,
  })async{
    try {
      await mikrotik.addData(
        command: "/tool/user-manager/user/add", 
        data: {
          "customer":customer,
          "username":username,
          "password":password,
        }
      );
      
      await addCardProfile(
        customer: customer, 
        username: username, 
        profile: profile
      );
      return "done";
    } on Exception catch (e) {
      return "error:${e.toString()}";
    }
  }
  
  Future<List> getCustomers()async{
    return await mikrotik.printData(
      commands: ["/tool/user-manager/customer/print"],
      conditions: ["?disabled=no"]
    );
  }

  Future<String> cardEdit({
    required String username,
    required Map<String, String> data,
  })async{
    try {
      await mikrotik.editData(
        command: "/tool/user-manager/user/set", 
        data: data, 
        condition: "?username=$username"
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
    // try {
    //   return await mikrotik.editData(
    //     command: "/tool/user-manager/user/set", 
    //     data: data, 
    //     condition: "?username=$username"
    //   );
    // } catch (e) {
    //   return [{"error":e.toString()}];
    // }
  }
  
  Future<String> deleteCard(String username)async{
    try {
      await mikrotik.deleteData(
        command: "/tool/user-manager/user/remove", 
        condition: "?username=$username"
      );
      return "done";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> cardRenew({
    required String username,
    required String profile,
    required String customer,
  })async{
    try {
      
      await addCardProfile(
        customer: customer, 
        username: username, 
        profile: profile
      );
      return "done";
    } on Exception catch (e) {
      return "error:${e.toString()}";
    }
  }


  Future<List> getCardSessions(String username)async{
    return await mikrotik.printData(
      commands: ["/tool/user-manager/session/print"],
      conditions: ["?user=$username"]
    );
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





