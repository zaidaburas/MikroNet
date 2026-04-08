import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من استيراد ملف الـ API الخاص بك هنا
import '/api/sites_api.dart'; 

class DnsController extends GetxController {
  // متغيرات لمراقبة حالة التحميل والسويتش
  var isLoading = true.obs;
  var allowRemoteRequest = false.obs;

  // تعريف TextControllers داخل المتحكم لضمان عدم تسريب الذاكرة
  late TextEditingController primaryCtrl;
  late TextEditingController secondaryCtrl;

  @override
  void onInit() {
    super.onInit();
    primaryCtrl = TextEditingController();
    secondaryCtrl = TextEditingController();
    // جلب البيانات عند فتح الصفحة
    fetchDnsData();
  }

  @override
  void onClose() {
    primaryCtrl.dispose();
    secondaryCtrl.dispose();
    super.onClose();
  }

  // الدالة الأولى: جلب بيانات الـ DNS من المايكروتك
  Future<void> fetchDnsData() async {
    isLoading.value = true;
    var response = await SitesApi.getDnsData();
    
    if (response.status && response.data != null && response.data.isNotEmpty) {
      // مايكروتك غالباً يُرجع البيانات كقائمة من الـ Maps
      var data = response.data[0];
      
      // ضبط السويتش
      if (data['allow-remote-requests'] != null) {
        allowRemoteRequest.value = data['allow-remote-requests'] == 'yes' || data['allow-remote-requests'] == 'true';
      }
      
      // فصل السيرفرات (لأن مايكروتك يرسلها مفصولة بفاصلة "8.8.8.8,1.1.1.1")
      if (data['servers'] != null) {
        List<String> servers = data['servers'].toString().split(',');
        if (servers.isNotEmpty) primaryCtrl.text = servers[0].trim();
        if (servers.length > 1) secondaryCtrl.text = servers[1].trim();
      }
    } else {
      Get.snackbar("تنبيه", "فشل في جلب إعدادات DNS الحالية", 
        backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
    isLoading.value = false;
  }

  // الدالة الثانية: حفظ البيانات الجديدة
  Future<void> saveDnsSettings() async {
    isLoading.value = true;
    var response = await SitesApi.setDns(
      main: primaryCtrl.text,
      secondary: secondaryCtrl.text,
      allowRemoteRequests: allowRemoteRequest.value,
    );

    if (response.status) {
      Get.snackbar(
        "نجاح", 
        "تم تحديث إعدادات DNS بنجاح",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(15)
      );
    } else {
      Get.snackbar(
        "خطأ", 
        response.message ?? "حدث خطأ أثناء الحفظ",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isLoading.value = false;
  }
}