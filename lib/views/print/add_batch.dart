import 'package:flutter/material.dart';
import '../../Controllers/batches_controller.dart';
import 'page_preview.dart';

class AddBatchView extends StatefulWidget {
  final BatchesController controller;
  final int? editIndex;
  final dynamic batch;

  const AddBatchView({
    super.key,
    required this.controller,
    this.editIndex,
    this.batch,
  });

  @override
  State<AddBatchView> createState() => _AddBatchViewState();
}

class _AddBatchViewState extends State<AddBatchView> {
  final nameCtrl = TextEditingController();
  final totalCtrl = TextEditingController();
  final prefixCtrl = TextEditingController();
  final suffixCtrl = TextEditingController();

  String selectedPackage = "100";
  final List<String> packages = ["100", "200", "250", "500", "1500", "3000"];

  String selectedTemplate = "القالب 1";
  final List<String> templates = ["القالب 1", "القالب 2", "القالب 3"];

  // خيارات نوع توليد الرموز
  String selectedGenType = "mixed"; 
  final List<Map<String, dynamic>> genOptions = [
    {"id": "numeric", "label": "أرقام فقط", "icon": Icons.pin_outlined},
    {"id": "alphabetic", "label": "حروف فقط", "icon": Icons.abc_rounded},
    {"id": "mixed", "label": "أرقام وحروف", "icon": Icons.password_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      nameCtrl.text = widget.batch['name'] ?? "";
      totalCtrl.text = widget.batch['total']?.toString() ?? "";
      selectedPackage = widget.batch['package'] ?? "100";
      prefixCtrl.text = widget.batch['prefix'] ?? "";
      suffixCtrl.text = widget.batch['suffix'] ?? "";
      selectedGenType = widget.batch['charType'] ?? "mixed";
    }
  }

  /* ================= الدوال الوظيفية ================= */

  void _handleCreate() async {
    if (nameCtrl.text.isEmpty || totalCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("يرجى ملء البيانات الأساسية")));
      return;
    }
    
    final total = int.tryParse(totalCtrl.text) ?? 0;
    if (total <= 0) return;

    if (widget.editIndex == null) {
      widget.controller.addBatch(nameCtrl.text, total, selectedPackage, prefixCtrl.text, suffixCtrl.text, charType: selectedGenType);
    } else {
      widget.controller.updateBatch(widget.editIndex!, nameCtrl.text, total, selectedPackage, prefixCtrl.text, suffixCtrl.text, charType: selectedGenType);
    }
    
    widget.controller.generateBatchByTemplate(nameCtrl.text, selectedTemplate, type: selectedGenType);

    if (mounted) _showSuccessDialog();
  }

  void _handlePreview() {
    final total = int.tryParse(totalCtrl.text) ?? 12;
    int templateIndex = templates.indexOf(selectedTemplate);
    if (templateIndex == -1) templateIndex = 0;

    final batchData = {
      'total': total,
      'prefix': prefixCtrl.text,
      'suffix': suffixCtrl.text,
      'name': nameCtrl.text,
      'charType': selectedGenType,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplatePreviewPage(
          controller: widget.controller.printTemplatesController,
          templateIndex: templateIndex,
          batchData: batchData,
        ),
      ),
    );
  }

  /* ================= واجهة العرض (UI) ================= */

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            _buildBalancedHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: _buildFormCard(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
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
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Icon(Icons.layers_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              widget.editIndex == null ? "إنشاء دفعة كروت جديدة" : "تعديل بيانات الدفعة",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("المعلومات الأساسية"),
          const SizedBox(height: 15),
          _buildModernInput(nameCtrl, "اسم الدفعة (مثال: دفعة الصيف)", Icons.badge_outlined),
          _buildModernInput(totalCtrl, "عدد الكروت المطلوب توليدها", Icons.pin_outlined, isNumber: true),
          
          const Divider(height: 40),
          _buildFieldLabel("إعدادات الربط والتصميم"),
          const SizedBox(height: 15),
          _buildPackageDropdown(),
          _buildTemplateDropdown(),
          
          const Divider(height: 40),
          _buildFieldLabel("طريقة توليد الرموز"),
          const SizedBox(height: 12),
          _buildGenerationTypeSelector(),
          
          const Divider(height: 40),
          _buildFieldLabel("تخصيص الرموز (اختياري)"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildModernInput(prefixCtrl, "بادئة (Prefix)", Icons.login_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildModernInput(suffixCtrl, "لاحقة (Suffix)", Icons.logout_rounded)),
            ],
          ),
          const SizedBox(height: 35),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildGenerationTypeSelector() {
    return Row(
      children: genOptions.map((opt) {
        bool isSelected = selectedGenType == opt['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedGenType = opt['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(opt['icon'], color: isSelected ? Colors.white : const Color(0xFF64748B), size: 20),
                  const SizedBox(height: 4),
                  Text(opt['label'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)));
  }

  Widget _buildModernInput(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPackageDropdown() => _buildBaseDropdown(value: selectedPackage, items: packages, icon: Icons.inventory_2_outlined, labelBuilder: (p) => "باقة اشتراك $p", onChanged: (v) => setState(() => selectedPackage = v!));

  Widget _buildTemplateDropdown() => _buildBaseDropdown(value: selectedTemplate, items: templates, icon: Icons.palette_outlined, labelBuilder: (t) => "قالب التصميم: $t", onChanged: (v) => setState(() => selectedTemplate = v!));

  Widget _buildBaseDropdown({required String value, required List<String> items, required IconData icon, required String Function(String) labelBuilder, required Function(String?) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF1E3A8A)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(flex: 2, child: _customButton("إنشاء وتوليد", const [Color(0xFF0F172A), Color(0xFF1E3A8A)], Icons.bolt_rounded, _handleCreate)),
        const SizedBox(width: 12),
        Expanded(child: _customButton("معاينة", const [Color(0xFF10B981), Color(0xFF059669)], Icons.visibility_rounded, _handlePreview)),
      ],
    );
  }

  Widget _customButton(String text, List<Color> colors, IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("تمت العملية بنجاح!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            const Text("تم إنشاء الدفعة وتوليد الرموز. هل تود طباعتها الآن؟", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 25),
            Row(children: [
              Expanded(child: TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("لاحقاً", style: TextStyle(color: Colors.grey)))),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { Navigator.pop(ctx); widget.controller.printBatchToPdf(nameCtrl.text, selectedTemplate); Navigator.pop(context); }, child: const Text("طباعة PDF"))),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() => const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text("Micronet Card Engine v2.0", style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)));
}
