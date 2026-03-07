import 'package:flutter/material.dart';
import 'users/users_page.dart' show UsersManagementView;
import '../controllers/login_controller.dart';
import 'cards/add_single_card_view.dart';
import 'cards/cards_view.dart';
import 'reports/sites_page.dart';
import 'reports/reports_page.dart';
import 'print/print_page.dart';
import 'backups/backup_view.dart';

// استيراد الـ Widgets الجديدة
import './widgets/home_header.dart';
import './widgets/home_carousel.dart';
import './widgets/menu_item_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key,});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSingleCardView())),
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
      {"title": "إدارة الكروت", "icon": Icons.credit_card_rounded, "view": const CardsManagementView()},
      {"title": "المستخدمين", "icon": Icons.people_alt_rounded, "view": const UsersManagementView()},
      {"title": "ادارة عملية الطباعة", "icon": Icons.print_rounded, "view": const PrintOperationsView()},
      {"title": "بيانات السيرفر", "icon": Icons.dns_rounded, "view": const DataManagementView()},
      {"title": "التقارير", "icon": Icons.analytics_rounded, "view": const ReportsView()},
      {"title": "النسخ الاحتياطي", "icon": Icons.cloud_sync_rounded, "view": const BackupView()},
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => menuData[index]['view'])),
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
