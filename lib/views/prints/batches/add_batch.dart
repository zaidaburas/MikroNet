import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/controllers/helpers/widgets.dart';
import 'package:mikronet/controllers/print/batches_controller.dart';
import 'package:mikronet/views/helpers/dialogs.dart';
// import '../../print/page_preview.dart';

// استيراد الويجيت الموحدة
import '../../widgets/shared/layouts/sub_page_header.dart';
import '../../widgets/shared/layouts/app_mini_footer.dart';
import '../../widgets/shared/typography/section_title.dart';

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
  // final nameCtrl = TextEditingController();
  // final totalCtrl = TextEditingController();
  // final prefixCtrl = TextEditingController();
  // final suffixCtrl = TextEditingController();

  // String selectedProfile = "100";

  // final List<String> profiles = ["100", "200", "250", "500", "1500", "3000"];

  // String selectedTemplate = "القالب 1";

  // final List<String> templates = ["القالب 1", "القالب 2", "القالب 3"];

  

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      // nameCtrl.text = widget.batch['name'] ?? "";
      // totalCtrl.text = widget.batch['total']?.toString() ?? "";
      // selectedProfile = widget.batch['profile'] ?? "100";
      // prefixCtrl.text = widget.batch['prefix'] ?? "";
      // suffixCtrl.text = widget.batch['suffix'] ?? "";
      // selectedGenType = widget.batch['charType'] ?? "mixed";
    }
  }

  /* ================= الدوال الوظيفية (محفوظة بالكامل) ================= */

  void _handleCreate() async {
    // if (nameCtrl.text.isEmpty || totalCtrl.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("يرجى ملء البيانات الأساسية")));
    //   return;
    // }
    // final total = int.tryParse(totalCtrl.text) ?? 0;
    // if (total <= 0) return;

    // if (widget.editIndex == null) {
    //   // widget.controller.addBatch(nameCtrl.text, total, selectedProfile,
    //   //     prefixCtrl.text, suffixCtrl.text,
    //   //     charType: selectedGenType);
    // } else {
    //   // widget.controller.updateBatch(widget.editIndex!, nameCtrl.text, total,
    //   //     selectedProfile, prefixCtrl.text, suffixCtrl.text,
    //   //     charType: selectedGenType);
    // }
    // // widget.controller.generateBatchByTemplate(nameCtrl.text, selectedTemplate,
    // //     type: selectedGenType);
    // if (mounted) _showSuccessDialog();
  }

  void _handlePreview() {
    // final total = int.tryParse(totalCtrl.text) ?? 12;
    // int templateIndex = templates.indexOf(selectedTemplate);
    // if (templateIndex == -1) templateIndex = 0;

    // final batchData = {
    //   'total': total,
    //   'prefix': prefixCtrl.text,
    //   'suffix': suffixCtrl.text,
    //   'name': nameCtrl.text,
    //   // 'charType': selectedGenType,
    // };

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => TemplatePreviewPage(
    //       controller: widget.controller.printTemplatesController,
    //       templateIndex: templateIndex,
    //       batchData: batchData,
    //     ),
    //   ),
    // );
  }

  /* ================= واجهة العرض (UI) ================= */

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: GetBuilder<BatchesController>(
          init: widget.controller,
          builder: (controller) {
            return Column(
              children: [
                // 1. استخدام الهيدر الموحد (توريث التصميم)
                PremiumHeader(
                  title:
                      widget.editIndex == null ? "إنشاء دفعة كروت" : "تعديل الدفعة",
                  subtitle: "توليد وإدارة رموز الشبكة",
                  icon: Icons.layers_rounded,
                ),
            
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        const SectionTitle(title: "إعدادات الدفعة الجديدة"),
                        _buildFormCard(),
                      ],
                    ),
                  ),
                ),
            
                // 2. استخدام الفوتر الموحد (توريث التصميم)
                const AppMiniFooter(sectionName: "Micronet Card Engine"),
              ],
            );
          }
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
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("المعلومات الأساسية"),
          const SizedBox(height: 15),
          _buildModernInput(
              widget.controller.batchName, "اسم الدفعة (مثال: دفعة الشتاء)", Icons.badge_outlined),
          _buildModernInput(
              widget.controller.numOfCards, "عدد الكروت المطلوب توليدها", Icons.pin_outlined,
              isNumber: true),
          const Divider(height: 40),
          _buildFieldLabel("إعدادات الربط والتصميم"),
          const SizedBox(height: 15),
          _buildProfileDropdown(),
          const SizedBox(height: 12),
          _buildTemplateDropdown(),
          const Divider(height: 40),
          _buildFieldLabel("نمط كلمة المرور"),
          const SizedBox(height: 12),
          _buildGenerationTypeSelector(),
          const Divider(height: 40),
          // 
          _buildFieldLabel("طول الرموز"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _buildModernInput(
                      widget.controller.usernameLength, "طول اسم المستخدم", Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildModernInput(
                      widget.controller.passwordLength, "طول كلمة المرور", Icons.password)),
            ],
          ),
          const Divider(height: 40),
          // 
          Text(widget.controller.dataInsert.toString()),
          const Divider(height: 40),
          // 
          _buildFieldLabel("تخصيص الرموز (اختياري)"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _buildModernInput(
                      widget.controller.prefix, "بادئة (Prefix)", Icons.login_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildModernInput(
                      widget.controller.suffix, "لاحقة (Suffix)", Icons.logout_rounded)),
            ],
          ),
          const SizedBox(height: 35),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /* ميثودات مساعدة تم تعديلها لتتناسب مع الـ UI الموحد */

  Widget _buildFieldLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E3A8A)));
  }

  Widget _buildModernInput(
      TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          widget.controller.update();
        } ,
      ),
    );
  }

  Widget _buildDropdownRow({
    required double screenWidth,
    double padding=10,
    required Widget child,
    required String label
  }){
    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: (screenWidth / 3) - padding,
            child: Text(label),
          ),
          SizedBox(
            width: (screenWidth / 3 * 2) - padding,
            child: child
          )
        ],
      );
  }

  Widget _buildProfileDropdown() => 
  _buildDropdownRow(
    screenWidth: Navigator.of(context).context.width , 
    padding: 45,
    label: "اختر باقة",
    child: MySelectedMenu(
      items: widget.controller.allProfiles.map((p)=>{"id":p.id ,"name":p.name}).toList(),
      onSave: (val) {
        // showErrorDialog(content: val.toString());
        widget.controller.selectedProfile.value=val.toString();
        widget.controller.update();
      },
      hintText: "اختر باقة",
      selectedKeyName: "id",
      bgColor: const Color(0xFFF1F5F9),
      border: Border.all(color: Colors.grey.shade300),
      // color: Colors.grey.shade300,
    ),

  );

  Widget _buildTemplateDropdown() => 
  _buildDropdownRow(
    screenWidth: Navigator.of(context).context.width , 
    padding: 45,
    label: "اختر قالب",
    child: MySelectedMenu(
      items: widget.controller.allTemplates.map((t)=>{"id":t.id ,"name":t.name}).toList(),
      onSave: (val) {
        widget.controller.selectedTemplate.value=int.parse(val);
        widget.controller.update();
      },
      hintText: "اختر قالب" ,
      selectedKeyName: "id",
      bgColor: const Color(0xFFF1F5F9),
      border: Border.all(color: Colors.grey.shade300),
      // color: Colors.grey.shade300,
    ),

  );
  
    Widget _buildBaseDropdown({
    required int? value, // تم التغيير إلى int? ليتعامل مع label_id
    required List<Map<String, dynamic>> items, // تم التغيير لتستقبل قائمة من الـ Maps
    required String label,
    required void Function(int?) onChanged, // الدالة الآن ترجع int?
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>( // تم التغيير إلى int
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem<int>( // تحديد نوع العنصر كـ int
                  value: e['index'] as int, // القيمة الفعلية التي سيتم التعامل معها
                  child: Text("$label: ${e['name']}", // النص الذي سيظهر للمستخدم
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  
  
  // Widget _buildBaseDropdown(
  //     {required String value,
  //     required List<String> items,
  //     required String label,
  //     required Function(String?) onChanged}) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 15),
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     decoration: BoxDecoration(
  //         color: const Color(0xFFF1F5F9),
  //         borderRadius: BorderRadius.circular(15)),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: value,
  //         isExpanded: true,
  //         items: items
  //             .map((e) => DropdownMenuItem(
  //                 value: e,
  //                 child: Text("$label: $e",
  //                     style: const TextStyle(
  //                         fontSize: 14, fontWeight: FontWeight.bold))))
  //             .toList(),
  //         onChanged: onChanged,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildGenerationTypeSelector() {
    return Row(
      children: widget.controller.passwordTypes.map((opt) {
        bool isSelected = widget.controller.selectedPasswordType == opt['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              widget.controller.selectedPasswordType=opt['id'];
              widget.controller.update();
            },
            // => setState(() => selectedGenType = opt['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(opt['icon'],
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 20),
                  const SizedBox(height: 4),
                  Text(opt['label'],
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: _customButton(
                "إنشاء وتوليد",
                const [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                Icons.bolt_rounded,
                _handleCreate)),
        const SizedBox(width: 12),
        Expanded(
            child: _customButton(
                "معاينة",
                const [Color(0xFF10B981), Color(0xFF059669)],
                Icons.visibility_rounded,
                widget.controller.preview
              )),
      ],
    );
  }

  Widget _customButton(
      String text, List<Color> colors, IconData icon, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: colors.last.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13))
        ]),
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
            const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 70),
            const SizedBox(height: 15),
            const Text("عملية ناجحة",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const Text("تم إنشاء الدفعة. هل تطبعها الآن؟",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 25),
            Row(children: [
              Expanded(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text("لاحقاً"))),
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        // Navigator.pop(ctx);
                        // widget.controller
                        //     .printBatchToPdf(nameCtrl.text, selectedTemplate);
                        // Navigator.pop(context);
                      },
                      child: const Text("طباعة PDF"))),
            ])
          ],
        ),
      ),
    );
  }
}
