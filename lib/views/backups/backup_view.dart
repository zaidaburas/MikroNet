/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controllers/backup_controller.dart';

// استيراد المكونات المشتركة الموحدة
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class BackupView extends StatelessWidget {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BackupVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // 1. الهيدر الموحد الفخم
              const MainGateHeader(
                title: "إدارة النسخ الاحتياطي",
                subtitle: "تأمين بيانات السيرفر واستعادتها سحابياً",
                icon: Icons.cloud_sync_rounded,
              ),

              Expanded(
                child: Consumer<BackupVM>(
                  builder: (context, vm, _) => ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SectionTitle(title: "أوامر الحماية والاستعادة"),
                      const SizedBox(height: 15),

                      // بطاقة النسخ الاحتياطي المطورة
                      _buildModernBackupCard(
                        title: "إنشاء نسخة احتياطية",
                        subtitle: "حفظ كافة بيانات السيرفر الحالية سحابياً",
                        icon: Icons.backup_outlined,
                        isLoading: vm.isBackingUp,
                        btnLabel: "ابدأ النسخ الآن",
                        color: const Color(0xFF2563EB),
                        onTap: () => vm.startBackup(),
                      ),

                      const SizedBox(height: 20),

                      // بطاقة استعادة النسخة المطورة
                      _buildModernBackupCard(
                        title: "استعادة نسخة سابقة",
                        subtitle: "استرجاع البيانات من آخر نقطة حفظ مستقرة",
                        icon: Icons.settings_backup_restore_rounded,
                        isLoading: vm.isRestoring,
                        btnLabel: "استعادة البيانات",
                        color: const Color(0xFF10B981),
                        onTap: () => vm.startRestore(),
                      ),

                      const SizedBox(height: 30),

                      // حالة النظام (Status Info)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.history_rounded,
                                  size: 14, color: Colors.blueGrey),
                              SizedBox(width: 8),
                              Text(
                                "آخر عملية ناجحة: منذ ساعتين (12:30 م)",
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. الفوتر الأسود الموحد v4.5
              const AppMiniFooter(title: "نظام حماية البيانات السحابي"),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= MODERN BACKUP CARD ================= */
  Widget _buildModernBackupCard({
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                shadowColor: color.withOpacity(0.3),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      btnLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

*/