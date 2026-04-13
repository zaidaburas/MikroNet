import 'package:get/get.dart';
import '../../core/app_pages.dart'; // استيراد المسارات

class UsersManagementController extends GetxController {

  void goBack() {
    Get.back();
  }

  void goToActiveUsers() {
    //Get.toNamed(AppRoutes.activeUsers);
  }

  void goToDevices() {
    //Get.toNamed(AppRoutes.devices);
  }
}