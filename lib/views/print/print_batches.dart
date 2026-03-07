import 'package:flutter/material.dart';
import '../../Controllers/batches_controller.dart';
import 'add_batch.dart';
import 'page_preview.dart'; // استيراد صفحة المعاينة

class BatchesView extends StatefulWidget {
  const BatchesView({super.key});

  @override
  State<BatchesView> createState() => _BatchesViewState();
}

class _BatchesViewState extends State<BatchesView> {
  // تعريف الكنترولر
  final controller = BatchesController();
  final searchCtrl = TextEditingController();
  String filter = "ALL";

  @override
  Widget build(BuildContext context) {
    // جلب البيانات من الكنترولر
    var batches = controller.batches; 

    // منطق البحث
    if (searchCtrl.text.isNotEmpty) {
      batches = batches.where((b) => b['name'].toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
    }

    // منطق الفلترة (تم تعديل الوصول للبيانات لتناسب Map)
    batches = batches.where((b) {
      final sold = b['sold'] ?? 0;
      final remaining = b['remaining'] ?? (b['total'] ?? 0);
      
      if (filter == "FULL") return sold == 0;
      if (filter == "USING") return remaining > 0 && sold > 0;
      if (filter == "ENDED") return remaining == 0;
      return true;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildBalancedHeader(context),
            _buildSmallStats(batches.length),
            _buildSearchRow(),
            _buildFilterTabs(),
            Expanded(child: _buildBatchesList(batches)),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= الهيدر ================= */
  Widget _buildBalancedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 35),
            const SizedBox(height: 8),
            const Text(
              "دفعات الكروت والاستهلاك",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= العداد العلوي ================= */
  Widget _buildSmallStats(int count) {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Text(
          "إجمالي الدفعات: $count",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A)),
        ),
      ),
    );
  }

  /* ================= البحث والإضافة ================= */
  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "بحث عن دفعة...",
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF1E3A8A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AddBatchView(controller: controller))
              ).then((_) => setState(() {}));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= الفلاتر ================= */
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          _filterItem("ALL", "الكل"),
          _filterItem("FULL", "ممتلئة"),
          _filterItem("USING", "قيد الاستهلاك"),
          _filterItem("ENDED", "منتهية"),
        ],
      ),
    );
  }

  Widget _filterItem(String key, String title) {
    final active = filter == key;
    return GestureDetector(
      onTap: () => setState(() => filter = key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /* ================= قائمة الدفعات ================= */
  Widget _buildBatchesList(List batches) {
    if (batches.isEmpty) return const Center(child: Text("لا توجد دفعات حالياً"));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
      itemCount: batches.length,
      itemBuilder: (_, i) {
        final b = batches[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(b['name'] ?? "", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                subtitle: Text("اللاحقة: ${b['suffix']?.isEmpty ?? true ? '-' : b['suffix']} | البادئة: ${b['prefix']?.isEmpty ?? true ? '-' : b['prefix']}", style: const TextStyle(fontSize: 11)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blue), onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddBatchView(controller: controller, editIndex: i, batch: b)))
                          .then((_) => setState(() {}));
                    }),
                    IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), onPressed: () {
                      controller.batches.removeAt(i);
                      setState(() {});
                    }),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _buildStatMini(Icons.confirmation_number_outlined, "الإجمالي", b['total'] ?? 0),
                    _buildStatMini(Icons.sell_outlined, "المباعة", b['sold'] ?? 0),
                    _buildStatMini(Icons.task_alt_rounded, "المستخدمة", b['used'] ?? 0),
                    _buildStatMini(Icons.hourglass_empty_rounded, "المتبقية", b['remaining'] ?? (b['total'] ?? 0)),
                  ],
                ),
              ),
              _buildPrintAction(b),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatMini(IconData icon, String label, dynamic val) {
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text("$val", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrintAction(Map<String, dynamic> b) {
    return InkWell(
      onTap: () {
        // الانتقال لصفحة المعاينة مع تمرير بيانات الدفعة المختارة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TemplatePreviewPage(
              controller: controller.printTemplatesController,
              templateIndex: 0, // يمكن تغييره ليسمح باختيار القالب قبل الطباعة
              batchData: {
                'total': b['total'],
                'prefix': b['prefix'],
                'suffix': b['suffix'],
                'name': b['name'],
              },
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.print_rounded, size: 18, color: Colors.green),
            SizedBox(width: 10),
            Text("معاينة وطباعة الدفعة", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text("نظام إدارة الشبكة v2.8", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
