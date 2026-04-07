import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api/cards_api.dart'; //
import '/api/profiles_api.dart'; //
import '/models/profiles_model.dart'; //
import '/models/response.dart';
import '/controllers/dialog_helper.dart';

class AddSingleCardController extends GetxController {
  // الحقول النصية
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // الحالات التفاعلية
  RxBool isLoading = false.obs;
  RxBool isProfilesLoading = true.obs;
  
  // قائمة الباقات المختارة
  RxList<ProfilesModel> profiles = <ProfilesModel>[].obs;
  Rxn<ProfilesModel> selectedProfile = Rxn<ProfilesModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfiles(); // جلب الباقات عند التشغيل
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }

  // جلب الباقات من ProfilesApi
  Future<void> fetchProfiles() async {
    isProfilesLoading.value = true;
    try {
      AppResponse<List<ProfilesModel>> response = await ProfilesApi.getProfiles(); //
      if (response.status && response.data != null) {
        profiles.assignAll(response.data!);
        if (profiles.isNotEmpty) {
          selectedProfile.value = profiles.first; // تحديد أول باقة تلقائياً
        }
      } else {
        showMsgDialog(message: "فشل جلب الباقات: ${response.message}");
      }
    } catch (e) {
      showMsgDialog(message: "خطأ في الاتصال: $e");
    } finally {
      isProfilesLoading.value = false;
    }
  }

  // دالة حفظ الكرت
  Future<void> saveCard() async {
    if (usernameCtrl.text.isEmpty || selectedProfile.value == null) {
      showMsgDialog(message: "يرجى إدخال اسم المستخدم واختيار الباقة");
      return;
    }

    isLoading.value = true;
    try {
      // إرسال الطلب عبر CardsApi
      AppResponse<void> response = await CardsApi.addOneCard(
        customer: "admin", // يمكن تغييرها حسب المستخدم الحالي
        username: usernameCtrl.text,
        password: passwordCtrl.text,
        profile: selectedProfile.value!.name,
      );

      if (response.status) {
        Get.back(); // العودة للخلف بعد النجاح
        showMsgDialog(message: "تم إضافة الكرت بنجاح");
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      showMsgDialog(message: "خطأ أثناء الحفظ: $e");
    } finally {
      isLoading.value = false;
    }
  }
}