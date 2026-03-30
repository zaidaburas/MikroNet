import 'package:flutter/material.dart';

// استيراد الـ Widgets الموحدة
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/cards/main_action_card.dart';
import '../widgets/shared/typography/section_title.dart';

// استيراد الصفحات الفرعية
import 'connected_users.dart';
import 'devices_manager.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // 1. الهيدر الموحد
            const MainGateHeader(
              title: "إدارة المستخدمين",
              subtitle: "مراقبة الجلسات النشطة والتحكم بالأجهزة",
              icon: Icons.manage_accounts_rounded,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  
                  const SectionTitle(title: "المراقبة المباشرة"),
                  
                  MainActionCard(
                    title: "المتصلين حالياً",
                    subtitle: "عرض الجلسات النشطة وسرعة الاستهلاك",
                    icon: Icons.wifi_tethering_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveUsersView()),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const SectionTitle(title: "التحكم والأمان"),
                  
                  MainActionCard(
                    title: "إدارة الأجهزة",
                    subtitle: "التحكم في MAC Address وحظر الأجهزة",
                    icon: Icons.important_devices_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DevicesView()),
                    ),
                  ),
                ],
              ),
            ),

            // 4. الفوتر مع تمرير اسم القسم المطلوب (حل المشكلة)
            const AppMiniFooter(sectionName: "إدارة المستخدمين"),
          ],
        ),
      ),
    );
  }
}
