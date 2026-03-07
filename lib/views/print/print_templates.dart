import 'package:flutter/material.dart';
import '../../Controllers/print_controller.dart';
import 'saved_templates_view.dart';

class PrintTemplatesView extends StatefulWidget {
  const PrintTemplatesView({super.key});

  @override
  State<PrintTemplatesView> createState() => _PrintTemplatesViewState();
}

class _PrintTemplatesViewState extends State<PrintTemplatesView> {
  final c = PrintTemplatesController();
  final TextEditingController _newTextCtrl = TextEditingController(); 
  final TextEditingController _templateNameCtrl = TextEditingController(); // كنترولر اسم القالب
  
  String selectedId = "USER"; 

  final List<Color> _availableColors = [
    Colors.black, Colors.white, Colors.red, Colors.blue, Colors.green,
    Colors.orange, Colors.purple, Colors.yellow, Colors.brown, Colors.grey,
  ];

  @override
  void dispose() {
    _newTextCtrl.dispose();
    _templateNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Column(
          children: [
            _circleAvatarHeader(context), 
            Expanded(
              child: AnimatedBuilder(
                animation: c,
                builder: (_, __) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    children: [
                      _sectionLabel("إعدادات القالب الأساسية"),
                      _templateNameInput(), // حقل اسم القالب الجديد
                      const SizedBox(height: 15),
                      _sectionLabel("لوحة التصميم (اسحب للتحريك)"),
                      _designerCanvas(),
                      const SizedBox(height: 15),
                      _smartToolbar(), 
                      const SizedBox(height: 15),
                      _addTextSection(),
                      const SizedBox(height: 20),
                      _sectionLabel("توزيع الشبكة والطباعة"),
                      _fullSettingsGrid(),
                      const SizedBox(height: 20),
                      _sectionLabel("المعاينة الحية للمنشور"),
                      _pagePreview(),
                      const SizedBox(height: 25),
                      _saveActions(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  /* ================= 1. حقل اسم القالب بتصميم أنيق ================= */
  Widget _templateNameInput() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      border: Border.all(color: Colors.blue.shade50),
    ),
    child: TextField(
      controller: _templateNameCtrl,
      onChanged: (v) => c.setTemplateName(v), // تأكد من وجود هذه الدالة في الكنترولر
      decoration: const InputDecoration(
        icon: Icon(Icons.edit_note, color: Color(0xff1E3C72)),
        hintText: "أدخل اسماً مميزاً للقالب (مثال: كروت فئة 500)",
        border: InputBorder.none,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    ),
  );

  /* ================= 2. الهيدر المطور ================= */
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
                      child: Icon(Icons.auto_awesome_motion_rounded, color: Color(0xff1E3C72), size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("ستوديو تصميم القوالب", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ),
            Positioned(top: 45, right: 20, child: _glassBackButton(context)),
          ],
        ),
      );

  Widget _glassBackButton(BuildContext context) => InkWell(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
    ),
  );

  /* ================= 3. لوحة التصميم ================= */
  Widget _designerCanvas() {
    return LayoutBuilder(builder: (context, constraints) {
      final double canvasWidth = constraints.maxWidth;
      const double canvasHeight = 220;

      return Container(
        height: canvasHeight,
        width: canvasWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          image: c.background != null ? DecorationImage(image: c.background!, fit: BoxFit.cover) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              _buildDraggableItem("USER", "USERNAME", c.userPos, c.userFont, c.userColor, (d) => c.dragUser(d), canvasWidth, canvasHeight),
              if (c.showPassword) ...[
                _buildDraggableItem("PASS", "PASSWORD", c.passPos, c.passFont, c.passColor, (d) => c.dragPass(d), canvasWidth, canvasHeight),
              ],
              ...c.customTexts.map((txt) => _buildDraggableItem(
                    txt.id, txt.content, txt.position, txt.fontSize, txt.color,
                    (d) => c.dragCustomText(txt.id, d), canvasWidth, canvasHeight,
                  )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDraggableItem(String id, String text, Offset pos, double size, Color color, Function(Offset) onDrag, double maxWidth, double maxHeight) {
    bool isSelected = selectedId == id;
    return Positioned(
      left: pos.dx.clamp(0, maxWidth - 60), 
      top: pos.dy.clamp(0, maxHeight - 30), 
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        onTap: () => setState(() => selectedId = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.black12,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2),
          ),
          child: Text(text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 3, color: Colors.black38)])),
        ),
      ),
    );
  }

  /* ================= 4. شريط التحكم الذكي ================= */
  Widget _smartToolbar() {
    int customIndex = c.customTexts.indexWhere((e) => e.id == selectedId);
    bool isCustom = customIndex != -1;
    double currentFontSize = selectedId == "USER" ? c.userFont : (selectedId == "PASS" ? c.passFont : (isCustom ? c.customTexts[customIndex].fontSize : 14));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.04), blurRadius: 10)]
      ),
      child: Row(
        children: [
          _toolbarInfoBadge(isCustom),
          const Spacer(),
          _actionBtn(Icons.remove, Colors.red, () {
             if (selectedId == "USER") c.setUserFont(c.userFont - 1);
             else if (selectedId == "PASS") c.setPassFont(c.passFont - 1);
             else if (isCustom) c.setCustomTextFont(selectedId, currentFontSize - 1);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("${currentFontSize.toInt()}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xff1E3C72))),
          ),
          _actionBtn(Icons.add, Colors.green, () {
             if (selectedId == "USER") c.setUserFont(c.userFont + 1);
             else if (selectedId == "PASS") c.setPassFont(c.passFont + 1);
             else if (isCustom) c.setCustomTextFont(selectedId, currentFontSize + 1);
          }),
          const SizedBox(width: 12),
          _actionBtn(Icons.color_lens_rounded, Colors.indigo, _pickColor),
          if (isCustom) ...[
            const SizedBox(width: 8),
            _actionBtn(Icons.delete_forever_rounded, Colors.redAccent, () {
               c.removeCustomText(selectedId);
               setState(() => selectedId = "USER");
            }),
          ]
        ],
      ),
    );
  }

  Widget _toolbarInfoBadge(bool isCustom) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("العنصر النشط", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      Text(isCustom ? "نص إضافي" : (selectedId == "USER" ? "اسم المستخدم" : "كلمة المرور"), 
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff2563EB))),
    ],
  );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) => Material(
    color: color.withOpacity(0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 22, color: color)),
    ),
  );

  /* ================= 5. إعدادات الشبكة ================= */
  Widget _fullSettingsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade50)),
      child: Column(
        children: [
          Row(children: [
  _gridControl("عدد الصفوف", c.rows, c.setRows, Icons.table_rows_rounded), // تم تصحيح الاسم هنا
  _gridControl("عدد الأعمدة", c.cols, c.setCols, Icons.view_column_rounded) // أيقونة أنسب للأعمدة
]),

          const Divider(height: 25, thickness: 0.5),
          Row(children: [_gridControl("طول المستخدم", c.userLength, c.setUserLen, Icons.person_outline), _gridControl("طول الرمز", c.passLength, c.setPassLen, Icons.password)]),
          const SizedBox(height: 10),
          _modernSwitch(),
          const SizedBox(height: 15),
          _gradientButton(
            onPressed: () => c.pickBackground(),
            icon: Icons.image_outlined,
            label: "تغيير خلفية البطاقة",
            colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900],
          )
        ],
      ),
    );
  }

  Widget _gridControl(String title, int val, Function(int) func, IconData icon) => Expanded(
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(color: const Color(0xffF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () => func(val + 1), icon: const Icon(Icons.add_circle, color: Colors.blue, size: 20)),
              Text("$val", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              IconButton(onPressed: () { if (val > 1) func(val - 1); }, icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20)),
            ],
          ),
        )
      ],
    ),
  );

  Widget _modernSwitch() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xffF1F5F9), borderRadius: BorderRadius.circular(12)),
    child: SwitchListTile(
      title: const Text("عرض كلمة السر في المعاينة", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      value: c.showPassword,
      onChanged: (v) => c.togglePass(v),
      activeColor: const Color(0xff2563EB),
      dense: true,
    ),
  );

  /* ================= 6. المعاينة الحية الملتزمة بالشبكة ================= */
  Widget _pagePreview() {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)]
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: c.cols, // التزام بعدد الأعمدة
            crossAxisSpacing: 5, 
            mainAxisSpacing: 5, 
            childAspectRatio: 380 / 220,
          ),
          itemCount: c.rows * c.cols, // التزام بعدد الصفوف
          itemBuilder: (context, index) => _miniCard(),
        ),
      ),
    );
  }

  Widget _miniCard() {
    return LayoutBuilder(builder: (context, constraints) {
      final double scale = constraints.maxWidth / 380.0;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          image: c.background != null ? DecorationImage(image: c.background!, fit: BoxFit.cover) : null,
        ),
        child: Stack(
          children: [
            _buildMiniElement(c.userPos, "USER", c.userFont, c.userColor, scale),
            if (c.showPassword) _buildMiniElement(c.passPos, "PASS", c.passFont, c.passColor, scale),
            ...c.customTexts.map((txt) => _buildMiniElement(txt.position, txt.content, txt.fontSize, txt.color, scale)),
          ],
        ),
      );
    });
  }

  Widget _buildMiniElement(Offset pos, String text, double size, Color color, double scale) => Positioned(
    left: pos.dx * scale, top: pos.dy * scale,
    child: Text(text, style: TextStyle(color: color, fontSize: (size * scale).clamp(1, 100), fontWeight: FontWeight.bold, height: 1.0)),
  );

  /* ================= 7. إضافة نص والأزرار النهائية ================= */
  Widget _addTextSection() => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade50)),
    child: Row(children: [
      const SizedBox(width: 10),
      const Icon(Icons.text_fields_rounded, color: Colors.grey, size: 20),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: _newTextCtrl, decoration: const InputDecoration(hintText: "أضف نصاً ثابتاً (مثال: السعر، تواصل معنا)", border: InputBorder.none, hintStyle: TextStyle(fontSize: 12)))),
      _gradientButton(
        onPressed: () { if (_newTextCtrl.text.isNotEmpty) { c.addCustomText(_newTextCtrl.text); _newTextCtrl.clear(); } },
        icon: Icons.add, label: "إضافة", colors: [const Color(0xff1E3C72), const Color(0xff2563EB)], width: 100, height: 40,
      ),
    ]),
  );

  Widget _saveActions() => Column(children: [
    _gradientButton(
      onPressed: () {
        if (_templateNameCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ برجاء إدخال اسم للقالب أولاً"), backgroundColor: Colors.orange)
          );
          return;
        }
        c.saveTemplate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم حفظ القالب بنجاح"), backgroundColor: Colors.green)
        );
      },
      icon: Icons.save_rounded, label: "حفظ التصميم الآن", colors: [const Color(0xff059669), const Color(0xff10B981)], height: 55,
    ),
    const SizedBox(height: 12),
    OutlinedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedTemplatesView(c: c))),
      icon: const Icon(Icons.folder_special_outlined),
      label: const Text("استعراض القوالب المحفوظة"),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), 
        side: const BorderSide(color: Color(0xff1E3C72), width: 1.5)
      ),
    ),
  ]);

  /* ويدجت الزر المتدرج الموحد */
  Widget _gradientButton({required VoidCallback onPressed, required IconData icon, required String label, required List<Color> colors, double? width, double height = 45}) => Container(
    width: width ?? double.infinity,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors), 
      borderRadius: BorderRadius.circular(15), 
      boxShadow: [BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed, icon: Icon(icon, size: 18), label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    ),
  );

  Widget _footer() => Container(height: 30, width: double.infinity, color: const Color(0xff0F172A), child: const Center(child: Text("Micronet Professional Edition v4.5", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))));

  Widget _sectionLabel(String t) => Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(bottom: 10, top: 5), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xff0F172A)))));

  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("اختر لون العنصر", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: _availableColors.map((color) => InkWell(
            onTap: () { c.setElementColor(selectedId, color); Navigator.pop(context); },
            child: Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)), child: CircleAvatar(backgroundColor: color, radius: 22)),
          )).toList(),
        ),
      ),
    );
  }
}
