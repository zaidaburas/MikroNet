import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/backup_controller.dart';

class BackupView extends StatelessWidget {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BackupVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Column(
            children: [
              // الهيدر المطور مع زر الرجوع
              _header(context, "إدارة النسخ الاحتياطي", Icons.cloud_sync_rounded),
              
              const SizedBox(height: 30),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<BackupVM>(
                  builder: (context, vm, _) => Column(
                    children: [
                      // بطاقة النسخ الاحتياطي
                      _actionCard(
                        title: "إنشاء نسخة احتياطية",
                        subtitle: "حفظ كافة بيانات السيرفر الحالية سحابياً",
                        icon: Icons.backup_outlined,
                        isLoading: vm.isBackingUp,
                        btnLabel: "ابدأ النسخ الآن",
                        color: const Color(0xFF2563EB),
                        onTap: () => vm.startBackup(),
                      ),
                      
                      const SizedBox(height: 20),

                      // بطاقة استعادة النسخة
                      _actionCard(
                        title: "استعادة نسخة سابقة",
                        subtitle: "استرجاع البيانات من آخر نقطة حفظ مستقرة",
                        icon: Icons.settings_backup_restore_rounded,
                        isLoading: vm.isRestoring,
                        btnLabel: "استعادة البيانات",
                        color: const Color(0xFF10B981),
                        onTap: () => vm.startRestore(),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "آخر عملية ناجحة: منذ ساعتين (12:30 م)",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= الهيدر مع زر الرجوع ================= */
  Widget _header(BuildContext context, String title, IconData icon) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // زر الرجوع
            Positioned(
              right: 15,
              top: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.cyanAccent, size: 40),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= بطاقة الإجراءات (Reusable Card) ================= */
  Widget _actionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLoading,
    required String btnLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
