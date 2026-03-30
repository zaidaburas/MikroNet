import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/sites_controller.dart';

// استيراد الـ Widgets الموحدة (تأكد من صحة المسارات في مشروعك)
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/cards/main_action_card.dart';
import '../widgets/shared/typography/section_title.dart';

// استيراد الصفحات الفرعية
import '../sites/dns_settings.dart';
import '../sites/black_sites.dart' show BlockedSitesView;
import '../sites/dns_cache.dart' show DnsCacheView;

class DataManagementView extends StatelessWidget {
  const DataManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
           
            const MainGateHeader(
              title: "إدارة المواقع",
              subtitle: "إعدادات DNS وحظر عناوين الشبكة",
              icon: Icons.public_rounded,
            ),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SectionTitle(title: "إعدادات الشبكة"),
                  MainActionCard(
                    title: "إعدادات DNS",
                    subtitle: "Remote Request • DNS Servers",
                    icon: Icons.settings_ethernet_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () => _navigateTo(context, const DnsSettingsView()),
                  ),
                  const SizedBox(height: 10),
                  const SectionTitle(title: "السجلات المؤقتة"),
                  MainActionCard(
                    title: "DNS Cache",
                    subtitle: "عرض وحذف السجلات المؤقتة",
                    icon: Icons.dns_rounded,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _navigateTo(context, const DnsCacheView()),
                  ),
                  const SizedBox(height: 10),
                  const SectionTitle(title: "الرقابة والحماية"),
                  MainActionCard(
                    title: "المواقع المحظورة",
                    subtitle: "إضافة • حذف • إدارة الحظر",
                    icon: Icons.block_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () => _navigateTo(context, const BlockedSitesView()),
                  ),
                ],
              ),
            ),


            const AppMiniFooter(sectionName: "إدارة الشبكة والمواقع"),
          ],
        ),
      ),
    );
  }

  
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: context.read<DataMgmtVM>(),
          child: page,
        ),
      ),
    );
  }
}
