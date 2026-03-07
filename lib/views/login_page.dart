import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/controllers/login_controller.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController controller;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0B), // أسود كربوني
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: GetBuilder<LoginController>(
              init: LoginController(),
              builder: (controller) {
                return Column(
                  children: [
                    // 1. الجزء العلوي: أيقونة وعنوان حاد
                    _buildTechHeader(),
                
                    const Spacer(),
                
                    // 2. الجزء الأوسط: حقول الإدخال بهيكل قوي
                    _buildInputSection(),
                
                    const Spacer(),
                
                    // 3. الجزء السفلي: أزرار "الأكشن" الضخمة
                    _buildEliteActions(),
                    
                    const SizedBox(height: 10),
                    const Text("إصدار النظام 2026.1", style: TextStyle(color: Colors.white12, fontSize: 10)),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  /* ================= هيدر تقني حاد ================= */
  Widget _buildTechHeader() {
    return Column(
      children: [
        const Icon(Icons.router_rounded, color: Color(0xFF00E5FF), size: 60), // أزرق نيون
        const SizedBox(height: 10),
        const Text(
          "نظام مايكرونت",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        Container(
          height: 2,
          width: 50,
          margin: const EdgeInsets.only(top: 8),
          color: const Color(0xFF00E5FF),
        ),
      ],
    );
  }

  /* ================= قسم المدخلات الموزع ================= */
  Widget _buildInputSection() {
    return Column(
      children: [
        _techField("عنوان السيرفر IP", Icons.terminal_rounded, controller.addressController),
        _techField("اسم المستخدم", Icons.admin_panel_settings_rounded, controller.userController),
        _techPasswordField(),
        _techField("المنفذ الرقمي", Icons.numbers_rounded, controller.portController),
        _techField("اسم الشبكة المحلية", Icons.wifi_find_rounded, controller.nameController),
      ],
    );
  }

  Widget _techField(String label, IconData icon, TextEditingController ctrl) {
    return Container(
      height: 55,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          suffixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  Widget _techPasswordField() {
    return Container(
      height: 55,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller.passwordController,
        obscureText: hidePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: "كلمة المرور",
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 18),
            onPressed: () => setState(() => hidePassword = !hidePassword),
          ),
          suffixIcon: const Icon(Icons.lock_outline, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  /* ================= الأزرار الاحترافية ================= */
  Widget _buildEliteActions() {
    return Column(
      children: [
        // زر تسجيل الدخول
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5FF),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 10,
            shadowColor: const Color(0xFF00E5FF).withOpacity(0.4),
          ),
          onPressed: controller.connectToRouter ,
          // => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeView(controller: controller))),
          child: const Text("دخول السيرفر", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        // أزرار الحفظ والعرض
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.addRouterData,
                icon: const Icon(Icons.save_rounded, color: Colors.white60, size: 18),
                label: const Text("حفظ", style: TextStyle(color: Colors.white60)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.history_rounded, color: Colors.white60, size: 18),
                label: const Text("عرض", style: TextStyle(color: Colors.white60)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
