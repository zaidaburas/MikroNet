import 'package:flutter/material.dart';
import '../../Controllers/cards_controller.dart';

// استيراد الويدجت الجاهزة
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/modern_input.dart';
import '../widgets/widgetsCard/status_badge.dart';

class CardDetailsView extends StatefulWidget {
  final CardItem card;
  const CardDetailsView({super.key, required this.card});

  @override
  State<CardDetailsView> createState() => _CardDetailsViewState();
}

class _CardDetailsViewState extends State<CardDetailsView> {
  final controller = CardsController();
  late TextEditingController userCtrl;
  late TextEditingController passCtrl;
  late TextEditingController packageCtrl;
  late String status;

  @override
  void initState() {
    super.initState();
    userCtrl = TextEditingController(text: widget.card.username);
    passCtrl = TextEditingController(text: widget.card.password);
    packageCtrl = TextEditingController(text: widget.card.package);
    status = widget.card.status;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            // استخدام الهيدر الموحد
            const PremiumHeader(
              title: "لوحة إدارة الكرت",
              subtitle: "تعديل البيانات وتغيير حالة الاتصال",
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("بيانات الاشتراك"),
                    
                    // استخدام حقول الإدخال الموحدة
                    ModernInput(label: "اسم المستخدم", icon: Icons.person_outline, controller: userCtrl),
                    ModernInput(label: "كلمة المرور", icon: Icons.lock_outline, controller: passCtrl),
                    ModernInput(label: "الباقة الحالية", icon: Icons.inventory_2_outlined, controller: packageCtrl, isReadOnly: true),
                    
                    const SizedBox(height: 10),
                    _buildStatusSection(),
                    
                    const SizedBox(height: 30),
                    _buildSaveButton(),
                    
                    const SizedBox(height: 15),
                    _buildDeleteButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= STATUS SECTION ================= */
  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("حالة الاتصال", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              StatusBadge(status: status), // استخدام ويدجت الحالة الموحد
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statusBtn("تجديد الكرت", Colors.green, () => _changeStatus("نشطة"))),
              const SizedBox(width: 12),
              Expanded(child: _statusBtn("تعطيل مؤقت", Colors.redAccent, () => _changeStatus("منتهية"))),
            ],
          ),
        ],
      ),
    );
  }

  /* ================= HELPERS & LOGIC ================= */
  Widget _buildSectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12, right: 5),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 15)),
  );

  Widget _statusBtn(String t, Color c, VoidCallback o) => OutlinedButton(
    onPressed: o,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: c.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _buildSaveButton() => InkWell(
    onTap: _saveChanges,
    child: Container(
      height: 58, width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: const Center(child: Text("حفظ كافة التعديلات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
    ),
  );

  Widget _buildDeleteButton() => SizedBox(
    width: double.infinity,
    child: TextButton.icon(
      onPressed: _showDeleteConfirm,
      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 20),
      label: const Text("حذف هذا الكرت نهائياً", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      style: TextButton.styleFrom(padding: const EdgeInsets.all(15)),
    ),
  );

  void _saveChanges() async {
    await controller.updateCard(CardItem(username: userCtrl.text, password: passCtrl.text, package: packageCtrl.text, status: status));
    Navigator.pop(context);
  }

  void _changeStatus(String ns) async {
    setState(() => status = ns);
    await controller.updateCardStatus(widget.card.username, ns);
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد الحذف"),
        content: const Text("هذا الإجراء سيقوم بإزالة الكرت من السيرفر بشكل دائم. هل أنت متأكد؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("تراجع")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              await controller.deleteCard(widget.card.username);
              Navigator.pop(context); Navigator.pop(context);
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }
}
