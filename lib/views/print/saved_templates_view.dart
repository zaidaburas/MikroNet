import 'package:flutter/material.dart';
import '../../Controllers/print_controller.dart';
import 'page_preview.dart';

class SavedTemplatesView extends StatelessWidget {
  final PrintTemplatesController c;

  const SavedTemplatesView({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Column(
          children: [
            _circleAvatarHeader(context), // نفس الهيدر المعتمد
            Expanded(
              child: AnimatedBuilder(
                animation: c,
                builder: (_, __) {
                  if (c.savedTemplates.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: c.savedTemplates.length,
                    itemBuilder: (_, i) {
                      final t = c.savedTemplates[i];
                      final rows = t['rows'] ?? 0;
                      final cols = t['cols'] ?? 0;
                      final total = rows * cols;
                      final templateName = t['name'] ?? "قالب بدون اسم";

                      return _buildTemplateCard(context, t, i, templateName, total, rows, cols);
                    },
                  );
                },
              ),
            ),
            _footer(), // نفس الفوتر المعتمد
          ],
        ),
      ),
    );
  }

  /* ================= الهيدر الموحد ================= */
  Widget _circleAvatarHeader(BuildContext context) => Container(
        height: 160,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xff0F172A), Color(0xff1E3C72), Color(0xff2563EB)]
          ),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.bookmarks_rounded, color: Color(0xff1E3C72), size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("مكتبة القوالب المحفوظة", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ),
            Positioned(
              top: 45, 
              right: 20, 
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );

  /* ================= كرت القالب ================= */
  Widget _buildTemplateCard(BuildContext context, Map t, int index, String name, int total, int rows, int cols) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.blue.shade50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // خلفية مصغرة للكرت
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue.shade900, Colors.blue.shade600]),
                image: t['background'] != null ? DecorationImage(image: t['background'], fit: BoxFit.cover) : null,
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xff0F172A))),
                      _infoBadge("$total كرت", const Color(0xff2563EB)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _gridDetail(Icons.table_rows_rounded, "صفوف: $rows"),
                      const SizedBox(width: 15),
                      _gridDetail(Icons.view_column_rounded, "أعمدة: $cols"),
                      const Spacer(),
                      Text(t['date'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, thickness: 0.5)),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          label: "فتح المعاينة",
                          icon: Icons.remove_red_eye_rounded,
                          color: const Color(0xff1E3C72),
                          onTap: () {
                            final dummyBatchData = {'total': total, 'prefix': 'USR-', 'suffix': '', 'name': name};
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TemplatePreviewPage(
                              controller: c, templateIndex: index, batchData: dummyBatchData,
                            )));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      _deleteButton(() => _confirmDelete(context, index)),
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

  /* ================= المكونات الصغيرة ================= */
  Widget _gridDetail(IconData icon, String txt) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.blueGrey),
      const SizedBox(width: 4),
      Text(txt, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _infoBadge(String txt, Color col) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
    child: Text(txt, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.bold)),
  );

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    ),
  );

  Widget _deleteButton(VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.folder_open_rounded, size: 70, color: Colors.grey.shade300),
        const SizedBox(height: 15),
        const Text("لا توجد قوالب محفوظة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    ),
  );

  Widget _footer() => Container(height: 30, width: double.infinity, color: const Color(0xff0F172A), child: const Center(child: Text("Micronet Professional Edition v4.5", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))));

  void _confirmDelete(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("حذف القالب؟"),
        content: const Text("سيتم حذف تصميم القالب نهائياً من الذاكرة."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("تراجع")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("حذف", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) c.deleteTemplate(index);
  }
}
