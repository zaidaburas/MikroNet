import 'package:flutter/material.dart';

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
            _buildPremiumHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle("السجلات الأخيرة"),
                  _modernSessionCard(
                    from: "2026-02-10 10:20",
                    to: "2026-02-10 12:30",
                    ip: "192.168.1.10",
                    mac: "AA:BB:CC:11:22",
                    server: "السيرفر الرئيسي",
                    upload: "120MB",
                    download: "350MB",
                  ),
                  _modernSessionCard(
                    from: "2026-02-11 09:00",
                    to: "2026-02-11 10:10",
                    ip: "192.168.1.15",
                    mac: "AA:BB:CC:33:44",
                    server: "سيرفر الاحتياط",
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

  /* ================= MODERN HEADER ================= */
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // سهم العودة لليمين تماماً كما طلبت
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "سجل الجلسات",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 45),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "رقم الكرت: $code",
                  style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 5),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w900, fontSize: 15),
      ),
    );
  }

  /* ================= MODERN SESSION CARD ================= */
  Widget _modernSessionCard({
    required String from,
    required String to,
    required String ip,
    required String mac,
    required String server,
    required String upload,
    required String download,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // رأس البطاقة (التوقيت)
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 18, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "$from  ←  $to",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // بيانات الشبكة
                _sessionInfoRow(Icons.lan_outlined, "العنوان (IP)", ip),
                _sessionInfoRow(Icons.fingerprint_rounded, "الماك (MAC)", mac),
                _sessionInfoRow(Icons.dns_outlined, "السيرفر", server),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                
                // بيانات الاستهلاك (Traffic)
                Row(
                  children: [
                    Expanded(child: _trafficIndicator(Icons.cloud_upload_outlined, "رفع", upload, Colors.orange)),
                    const SizedBox(width: 15),
                    Expanded(child: _trafficIndicator(Icons.cloud_download_outlined, "تنزيل", download, Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey.shade300),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _trafficIndicator(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }
}
