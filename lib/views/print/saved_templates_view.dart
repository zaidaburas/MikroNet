import 'package:flutter/material.dart';
import '../../Controllers/print_controller.dart';
import 'page_preview.dart';

// استيراد الويجيت الموحدة (المحرك الجديد للنظام)
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class SavedTemplatesView extends StatelessWidget {
  final PrintTemplatesController c;

  const SavedTemplatesView({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xffF1F5F9), // اللون الرمادي المعتمد للخلفيات
        body: Column(
          children: [
            // 1. استخدام الهيدر الفرعي الموحد (بدلاً من Stack و Container اليدوي)
            PremiumHeader(
              title: "مكتبة القوالب",
              subtitle: "إدارة وتعديل تصاميم الكروت المحفوظة",
              icon: Icons.bookmarks_rounded,
            ),

            const SectionTitle(title: "القوالب المتوفرة"),

            Expanded(
              child: AnimatedBuilder(
                animation: c,
                builder: (context, _) {
                  if (c.savedTemplates.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    itemCount: c.savedTemplates.length,
                    itemBuilder: (context, i) {
                      final t = c.savedTemplates[i];
                      return _buildTemplateCard(context, t, i);
                    },
                  );
                },
              ),
            ),

            // 2. استخدام الفوتر الموحد
            const AppMiniFooter(sectionName: "Template Library"),
          ],
        ),
      ),
    );
  }

  /* ================= كرت القالب المطوّر ================= */
  Widget _buildTemplateCard(BuildContext context, Map t, int index) {
    final rows = t['rows'] ?? 0;
    final cols = t['cols'] ?? 0;
    final total = rows * cols;
    final name = t['name'] ?? "قالب بدون اسم";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            25), // زوايا دائرية أكبر لتناسب الهوية الجديدة
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            // معاينة خلفية الكرت (Banner)
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]),
                image: t['background'] != null
                    ? DecorationImage(image: t['background'], fit: BoxFit.cover)
                    : null,
              ),
              child: Container(
                  color: Colors.black.withOpacity(0.1)), // طبقة تعتيم خفيفة
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A))),
                      _infoBadge("$total كرت", const Color(0xFF2563EB)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _gridIconDetail(Icons.grid_4x4_rounded, "$rows x $cols"),
                      const Spacer(),
                      Text(t['date'] ?? "",
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final dummyData = {
                              'total': total,
                              'prefix': 'USR-',
                              'suffix': '',
                              'name': name
                            };
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TemplatePreviewPage(
                                          controller: c,
                                          templateIndex: index,
                                          batchData: dummyData,
                                        )));
                          },
                          icon: const Icon(Icons.remove_red_eye_rounded,
                              size: 18, color: Colors.white),
                          label: const Text("فتح المعاينة",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // زر الحذف
                      IconButton(
                        onPressed: () => _confirmDelete(context, index),
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= المكونات الصغيرة المساعدة ================= */

  Widget _gridIconDetail(IconData icon, String txt) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(txt,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold)),
        ],
      );

  Widget _infoBadge(String txt, Color col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: col.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Text(txt,
            style: TextStyle(
                color: col, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_motion_rounded,
                size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 15),
            const Text("المكتبة فارغة حالياً",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          ],
        ),
      );

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("حذف القالب",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "هل أنت متأكد من حذف هذا التصميم؟ لا يمكن التراجع عن هذه العملية."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, elevation: 0),
            onPressed: () {
              c.deleteTemplate(index);
              Navigator.pop(ctx);
            },
            child:
                const Text("حذف الآن", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
