import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/reports_controller.dart';

// استيراد المكونات المشتركة الموحدة
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF8FAFC),
          body: Column(
            children: [
              // 1. الهيدر الموحد الفخم (سهم لليمين + أيقونة التحليل)
              const MainGateHeader(
                title: "التقارير والإحصائيات",
                subtitle: "تحليل المبيعات وحالة النظام الحية",
                icon: Icons.analytics_rounded,
              ),

              Expanded(
                child: Consumer<ReportsVM>(
                  builder: (context, vm, _) => ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SectionTitle(title: "مؤشرات الأداء الرئيسية"),
                      const SizedBox(height: 15),

                      // شبكة الإحصائيات بتصميم فخم
                      GridView.count(
                        shrinkWrap: true, // مهم لأننا داخل ListView
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 1.0,
                        children: [
                          _buildPremiumStatCard(
                            "إجمالي المبيعات",
                            "${vm.totalSales} \$",
                            Icons.payments_rounded,
                            const Color(0xFF10B981),
                          ),
                          _buildPremiumStatCard(
                            "المستخدمين",
                            "${vm.activeUsers}",
                            Icons.groups_rounded,
                            const Color(0xFF6366F1),
                          ),
                          _buildPremiumStatCard(
                            "حالة النظام",
                            vm.systemStatus,
                            Icons.auto_graph_rounded,
                            const Color(0xFF0EA5E9),
                          ),
                          _buildPremiumStatCard(
                            "التنبيهات",
                            "0",
                            Icons.notifications_active_rounded,
                            const Color(0xFFF59E0B),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // هنا يمكنك إضافة أزرار تقارير تفصيلية مستقبلاً بنفس نمط MainActionCard
                    ],
                  ),
                ),
              ),

              // 2. الفوتر الأسود الموحد (النسخة الاحترافية)
              const AppMiniFooter(
                  sectionName: "مركز التقارير والذكاء الاصطناعي"),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= MODERN STAT CARD ================= */
  Widget _buildPremiumStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
