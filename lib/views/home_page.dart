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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            // الهيدر
            HomeHeader(
              pulseAnimation: controller.pulseController,
              onLogout: controller.logout,
            ),
            
            // منطقة الكروت الدوارة - مغلفة بـ Obx لمراقبة تغير الصفحات والقيم
            Obx(() => HomeCarousel(
              controller: controller.pageController,
              currentPage: controller.currentPage.value,
              onPageChanged: controller.updateCurrentPage,
              items: _buildCarouselItems(),
            )),
            
            _buildSectionTitle("إدارة النظام والعمليات"),
            
            // شبكة الأزرار
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

  // تم إزالة كلمة const من الكروت بسبب استخدام المتغيرات التفاعلية
  List<Widget> _buildCarouselItems() {
    return [
      ActionCarouselItem(
        category: "إجراء سريع",
        title: "توليد كرت واحد",
        subtitle: "إنشاء كرت مستخدم فوري",
        icon: Icons.add_moderator_rounded,
        color: const Color(0xFF2563EB),
        actionText: "ابدأ الإضافة",
        onTap: controller.generateSingleCard, // استدعاء الدالة
      ),
      ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "حمل المعالج (CPU)",
        percent: controller.cpuPercent.value, // قيمة تفاعلية
        icon: Icons.speed_rounded,
        color: Colors.cyanAccent,
      ),
      ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "استهلاك الرام (RAM)",
        percent: controller.ramPercent.value, // قيمة تفاعلية
        icon: Icons.memory_rounded,
        color: Colors.purpleAccent,
      ),
      ActionCarouselItem(
        category: "الأمن والرقابة",
        title: "قائمة الحظر",
        subtitle: "مستخدمين تم تقييدهم",
        value: controller.blockedUsersCount.value, // قيمة تفاعلية
        icon: Icons.block_flipped,
        color: const Color(0xFFDC2626),
        actionText: "إدارة الحظر",
        onTap: controller.manageBlockedUsers, // استدعاء الدالة
      ),
      ActionCarouselItem(
        category: "تنبيه النظام",
        title: "مساحة القرص",
        subtitle: "قاعدة بيانات السيرفر",
        value: controller.diskSpace.value, // قيمة تفاعلية
        icon: Icons.storage_rounded,
        color: const Color(0xFF10B981),
        actionText: "فحص القرص",
        onTap: controller.checkDiskSpace, // استدعاء الدالة
      ),
      ActionCarouselItem(
        category: "تقارير مالية",
        title: "مبيعات اليوم",
        subtitle: "إجمالي الكروت المباعة",
        value: controller.dailySales.value, // قيمة تفاعلية
        icon: Icons.auto_graph_rounded,
        color: const Color(0xFF0EA5E9),
        actionText: "عرض التقارير",
        onTap: controller.viewDailySales, // استدعاء الدالة
      ),
    ];
  }

  // تم ربط الأزرار بالدوال المخصصة مباشرة
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
        onTap: menuData[index]['onTap'], // استدعاء الدالة مباشرة بدون نصوص
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