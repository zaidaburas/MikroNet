import 'package:mikronet/services/mikrotik_client.dart';
import 'package:mikronet/services/response.dart';

class ReportsApi {

  // دالة مساعدة: لتحويل صيغة تاريخ الدفع (MMM/DD/YYYY HH:mm:ss) إلى DateTime
  static DateTime? _parsePaymentDate(String dateStr) {
    try {
      // مثال للنص القادم: "jul/16/2025 11:32:32"
      var parts = dateStr.trim().split(' ');
      if (parts.length != 2) return null;

      // تفكيك التاريخ
      var dateParts = parts[0].split('/');
      if (dateParts.length != 3) return null;

      // خريطة لتحويل اسم الشهر المختصر إلى رقم
      const months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };

      // استخراج الشهر كـ int باستخدام الخريطة (افتراضي 1 إذا لم يتطابق)
      int month = months[dateParts[0].toLowerCase()] ?? 1; 
      int day = int.parse(dateParts[1]);   // 16
      int year = int.parse(dateParts[2]);  // 2025

      // تفكيك الوقت
      var timeParts = parts[1].split(':');
      if (timeParts.length != 3) return null;

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      int second = int.parse(timeParts[2]);

      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      print('خطأ في تحويل تاريخ الدفع: $dateStr -> $e');
      return null;
    }
  }

  static Future<List> getPayments()async{
    return await MikrotikClient.printData(
        commands: ["/tool/user-manager/payment/print"],
        fields: "user,trans-start,price" 
      );
  }

  static Future<List> getProfiles()async{
    return await MikrotikClient.printData(
        commands: ["/tool/user-manager/profile/print"],
      );
  }

  // الدالة الرئيسية: جلب المدفوعات وتصفيتها بين تاريخين
  static Future<List<Map<String, dynamic>>> getPaymentsBetweenDates(DateTime startDate, DateTime endDate) async {
    try {
      // تمديد تاريخ النهاية ليشمل آخر ثانية في اليوم
      DateTime adjustedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      // 1. جلب البيانات من المايكروتيك
      var allPayments = await getPayments();
      // var allProfiles = await getProfiles();
      // 2. فلترة البيانات
      var matchedPayments = allPayments.where((payment) {
        String? paymentTimeStr = payment['trans-start']; 
        if (paymentTimeStr == null || paymentTimeStr.isEmpty) return false;
        // تحويل النص إلى DateTime
        DateTime? paymentDate = _parsePaymentDate(paymentTimeStr);
        if (paymentDate == null) return false;
        // التحقق من النطاق الزمني
        bool isAfterStart = paymentDate.compareTo(startDate) >= 0;
        bool isBeforeEnd = paymentDate.compareTo(adjustedEndDate) <= 0;
        return isAfterStart && isBeforeEnd;
      }).toList();    
      List<Map<String, dynamic>> result=List<Map<String, dynamic>>.from(matchedPayments);
      // List<Map<String, dynamic>> packages=[];
      // for (var i in result) {
      //   Map profile=allProfiles.firstWhere((p)=> (int.parse(i["price"])/100) == (int.parse(p["price"])) );

      //   var temp=Map<String, dynamic>.from(i);
      //   temp['price']=(int.parse(i["price"])/100);
      //   temp['profile']=profile["name"];
      //   // temp.remove(key)

      //   packages.add(temp);
      // }
      // إرجاع النتيجة
      return result;

    } catch (e) {
      throw('حدث خطأ أثناء جلب أو فلترة المدفوعات: $e');
      // return [];
    }
  }



  static Future<AppResponse> getSallesReport({DateTime? from,DateTime? to})async{
    try {
      var result=await getPaymentsBetweenDates(from??DateTime(1900),to??DateTime(2200));
      var allProfiles = await getProfiles();
      List<Map<String, dynamic>> packages=[];
      for (var i in result) {
        Map profile=allProfiles.firstWhere((p)=> (int.parse(i["price"])/100) == (int.parse(p["price"])) );

        var temp=Map<String, dynamic>.from(i);
        temp['price']=(int.parse(i["price"])/100);
        temp['profile']=profile["name"];
        // temp.remove(key)

        packages.add(temp);
      }
      return AppResponse(status: true, message: "done",data: packages);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }
  

  static Future<AppResponse> getSystemState()async{
    try {
      var respone=await MikrotikClient.printData(
        commands: ["/system/resource/print"]
      );

      return AppResponse(status: true, message: "done",data: respone);
      
    } catch (e) {
      return AppResponse(status: false, message: e.toString());
    }
  }


}