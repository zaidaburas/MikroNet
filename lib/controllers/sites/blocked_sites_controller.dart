import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/models/sites_model.dart';
import '/api/sites_api.dart';
import '/models/response.dart';

// تأكد من تعديل هذا المسار ليطابق مكان تواجد ملف dialog_helper.dart عندك
import '/controllers/dialog_helper.dart'; 

class BlockedSitesController extends GetxController {
  String blockType = 'Domain'; // القيمة الافتراضية

  RxList<BlockedSiteModel> blockedList = <BlockedSiteModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      blockType = Get.arguments.toString();
    }
    fetchBlockedData();
  }

  // ================= 1. خريطة النصوص والواجهة =================
  late final Map<String, Map<String, String>> uiConfig = {
    'IP': {
      'title': "حظر العناوين (IP)",
      'subtitle': "منع وصول أجهزة محددة للشبكة",
      'hint': "مثال: 192.168.88.50",
    },
    'Domain': {
      'title': "حظر النطاقات (Domain)",
      'subtitle': "إدارة قائمة المواقع المحظورة في الشبكة",
      'hint': "مثال: youtube.com",
    },
    'Content': {
      'title': "حظر المحتوى (Filter)",
      'subtitle': "إسقاط الحزم التي تحتوي على كلمات محددة",
      'hint': "مثال: porn أو movies",
    },
  };

  // دوال استدعاء النصوص بسطر واحد
  String get pageTitle => uiConfig[blockType]?['title'] ?? "";
  String get pageSubtitle => uiConfig[blockType]?['subtitle'] ?? "";
  String get inputHint => uiConfig[blockType]?['hint'] ?? "";

  // ================= 2. خرائط دوال الـ API =================
  
  // خريطة دوال الجلب
  late final Map<String, Future<AppResponse<List<BlockedSiteModel>>> Function()> fetchActions = {
    'IP': SitesApi.getAllBlockedByIps,
    'Domain': SitesApi.getAllBlockedByDomains,
    'Content': SitesApi.getAllBlockedByContent,
  };

  // خريطة دوال الإضافة
  late final Map<String, Future<AppResponse<bool>> Function(String, String)> addActions = {
    'IP': SitesApi.blockByIp,
    'Domain': SitesApi.blockByDomain,
    'Content': SitesApi.blockByContent,
  };

  // خريطة دوال الحذف
  late final Map<String, Future<AppResponse<bool>> Function(String)> removeActions = {
    'IP': SitesApi.unblockByIp,
    'Domain': SitesApi.unblockByDomain,
    'Content': SitesApi.unblockByContent,
  };

  // ================= 3. الدوال الرئيسية (استدعاء ديناميكي) =================

  Future<void> fetchBlockedData() async {
    isLoading.value = true;
    try {
      final action = fetchActions[blockType];
      if (action != null) {
        final response = await action();
        if (response.status == true && response.data != null) {
          blockedList.value = response.data!;
        } else {
          Get.snackbar("خطأ", response.message ?? "حدث خطأ في الجلب");
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBlock(String value) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    final action = addActions[blockType];
    if (action != null) {
      final response = await action(value, "تمت الإضافة عبر MicroNet");
      
      Get.back(); // إغلاق دائرة التحميل
      
      if (response.status == true) {
        Get.back(); // إغلاق نافذة الإضافة
        fetchBlockedData();
        Get.snackbar("نجاح", response.message ?? "تمت العملية", backgroundColor: Colors.green.shade600, colorText: Colors.white);
      } else {
        Get.snackbar("فشل", response.message ?? "حدث خطأ أثناء الإضافة");
      }
    }
  }

  // التعديل تم هنا: استخدام showConfirmDialog
  void removeBlock(String id) {
    showConfirmDialog(
      message: "هل أنت متأكد من رغبتك في إزالة هذا الحظر؟ لا يمكن التراجع عن هذه الخطوة.",
      onConfirm: () async {
        
        // تأخير بسيط جداً للسماح لـ Get.back() الموجودة في ملف المساعد بإغلاق نافذة التأكيد أولاً
        await Future.delayed(const Duration(milliseconds: 150));

        // إظهار دائرة التحميل
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        
        final action = removeActions[blockType];
        if (action != null) {
          final response = await action(id);
          
          Get.back(); // إغلاق دائرة التحميل
          
          if (response.status == true) {
            fetchBlockedData();
            Get.snackbar("نجاح", response.message ?? "تم الحذف", backgroundColor: Colors.green.shade600, colorText: Colors.white);
          } else {
            Get.snackbar("فشل", response.message ?? "حدث خطأ أثناء الحذف");
          }
        }
      },
    );
  }
}