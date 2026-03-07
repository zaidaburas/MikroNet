import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/sites_controller.dart';
import '../sites/dns_settings.dart';
import '../sites/black_sites.dart' show BlockedSitesView;
import '../sites/dns_cache.dart' show DnsCacheView;

class DataManagementView extends StatelessWidget {
  const DataManagementView({super.key});

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 25),
                children: [

                  _buildSectionHeader("إعدادات الشبكة"),
                  const SizedBox(height: 12),

                  _buildActionRow(
                    context,
                    icon: Icons.settings_ethernet_rounded,
                    title: "إعدادات DNS",
                    subtitle: "Remote Request • DNS Servers",
                    color: const Color(0xFF6366F1),
                    builder: (_) => const DnsSettingsView(),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader("السجلات المؤقتة"),
                  const SizedBox(height: 12),

                  _buildActionRow(
                    context,
                    icon: Icons.dns_rounded,
                    title: "DNS Cache",
                    subtitle: "عرض وحذف السجلات المؤقتة",
                    color: const Color(0xFF0EA5E9),
                    builder: (_) => const DnsCacheView(),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader("الرقابة والحماية"),
                  const SizedBox(height: 12),

                  _buildActionRow(
                    context,
                    icon: Icons.block_rounded,
                    title: "المواقع المحظورة",
                    subtitle: "إضافة • حذف • إدارة الحظر",
                    color: const Color(0xFFEF4444),
                    builder: (_) => const BlockedSitesView(),
                  ),
                ],
              ),
            ),

            _buildMiniFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= PREMIUM HEADER ================= */

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x441E3A8A),
              blurRadius: 20,
              offset: Offset(0, 10))
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white24,
                          width: 2),
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "إدارة المواقع",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 15,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () =>
                    Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= SECTION HEADER ================= */

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius:
                BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  /* ================= ACTION ROW ================= */

  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required WidgetBuilder builder,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChangeNotifierProvider.value(
                  value:
                      context.read<DataMgmtVM>(),
                  child: builder(context),
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                  child: Icon(icon,
                      color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                          color:
                              Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(
                          height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors
                              .blueGrey
                              .shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded,
                    color:
                        Colors.blueGrey.shade200),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ================= FOOTER ================= */

  Widget _buildMiniFooter() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
              color:
                  Colors.blueGrey.shade50),
        ),
      ),
      child: Center(
        child: Text(
          "نظام مايكرونت • إدارة الشبكة الذكية",
          style: TextStyle(
            color:
                Colors.blueGrey.shade300,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}