import 'package:get/get.dart';
import 'package:flutter/material.dart';
// تأكد من صحة هذه المسارات حسب مجلدات مشروعك
import '../../models/selles_model.dart';
import '../../services/response.dart'; 
import '../../api/reports_api.dart'; // مسار ملف الـ API الذي قمنا بإنشائه

class SystemStatusController extends GetxController {
  // حالة التحميل
  RxBool isLoading = false.obs;
  
  // المتغير الذي سيحمل بيانات النظام
  Rx<SystemStateModel?> systemState = Rx<SystemStateModel?>(null);

  @override
  void onInit() {
    super.onInit();
    // جلب البيانات تلقائياً عند فتح الصفحة
    fetchSystemStatus();
  }

  // دالة جلب بيانات النظام الحقيقية من الـ API
  Future<void> fetchSystemStatus() async {
    isLoading.value = true;
    
    try {
      // استدعاء الـ API الحقيقي
      AppResponse<SystemStateModel> response = await ReportsApi.getSystemState();

      if (response.status && response.data != null) {
        // إذا نجح الطلب، قم بتعيين البيانات
        systemState.value = response.data;
      } else {
        // إذا فشل الطلب (مثلا السيرفر مفصول)، اعرض رسالة الخطأ القادمة من الـ API
        Get.snackbar(
          "تنبيه", 
          response.message ?? "فشل في جلب البيانات", 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ", 
        "حدث خطأ أثناء الاتصال بالراوتر: $e", 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}