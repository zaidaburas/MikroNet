

import 'package:mikronet/models/cards_model.dart';
import 'package:mikronet/services/mikrotik_client.dart';
import 'package:mikronet/services/response.dart';

class CardsApi {
  int version;
  CardsApi({this.version=6});
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
  final String _props=""".id,username,password,actual-profile,uptime-used,download-used,upload-used,last-seen,customer""";
  // List cards=[];

  


  Future<AppResponse<List<CardsModel>>> getAllCards({List where=const["=detail="]})async{
  try {
      List myCards=await MikrotikClient.printData(
        commands: ["/tool/user-manager/user/print"],
        fields: _props
      );
      List<CardsModel> cards=[];
      for (Map card in myCards) {
        cards.add(
          CardsModel.fromMap(card)
        );
      }
      return AppResponse(
        status: true, 
        message: "done",
        data: cards
      );
      // return cards;
    } catch (e) {
      return AppResponse(
        status: false, 
        message: e.toString() ,
      );
    }
  }

  
  // Future<AppResponse<CardsModel>> getCardInfo(String username)async{
  //   try {
  //     // return await getAllCards2(where: ["?username=$username"])[0];
  //     var result = await getAllCards2(where: ["?username=$username"]);
  //     return result[0];
  //   } catch (e) {
  //     return {
  //       "error":e.toString()
  //     };
  //   }
  // }

  Future<AppResponse> addCardProfile({
    required String customer,
    required String username,
    required String profile,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/tool/user-manager/user/create-and-activate-profile", 
        data: {
          "customer":customer,
          "numbers":username,
          "profile":profile,
        }
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } catch (e) {
      return AppResponse(
        status: false,
        message: e.toString(),
      );
    }
    // return await MikrotikClient.addData(
    //   command: "/tool/user-manager/user/create-and-activate-profile", 
    //   data: {
    //     "customer":customer,
    //     "numbers":username,
    //     "profile":profile,
    //   }
    // );
  }

  Future<AppResponse> addOneCard({
    required String customer,
    required String username,
    String password="",
    required String profile,
  })async{
    try {
      await MikrotikClient.addData(
        command: "/tool/user-manager/user/add", 
        data: {
          "customer":customer,
          "username":username,
          "password":password,
        }
      );
      
      await MikrotikClient.addData(
        command: "/tool/user-manager/user/create-and-activate-profile", 
        data: {
          "customer":customer,
          "numbers":username,
          "profile":profile,
        }
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
  
  Future<List> getCustomers()async{
    return await MikrotikClient.printData(
      commands: ["/tool/user-manager/customer/print"],
      conditions: ["?disabled=no"]
    );
  }

  Future<AppResponse> cardEdit({
    required String username,
    required Map<String, String> data,
  })async{
    try {
      await MikrotikClient.editData(
        command: "/tool/user-manager/user/set", 
        data: data, 
        condition: "?username=$username"
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse(
        status: false,
        message: e.toString(),
      );
    }
  }
  
  Future<AppResponse> deleteCard(String username)async{
    try {
      await MikrotikClient.deleteData(
        command: "/tool/user-manager/user/remove", 
        condition: "?username=$username"
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  Future<AppResponse> deleteCardsBatch(List idsList)async{
    try {
      String ids = idsList.join(',');
      await MikrotikClient.fetch(
        command: [
          "/tool/user-manager/user/remove",
          '=numbers=$ids'
        ], 
      );
      return AppResponse(
        status: true,
        message: "done",
      );
    } on Exception catch (e) {
      return AppResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

  

  // Future<String> cardRenew({
  //   required String username,
  //   required String profile,
  //   required String customer,
  // })async{
  //   try {
      
  //     await addCardProfile(
  //       customer: customer, 
  //       username: username, 
  //       profile: profile
  //     );
  //     return "done";
  //   } on Exception catch (e) {
  //     return "error:${e.toString()}";
  //   }
  // }


  Future<AppResponse> getCardSessions(String username)async{
    try {
      List sessions =await MikrotikClient.printData(
        commands: ["/tool/user-manager/session/print"],
        conditions: ["?user=$username"]
      );
      List result=[];
      for (var session in sessions) {
        result.add(
          CardSessionModel.fromMap(session)
        );
      }
      return AppResponse(
        status: true, 
        message: "done",
        data: result
      );
    } catch (e) {
      return AppResponse(
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





