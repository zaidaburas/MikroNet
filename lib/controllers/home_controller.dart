import 'package:get/get.dart';
import '/core/routes/app_pages.dart';
import 'dialog_helper.dart';

class HomeController extends GetxController {
  
  void navigateToTarget(String target) {
    final String clean = target.trim();
    
    if (clean.contains("الكروت")) {
      Get.toNamed(AppRoutes.cards);
    } else if (clean.contains("المستخدمين")) {
      Get.toNamed(AppRoutes.users);
    } else if (clean.contains("قوالب")) {
      Get.toNamed(AppRoutes.print);
    } else if (clean.contains("البيانات") || clean.contains("السيرفر")) {
      Get.toNamed(AppRoutes.sites);
    } else if (clean.contains("الإحصائيات") || clean.contains("تقارير")) {
      Get.toNamed(AppRoutes.reports);
    } else if (clean.contains("النسخ") || clean.contains("احتياطي")) {
      Get.toNamed(AppRoutes.backup);
    } else {
      showMsgDialog(message: "هذه الواجهة غير متوفرة حالياً");
    }
  }
}