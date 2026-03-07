import 'package:flutter/material.dart';
import '../../Controllers/single_card_controller.dart';

class AddSingleCardView extends StatefulWidget {
  const AddSingleCardView({super.key});

  @override
  State<AddSingleCardView> createState() => _AddSingleCardViewState();
}

class _AddSingleCardViewState extends State<AddSingleCardView> {
  final controller = SingleCardController();

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black.withOpacity(0.03),
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("بيانات الحساب"),
                      const SizedBox(height: 10),
                      _buildModernInput(controller.usernameCtrl, "اسم المستخدم",
                          Icons.person_outline_rounded),
                      _buildModernInput(controller.passwordCtrl, "كلمة المرور",
                          Icons.lock_outline_rounded),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      _buildFieldLabel("التفاصيل المالية والربط"),
                      const SizedBox(height: 10),
                      _buildPackageDropdown(),
                      const SizedBox(height: 35),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= الهيدر: حجم متناسق مع الرئيسية ================= */
  Widget _buildBalancedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
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
            const Icon(Icons.add_card_rounded, color: Colors.white, size: 38),
            const SizedBox(height: 10),
            const Text(
              "إضافة كرت جديد",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= أدوات الإدخال الفخمة ================= */

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildModernInput(
      TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPackageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedPackage,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF1E3A8A)),
          hint: const Text("اختر الباقة"),
          items: controller.packages
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text("باقة $p",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => controller.selectedPackage = v!),
        ),
      ),
    );
  }

  /* ================= أزرار التحكم ================= */

  Widget _buildSaveButton() {
    return InkWell(
      onTap: () {
        if (!controller.validate()) return;
        controller.clear();
        Navigator.pop(context);
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Center(
          child: Text(
            "حفظ الكرت",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  /* ================= الفوتر ================= */

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      color: Colors.transparent,
      child: const Center(
        child: Text(
          "نظام إدارة الكروت الفردية v1.0",
          style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
