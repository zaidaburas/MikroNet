import 'package:get/get.dart';
import 'package:mikronet/controllers/dialog_helper.dart';
import 'package:mikronet/core/routes/app_pages.dart';

class MoreSettingsController extends GetxController {
  
  // دالة الانتقال لصفحة النسخ الاحتياطي والاستعادة
  void goToBackupAndRestore() {
    Get.toNamed(AppRoutes.backup);
  }

  // دالة إعادة تشغيل النظام (الراوتر)
  void rebootSystem() {
    showConfirmDialog(message: "هل انت متاكد من اعادة تشغيل النظام", onConfirm: _executeReboot);
  }
  void _executeReboot()async{
    showMsgDialog(message: "rebooted",type: MsgType.success);
  }
}