import 'package:get/get.dart';
import '/core/routes/app_pages.dart'; 

class CardsManagementController extends GetxController {
  
  
  void goBack() {
    Get.back();
  }

  void goToCardsList() {
    Get.toNamed(AppRoutes.cardsList);
  }

  void goToAddSingleCard() {
    Get.toNamed(AppRoutes.addSingleCard);
  }

  void goToPackages() {
    Get.toNamed(AppRoutes.packages);
  }

  void goToBatches() {
    //Get.toNamed(AppRoutes.batches);
  }

}