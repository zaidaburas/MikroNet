import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/controllers/home_controller.dart';

// استيراد الـ Widgets الجديدة
import './widgets/home_header.dart';
import './widgets/home_carousel.dart';
import './widgets/menu_item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  
  // ربط المتحكم بالواجهة
  final HomeController controller = Get.put(HomeController());

  late PageController _pageController;
  late AnimationController _pulseController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startCarouselTimer();
  }

  // نقلنا مؤقت الحركة التلقائية للـ Carousel إلى الواجهة هنا
  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextItem = _currentPage + 1;
        if (nextItem >= 6) { // 6 هو عدد الكروت الموجودة في الـ Carousel
          nextItem = 0;
        }
        _pageController.animateToPage(
          nextItem,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            HomeHeader(
              pulseAnimation: _pulseController,
              onLogout: () => Navigator.pop(context),
            ),
            HomeCarousel(
              controller: _pageController,
              currentPage: _currentPage,
              onPageChanged: (i) => setState(() => _currentPage = i),
              items: _buildCarouselItems(context),
            ),
            _buildSectionTitle("إدارة النظام والعمليات"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGridMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCarouselItems(BuildContext context) {
    return [
      ActionCarouselItem(
        category: "إجراء سريع",
        title: "توليد كرت واحد",
        subtitle: "إنشاء كرت مستخدم فوري",
        icon: Icons.add_moderator_rounded,
        color: const Color(0xFF2563EB),
        actionText: "ابدأ الإضافة",
        onTap: () {}
      ),
      const ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "حمل المعالج (CPU)",
        percent: "34%",
        icon: Icons.speed_rounded,
        color: Colors.cyanAccent,
      ),
      const ResourceCarouselItem(
        category: "مراقبة الأداء",
        label: "استهلاك الرام (RAM)",
        percent: "58%",
        icon: Icons.memory_rounded,
        color: Colors.purpleAccent,
      ),
      ActionCarouselItem(
        category: "الأمن والرقابة",
        title: "قائمة الحظر",
        subtitle: "مستخدمين تم تقييدهم",
        value: "14 مستخدم",
        icon: Icons.block_flipped,
        color: const Color(0xFFDC2626),
        actionText: "إدارة الحظر",
        onTap: () {},
      ),
      ActionCarouselItem(
        category: "تنبيه النظام",
        title: "مساحة القرص",
        subtitle: "قاعدة بيانات السيرفر",
        value: "12% مستخدم",
        icon: Icons.storage_rounded,
        color: const Color(0xFF10B981),
        actionText: "فحص القرص",
        onTap: () {},
      ),
      ActionCarouselItem(
        category: "تقارير مالية",
        title: "مبيعات اليوم",
        subtitle: "إجمالي الكروت المباعة",
        value: "285 كرت",
        icon: Icons.auto_graph_rounded,
        color: const Color(0xFF0EA5E9),
        actionText: "عرض التقارير",
        onTap: () {},
      ),
    ];
  }

  Widget _buildGridMenu(BuildContext context) {
    final List<Map<String, dynamic>> menuData = [
      {
        "title": "إدارة الكروت",
        "icon": Icons.credit_card_rounded,
        "view": "الكروت"
      },
      {
        "title": "المستخدمين",
        "icon": Icons.people_alt_rounded,
        "view":  "المستخدمين"
      },
      {
        "title": "ادارة عملية الطباعة",
        "icon": Icons.print_rounded,
        "view": "قوالب"
      },
      {
        "title": "بيانات السيرفر",
        "icon": Icons.dns_rounded,
        "view": "البيانات"
      },
      {
        "title": "التقارير",
        "icon": Icons.analytics_rounded,
        "view": "الإحصائيات"
      },
      {
        "title": "النسخ الاحتياطي",
        "icon": Icons.cloud_sync_rounded,
        "view": "النسخ"
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
        // تم إصلاح السطر أدناه بإضافة الدالة المجهولة () => لمنع التنفيذ التلقائي
        onTap: () => controller.navigateToTarget(menuData[index]['view']),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Align(
          alignment: Alignment.centerRight,
          child: Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B)))),
    );
  }
}