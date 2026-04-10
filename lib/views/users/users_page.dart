import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/core/routes/app_pages.dart';

// استيراد الـ Widgets الموحدة
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/cards/main_action_card.dart';
import '../widgets/shared/typography/section_title.dart';

// استيراد الصفحات الفرعية
import 'connected_users.dart';
import 'devices_manager.dart';
import 'hosts_view.dart';

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
                    title: " - Hosts - المتصلين حالياً",
                    subtitle: "عرض الجلسات النشطة وسرعة الاستهلاك",
                    icon: Icons.devices_rounded,
                    color: const Color.fromARGB(255, 16, 95, 185),
                    onTap: () => Get.toNamed(AppRoutes.hostUsers),
                  ),
                  MainActionCard(
                    title: " - Active - المتصلين حالياً",
                    subtitle: "عرض الجلسات النشطة وسرعة الاستهلاك",
                    icon: Icons.online_prediction_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () => Get.toNamed(AppRoutes.activeUsers)
                  ),


                  const SizedBox(height: 15),

                  const SectionTitle(title: "التحكم والأمان"),
                  
                  MainActionCard(
                    title: "إدارة الأجهزة",
                    subtitle: "التحكم في MAC Address وحظر الأجهزة",
                    icon: Icons.important_devices_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () => Get.toNamed(AppRoutes.binding),
                  ),
                ],
              ),
            ),

            // 4. الفوتر مع تمرير اسم القسم المطلوب (حل المشكلة)
            const AppMiniFooter(title:Text( "إدارة المستخدمين")),
          ],
        ),
      ),
    );
  }
}
