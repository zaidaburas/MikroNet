import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/sites_controller.dart';
// استيراد الويجيت الموحدة v4.5 لضمان التوريث البصري
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class BlockedSitesView extends StatelessWidget {
  const BlockedSitesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DataMgmtVM>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // الخلفية الرسمية للنظام

        // 1. الزر العائم في موقعه الطبيعي (الزاوية) مع رفعة احترافية
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
              bottom: 90), // الرفعة المطلوبة لتجاوز الفوتر
          child: FloatingActionButton.extended(
            onPressed: () => _showAddSiteDialog(context, vm),
            backgroundColor: const Color(0xFF1E3A8A), // اللون الكحلي الأمني
            elevation: 8,
            icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
            label: const Text(
              "حظر جديد",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),

        body: Column(
          children: [
            // 2. الهيدر الموحد لصفحات MikroNet الفرعية
            const PremiumHeader(
              title: "جدار الحماية",
              subtitle: "إدارة قائمة المواقع المحظورة في الشبكة",
              icon: Icons.security_rounded,
            ),

            const SectionTitle(title: "المواقع المقيدة حالياً"),

            Expanded(
              child: vm.blockedSites.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      // padding سفلي لضمان عدم اختفاء العناصر خلف الزر المرفوع
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 160),
                      itemCount: vm.blockedSites.length,
                      itemBuilder: (context, i) {
                        final site = vm.blockedSites[i];
                        return _buildSiteCard(context, vm, site);
                      },
                    ),
            ),

            // 3. الفوتر الموحد v4.5
            const AppMiniFooter(sectionName: "Security Engine"),
          ],
        ),
      ),
    );
  }

  /* ================= كرت الموقع بتصميم "أمني" عصري ================= */
  Widget _buildSiteCard(BuildContext context, DataMgmtVM vm, String site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade50,
          child:
              const Icon(Icons.public_off_rounded, color: Colors.red, size: 20),
        ),
        title: Text(
          site,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: IconButton(
          icon:
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          onPressed: () => vm.removeBlocked(site),
        ),
      ),
    );
  }

  /* ================= نافذة إضافة موقع جديد ================= */
  void _showAddSiteDialog(BuildContext context, DataMgmtVM vm) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text(
          "حظر نطاق جديد",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "مثال: youtube.com",
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("تراجع", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                vm.addBlocked(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child:
                const Text("حظر الآن", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /* ================= واجهة الحالة الفارغة ================= */
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 70, color: Colors.green.withOpacity(0.2)),
          const SizedBox(height: 15),
          const Text(
            "لا توجد مواقع محظورة حالياً",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
