import 'package:flutter/material.dart';
import '../../Controllers/single_card_controller.dart';


import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/modern_input.dart';

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
            // 1. استخدام الهيدر الموحد مع أيقونة إضافة
            const PremiumHeader(
              title: "إضافة كرت جديد",
              subtitle: "إنشاء حساب مستخدم جديد في الشبكة",
              icon: Icons.add_card_rounded,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                      
                      // 2. استخدام الحقول الموحدة (ModernInput)
                      ModernInput(
                        label: "اسم المستخدم",
                        icon: Icons.person_outline_rounded,
                        controller: controller.usernameCtrl,
                      ),
                      ModernInput(
                        label: "كلمة المرور",
                        icon: Icons.lock_outline_rounded,
                        controller: controller.passwordCtrl,
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      
                      _buildFieldLabel("التفاصيل المالية والربط"),
                      const SizedBox(height: 10),
                      
                      // دروب داون الباقات (بقيت ميثود داخلية لأنها خاصة)
                      _buildPackageDropdown(),
                      
                      const SizedBox(height: 35),
                      
                      // 3. زر الحفظ
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
            
            // 4. الفوتر البسيط
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= أدوات الإدخال الخاصة ================= */

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
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E3A8A)),
          hint: const Text("اختر الباقة"),
          items: controller.packages
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text("باقة $p",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ))
              .toList(),
          onChanged: (v) => setState(() => controller.selectedPackage = v!),
        ),
      ),
    );
  }

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
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: const Center(
        child: Text(
          "نظام إدارة الكروت الفردية v1.0",
          style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
