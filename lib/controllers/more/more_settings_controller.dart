import 'package:get/get.dart';

class MoreSettingsController extends GetxController {
  
  // دالة الانتقال لصفحة النسخ الاحتياطي والاستعادة
  void goToBackupAndRestore() {
    // اكتب كود التوجيه هنا لاحقاً
    // مثال: Get.toNamed('/backup');
    print("الذهاب إلى صفحة النسخ الاحتياطي");
  }

  // دالة إعادة تشغيل النظام (الراوتر)
  void rebootSystem() {
    // اكتب كود الاتصال بالـ API لإعادة التشغيل هنا لاحقاً
    // يفضل إضافة Get.defaultDialog لاحقاً لتأكيد العملية قبل التنفيذ
    print("جاري إعادة تشغيل النظام...");
  }
}