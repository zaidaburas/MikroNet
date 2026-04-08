import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controllers/home_controller.dart';

// استيراد الـ Widgets الخاصة بك
import './widgets/home_header.dart';
import './widgets/home_carousel.dart';
import './widgets/menu_item_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            HomeHeader(
              pulseAnimation: controller.pulseController,
              onLogout: controller.logout,
            ),
            
            Obx(() => HomeCarousel(
              controller: controller.pageController,
              currentPage: controller.currentPage.value,
              onPageChanged: controller.updateCurrentPage,
              items: _buildCarouselItems(),
            )),
            
            _buildSectionTitle("إدارة النظام والعمليات"),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGridMenu(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ترتيب الكروت والبيانات كما طلبت
  List<Widget> _buildCarouselItems() {
    return [
      // 1. توليد كرت واحد
      ActionCarouselItem(
        category: "إجراء سريع",
        title: "توليد كرت واحد",
        subtitle: "إنشاء كرت مستخدم فوري",
        icon: Icons.add_moderator_rounded,
        color: const Color(0xFF2563EB),
        actionText: "ابدأ الإضافة",
        onTap: controller.generateSingleCard, 
      ),
      // 2. المتصلين النشطين
      ActionCarouselItem(
        category: "مراقبة الشبكة",
        title: "المتصلين النشطين",
        subtitle: "أجهزة تسحب بيانات الآن",
        value: controller.activeUsersCount.value, 
        icon: Icons.online_prediction_rounded,
        color: const Color(0xFF10B981), // لون أخضر يعبر عن النشاط
        actionText: "عرض المتصلين",
        onTap: controller.manageActiveUsers, 
      ),
      // 3. وقت التشغيل (Uptime)
      ActionCarouselItem(
        category: "حالة النظام",
        title: "وقت التشغيل",
        subtitle: "مدة عمل الراوتر (Uptime)",
        value: controller.uptime.value, 
        icon: Icons.timer_rounded,
        color: const Color(0xFFF59E0B), // برتقالي
        actionText: "تقارير النظام",
        onTap: controller.viewUptimeDetails, 
      ),
      // 4. حمل المعالج
      ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "حمل المعالج (CPU)",
        percent: controller.cpuPercent.value, 
        icon: Icons.speed_rounded,
        color: Colors.cyanAccent,
      ),
      // 5. استهلاك الرام
      ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "استهلاك الرام (RAM)",
        percent: controller.ramPercent.value, 
        icon: Icons.memory_rounded,
        color: Colors.purpleAccent,
      ),
      // 6. مساحة القرص
      ActionCarouselItem(
        category: "تنبيه النظام",
        title: "مساحة القرص",
        subtitle: "قاعدة بيانات السيرفر",
        value: controller.diskSpace.value, 
        icon: Icons.storage_rounded,
        color: const Color(0xFF64748B),
        actionText: "فحص القرص",
        onTap: controller.checkDiskSpace, 
      ),
    ];
  }

  Widget _buildGridMenu() {
    final List<Map<String, dynamic>> menuData = [
      {
        "title": "إدارة الكروت",
        "icon": Icons.credit_card_rounded,
        "onTap": controller.goToCards
      },
      {
        "title": "المستخدمين",
        "icon": Icons.people_alt_rounded,
        "onTap": controller.goToUsers
      },
      {
        "title": "ادارة عملية الطباعة",
        "icon": Icons.print_rounded,
        "onTap": controller.goToPrint
      },
      {
        "title": "اعدادات المواقع",
        "icon": Icons.dns_rounded,
        "onTap": controller.goToSites
      },
      {
        "title": "التقارير",
        "icon": Icons.analytics_rounded,
        "onTap": controller.goToReports
      },
      {
        "title": "المزيد من الاعدادات",
        "icon": Icons.tune_rounded,
        "onTap": controller.goToMoreSettings
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 30),
      itemCount: menuData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) => MenuItemCard(
        title: menuData[index]['title'],
        icon: menuData[index]['icon'],
        onTap: menuData[index]['onTap'], 
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B)),
        ),
      ),
    );
  }
}