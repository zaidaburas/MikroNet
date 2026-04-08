import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/routes/app_pages.dart';

// تأكد من صحة مسارات الـ API حسب مشروعك
import '/api/users_api.dart'; 
import '/api/reports_api.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  
  // ================= القيم التفاعلية (المتغيرة) الحقيقية =================
  var cpuPercent = "0%".obs;
  var ramPercent = "0%".obs;
  var activeUsersCount = "0 متصل".obs; // استبدلناها بقائمة الحظر
  var uptime = "00:00:00".obs; // استبدلناها بالمبيعات
  var diskSpace = "--".obs; // مساحة القرص (يمكنك جلبها لاحقاً إذا أضفتها للمودل)
  var currentPage = 0.obs;

  // ================= متحكمات الواجهة والحركة =================
  late PageController pageController;
  late AnimationController pulseController;
  Timer? carouselTimer;
  Timer? dataRefreshTimer; // مؤقت لتحديث بيانات السيرفر

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startCarouselTimer();
    
    // جلب البيانات فور فتح الصفحة
    fetchRealData();
    // تشغيل مؤقت يحدث البيانات كل 10 ثواني (يمكنك تقليل أو زيادة المدة)
    _startDataRefreshTimer();
  }

  @override
  void onClose() {
    carouselTimer?.cancel();
    dataRefreshTimer?.cancel();
    pageController.dispose();
    pulseController.dispose();
    super.onClose();
  }

  void _startCarouselTimer() {
    carouselTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (pageController.hasClients) {
        int nextItem = currentPage.value + 1;
        if (nextItem >= 6) { 
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

  void _startDataRefreshTimer() {
    dataRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchRealData();
    });
  }

  // ================= دالة جلب البيانات الحقيقية من السيرفر =================
  Future<void> fetchRealData() async {
    // 1. جلب بيانات النظام (CPU, RAM, Uptime)
    var sysResponse = await ReportsApi.getSystemState();
    if (sysResponse.status && sysResponse.data != null) {
      var sys = sysResponse.data!;
      cpuPercent.value = "${sys.cpu}%";
      uptime.value = sys.uptime; // يمكنك استخدام الـ extension الخاصة بالوقت هنا إذا أردت تنسيقها

      // حساب نسبة استهلاك الرام (المستخدم / الإجمالي * 100)
      double totalRam = double.tryParse(sys.totalMemory) ?? 0;
      double freeRam = double.tryParse(sys.freeMemory) ?? 0;
      if (totalRam > 0) {
        int ramUsagePercent = (((totalRam - freeRam) / totalRam) * 100).toInt();
        ramPercent.value = "$ramUsagePercent%";
      }
    }

    // 2. جلب عدد المتصلين النشطين
    var activeResponse = await UsersApi.getAllActive();
    if (activeResponse.status && activeResponse.data != null) {
      activeUsersCount.value = "${activeResponse.data!.length} متصل";
    }
  }

  void updateCurrentPage(int index) {
    currentPage.value = index;
  }

  // ================= دوال أزرار الـ Carousel =================
  void generateSingleCard() {
    // توجيه لصفحة إنشاء كرت
    print("إجراء: توليد كرت واحد");
  }

  void manageActiveUsers() {
    // توجيه لصفحة المتصلين النشطين
    Get.toNamed(AppRoutes.users); 
  }

  void viewUptimeDetails() {
    // توجيه لصفحة تقارير النظام
    Get.toNamed(AppRoutes.reports); 
  }

  void checkDiskSpace() {
    print("إجراء: فحص مساحة القرص");
  }

  // ================= دوال التنقل للأقسام (Grid) =================
  void goToCards() => Get.toNamed(AppRoutes.cards);
  void goToUsers() => Get.toNamed(AppRoutes.users);
  void goToPrint() => Get.toNamed(AppRoutes.print);
  void goToSites() => Get.toNamed(AppRoutes.sites);
  void goToReports() => Get.toNamed(AppRoutes.reports);
  void goToMoreSettings() => Get.toNamed(AppRoutes.more);

  void logout() {
    Get.back(); 
  }
}