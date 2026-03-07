import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/reports_controller.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF8FAFC),
          body: Column(
            children: [
              _buildModernHeader(context, "التقارير والإحصائيات", Icons.analytics_rounded),
              Expanded(
                child: Consumer<ReportsVM>(
                  builder: (context, vm, _) => GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.95,
                    children: [
                      // تم استبدال emerald بـ teal أو كود لوني أخضر فخم
                      _premiumStatBox("إجمالي المبيعات", "${vm.totalSales} \$", Icons.payments_rounded, const Color(0xFF10B981)),
                      _premiumStatBox("المستخدمين", "${vm.activeUsers}", Icons.groups_rounded, Colors.blueAccent),
                      _premiumStatBox("حالة النظام", vm.systemStatus, Icons.auto_graph_rounded, Colors.teal),
                      _premiumStatBox("التنبيهات", "0", Icons.notifications_active_rounded, Colors.orangeAccent),
                    ],
                  ),
                ),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= MODERN HEADER WITH BACK BUTTON ================= */
  Widget _buildModernHeader(BuildContext context, String title, IconData icon) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)], 
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x331E3A8A), blurRadius: 20, offset: Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF38BDF8), size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ================= PREMIUM STAT BOX ================= */
  Widget _premiumStatBox(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Center(
        child: Text(
          "نظام التقارير الذكي • MikroNet v5.0",
          style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
