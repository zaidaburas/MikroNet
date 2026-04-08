import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/routes/app_pages.dart'; // تأكد من المسار

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  
  // ================= القيم التفاعلية (المتغيرة) =================
  var cpuPercent = "34%".obs;
  var ramPercent = "58%".obs;
  var blockedUsersCount = "14 مستخدم".obs;
  var diskSpace = "12%".obs;
  var dailySales = "285 كرت".obs;
  var currentPage = 0.obs;

  // ================= متحكمات الواجهة والحركة =================
  late PageController pageController;
  late AnimationController pulseController;
  Timer? carouselTimer;

  @override
  void onInit() {
    super.onInit();
    // تهيئة متحكم الصفحات
    pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    
    // تهيئة متحكم النبض (الأنيميشن)
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startCarouselTimer();
  }

  @override
  void onClose() {
    carouselTimer?.cancel();
    pageController.dispose();
    pulseController.dispose();
    super.onClose();
  }

  // تشغيل التمرير التلقائي
  void _startCarouselTimer() {
    carouselTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (pageController.hasClients) {
        int nextItem = currentPage.value + 1;
        if (nextItem >= 6) { // 6 هو عدد الكروت في الكاروسيل
          nextItem = 0;
        }
        pageController.animateToPage(
          nextItem,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  // تحديث الصفحة الحالية عند السحب اليدوي
  void updateCurrentPage(int index) {
    currentPage.value = index;
  }

  // ================= دوال أزرار الـ Carousel =================
  void generateSingleCard() {
    // سيتم برمجتها لاحقاً
    print("إجراء: توليد كرت واحد");
  }

  void manageBlockedUsers() {
    // سيتم برمجتها لاحقاً
    print("إجراء: إدارة الحظر");
  }

  void checkDiskSpace() {
    // سيتم برمجتها لاحقاً
    print("إجراء: فحص مساحة القرص");
  }

  void viewDailySales() {
    // سيتم برمجتها لاحقاً
    print("إجراء: عرض مبيعات اليوم");
  }

  // ================= دوال التنقل للأقسام (Grid) =================
  void goToCards() => Get.toNamed(AppRoutes.cards);
  
  void goToUsers() => Get.toNamed(AppRoutes.users);
  
  void goToPrint() => Get.toNamed(AppRoutes.print);
  
  void goToSites() => Get.toNamed(AppRoutes.sites);
  
  void goToReports() => Get.toNamed(AppRoutes.reports);
  
  void goToMoreSettings() => Get.toNamed(AppRoutes.more);

  // دالة تسجيل الخروج
  void logout() {
    Get.back(); // أو التوجيه لصفحة تسجيل الدخول
  }
}