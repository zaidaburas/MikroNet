import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/login_controller.dart';
import '/views/helpers/dialogs.dart';

// استيراد المكونات المشتركة للتصميم الجديد
import '/views/widgets/shared/layouts/main_gate_header.dart';
import '/views/widgets/shared/layouts/app_mini_footer.dart';
import '/views/widgets/shared/typography/section_title.dart';

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
        backgroundColor: const Color(0xFFF8FAFC), // لون الخلفية الفاتح الموحد
        body: Column(
          children: [
            // 1. الهيدر الموحد
            const MainGateHeader(
              title: "تسجيل الدخول إلى الميكروتك",
              subtitle: "الرجاء إدخال بيانات الراوتر للمتابعة",
              icon: Icons.lock_outline_rounded,
              showButton: false,
            ),

            Expanded(
              child: GetBuilder<LoginController>(
                init: LoginController(),
                builder: (controller) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SectionTitle(title: "بيانات تسجيل الدخول"),
                      
                      // 2. الكرت الأبيض الذي يحتوي على الحقول
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInputField(
                              label: "اسم المستخدم",
                              icon: Icons.person,
                              ctrl: controller.userController,
                            ),
                            _buildInputField(
                              label: "كلمة المرور",
                              icon: Icons.lock,
                              ctrl: controller.passwordController,
                              isPassword: true,
                            ),
                            _buildInputField(
                              label: "عنوان IP السيرفر",
                              icon: Icons.lan_outlined, // أيقونة الشبكة
                              ctrl: controller.hostController,
                            ),
                            _buildInputField(
                              label: "اسم الشبكة المحلية",
                              icon: Icons.language, // أيقونة الكرة الأرضية
                              ctrl: controller.nameController,
                            ),
                            _buildInputField(
                              label: "المنفذ الرقمي",
                              icon: Icons.qr_code_2, // أيقونة مشابهة للمنفذ
                              ctrl: controller.portController,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 3. أزرار الإجراءات
                      _buildActionBtn(
                        text: "تسجيل الدخول",
                        icon: Icons.login_rounded,
                        bgColor: const Color(0xFF2563EB), // أزرق أساسي
                        textColor: Colors.white,
                        onPressed: controller.connectToRouter,
                      ),
                      
                      _buildActionBtn(
                        text: "حفظ البيانات",
                        icon: Icons.save_rounded,
                        bgColor: const Color(0xFF3B82F6), // أزرق أفتح قليلاً
                        textColor: Colors.white,
                        onPressed: controller.addRouterData,
                      ),

                      _buildActionBtn(
                        text: "البيانات المحفوظة",
                        icon: Icons.manage_search_rounded,
                        bgColor: const Color(0xFFE2E8F0), // رمادي فاتح
                        textColor: const Color(0xFF475569), // نص داكن
                        onPressed: controller.showSavedData,
                      ),
                    ],
                  );
                }
              ),
            ),

            // 4. الفوتر الموحد
            const AppMiniFooter(sectionName: "بوابة تسجيل الدخول"),
          ],
        ),
      ),
    );
  }

  /* ================= تصميم حقل الإدخال الجديد ================= */
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController ctrl,
    bool isPassword = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword && hidePassword,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF475569), size: 22), // الأيقونة على اليمين في RTL
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8), size: 20),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  /* ================= تصميم الأزرار السفلية الموحدة ================= */
  Widget _buildActionBtn({
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0, // بدون ظل بناءً على التصميم الفلات الفاتح
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, size: 20), // الأيقونة ستظهر على اليسار في اتجاه RTL
          ],
        ),
      ),
    );
  }
}
