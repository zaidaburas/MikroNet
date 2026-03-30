import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/sites_controller.dart';
// استيراد الويجيت الموحدة v4.5 لضمان تناسق الهوية
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class DnsCacheView extends StatelessWidget {
  const DnsCacheView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DataMgmtVM>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),

        // 1. الزر العائم في موقعه الطبيعي (الزاوية) مع رفعة 90 بكسل
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: FloatingActionButton.extended(
            onPressed: vm.clearCache,
            backgroundColor: const Color(0xFF1E3A8A),
            elevation: 8,
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            label: const Text(
              "مسح التخزين المؤقت",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        body: Column(
          children: [
            // 2. الهيدر الموحد لصفحات MikroNet
            const PremiumHeader(
              title: "سجلات DNS",
              subtitle: "مراقبة وإدارة التخزين المؤقت لـ MikroTik",
              icon: Icons.dns_rounded,
            ),

            const SectionTitle(title: "إحصائيات السجلات الحالية"),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // بطاقة الإحصائية بتصميم v4.5 المطور
                    _buildStatCard(vm.mikrotikSites.length),

                    const SizedBox(height: 10),
                    const SectionTitle(title: "قائمة عناوين الـ DNS"),

                    Expanded(
                      child: vm.mikrotikSites.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              // Padding سفلي لتجنب الزر المرفوع
                              padding:
                                  const EdgeInsets.only(bottom: 160, top: 10),
                              itemCount: vm.mikrotikSites.length,
                              itemBuilder: (context, i) {
                                final site = vm.mikrotikSites[i];
                                return _buildDnsItemCard(vm, site);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. الفوتر الموحد v4.5
            const AppMiniFooter(sectionName: "DNS Monitor Engine"),
          ],
        ),
      ),
    );
  }

  /* ================= بطاقة الإحصائيات الملونة ================= */
  Widget _buildStatCard(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1E3A8A), Color(0xff3B82F6)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1E3A8A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.speed_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("إجمالي السجلات",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                "$count سجل نشط",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ================= كرت سجل DNS الفردي ================= */
  Widget _buildDnsItemCard(DataMgmtVM vm, Map<String, String> site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffF0F7FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.language_rounded,
              color: Color(0xff1E3A8A), size: 22),
        ),
        title: Text(
          site['name'] ?? "Unknown Host",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1E293B)),
        ),
        subtitle: Text(
          site['address'] ?? "0.0.0.0",
          style: TextStyle(
              color: Colors.blueGrey.shade400, fontSize: 12, letterSpacing: 1),
        ),
        trailing: IconButton(
          icon:
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          onPressed: () => vm.deleteSite(site['id']!),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 60, color: Colors.blue.withOpacity(0.2)),
          const SizedBox(height: 15),
          const Text("الذاكرة نظيفة تماماً",
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
