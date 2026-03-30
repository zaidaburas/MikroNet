import 'package:flutter/material.dart';
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/widgetsCard/session_info_card.dart';

class CardSessionsView extends StatelessWidget {
  final String code;

  const CardSessionsView({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // 1. الهيدر الموحد (بدلاً من الميثود القديمة)
            PremiumHeader(
              title: "سجل الجلسات",
              subtitle: "رقم الكرت: $code",
              // showBackButton هي true تلقائياً
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle("السجلات الأخيرة"),
                  
                  // 2. استخدام الويدجت الجاهز SessionInfoCard بدلاً من _modernSessionCard
                  const SessionInfoCard(
                    from: "2026-02-10 10:20",
                    to: "2026-02-10 12:30",
                    ip: "192.168.1.10",
                    mac: "AA:BB:CC:11:22",
                    upload: "120MB",
                    download: "350MB",
                  ),
                  
                  const SessionInfoCard(
                    from: "2026-02-11 09:00",
                    to: "2026-02-11 10:10",
                    ip: "192.168.1.15",
                    mac: "AA:BB:CC:33:44",
                    upload: "60MB",
                    download: "180MB",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ميثود بسيطة للعنوان بقيت هنا لأنها سطر واحد ولا تتكرر كثيراً
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF475569), 
          fontWeight: FontWeight.w900, 
          fontSize: 15
        ),
      ),
    );
  }
}
