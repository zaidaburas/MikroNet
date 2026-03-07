import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/sites_controller.dart';

import 'dns_settings.dart';
import 'dns_cache.dart';
import 'black_sites.dart';

class DataManagementView extends StatelessWidget {
  const DataManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataMgmtVM()..fetchFromMikrotik(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              _header(context),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [

                      _card(
                        context,
                        "إعدادات DNS",
                        Icons.settings_ethernet_rounded,
                        const DnsSettingsView(),
                      ),

                      const SizedBox(height: 15),

                      _card(
                        context,
                        "سجلات DNS Cache",
                        Icons.dns_rounded,
                        const DnsCacheView(),
                      ),

                      const SizedBox(height: 15),

                      _card(
                        context,
                        "المواقع المحظورة",
                        Icons.block_rounded,
                        const BlockedSitesView(),
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

  /* ================= HEADER ================= */

  Widget _header(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [

          /// زر الرجوع
          Positioned(
            top: 50,
            right: 15,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          /// العنوان
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [

                Icon(
                  Icons.public,
                  color: Colors.white,
                  size: 32,
                ),

                SizedBox(height: 8),

                Text(
                  "إدارة المواقع",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ================= CARD ================= */

  Widget _card(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            )
          ],

          border: Border.all(
            color: Colors.blue.shade50,
          ),
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                color: const Color(0xFF1E3A8A),
                size: 26,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}