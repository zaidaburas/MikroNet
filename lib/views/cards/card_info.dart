import 'package:flutter/material.dart';
import '../../Controllers/cards_controller.dart';

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
            _buildCustomAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("بيانات الاشتراك"),
                    _modernEditField("اسم المستخدم", Icons.person_outline, userCtrl),
                    _modernEditField("كلمة المرور", Icons.lock_outline, passCtrl),
                    
                    // حقل الباقة: للقراءة فقط (Read Only)
                    _modernEditField(
                      "الباقة الحالية", 
                      Icons.inventory_2_outlined, 
                      packageCtrl, 
                      isReadOnly: true
                    ),
                    
                    const SizedBox(height: 10),
                    _buildStatusCard(),
                    
                    const SizedBox(height: 30),
                    _buildActionButtons(), // الزر الأساسي (حفظ)
                    
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

  /* ================= MODERN APP BAR ================= */

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // السهم يشير لليمين للخروج من الواجهة في وضع RTL
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded, 
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "لوحة إدارة الكرت",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // توازن بصري مقابل زر الرجوع
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900, 
          color: Color(0xFF1E293B), 
          fontSize: 15
        ),
      ),
    );
  }

  /* ================= INPUT FIELD ================= */

  Widget _modernEditField(String label, IconData icon, TextEditingController ctrl, {bool isReadOnly = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isReadOnly ? const Color(0xFFE2E8F0) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isReadOnly ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: TextField(
        controller: ctrl,
        readOnly: isReadOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isReadOnly ? Colors.blueGrey.shade400 : Colors.blueGrey, 
            fontSize: 13
          ),
          prefixIcon: Icon(
            icon, 
            color: isReadOnly ? Colors.blueGrey.shade400 : const Color(0xFF1E3A8A), 
            size: 20
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(
          color: isReadOnly ? Colors.blueGrey.shade600 : Colors.black,
          fontWeight: isReadOnly ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /* ================= STATUS CARD ================= */

  Widget _buildStatusCard() {
    bool isActive = status == "نشطة";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isActive ? Colors.green : Colors.red).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "حالة الاتصال", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 12
                  ),
                ),
              ),
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

  Widget _statusBtn(String text, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text, 
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)
      ),
    );
  }

  /* ================= ACTION BUTTONS ================= */

  Widget _buildActionButtons() {
    return _gradientBtn(
      "حفظ كافة التعديلات", 
      const [Color(0xFF0F172A), Color(0xFF1E3A8A)], 
      _saveChanges
    );
  }

  Widget _gradientBtn(String text, List<Color> colors, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.3), 
              blurRadius: 12, 
              offset: const Offset(0, 6)
            )
          ],
        ),
        child: Center(
          child: Text(
            text, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _showDeleteConfirm,
        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 20),
        label: const Text(
          "حذف هذا الكرت نهائياً", 
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(15)),
      ),
    );
  }

  /* ================= LOGIC ================= */

  void _saveChanges() async {
    await controller.updateCard(CardItem(
      username: userCtrl.text,
      password: passCtrl.text,
      package: packageCtrl.text,
      status: status,
    ));
    Navigator.pop(context);
  }

  void _changeStatus(String newStatus) async {
    setState(() => status = newStatus);
    await controller.updateCardStatus(widget.card.username, newStatus);
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              await controller.deleteCard(widget.card.username);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }
}
