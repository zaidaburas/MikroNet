import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/sites_controller.dart';
import '../widgets/app_scaffold_layout.dart';

class DnsSettingsView extends StatelessWidget {
  const DnsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {

    final vm = Provider.of<DataMgmtVM>(context);

    final primaryCtrl =
        TextEditingController(text: vm.primaryDns);

    final secondaryCtrl =
        TextEditingController(text: vm.secondaryDns);

    return AppScaffoldLayout(
      title: "إعدادات DNS",
      footerText: "Micronet Network System",

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            /// 🔹 Remote Request
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0,4),
                  )
                ],
              ),

              child: SwitchListTile(
                title: const Text(
                  "السماح بالطلبات الخارجية",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text(
                  "Allow Remote DNS Requests",
                ),

                value: vm.allowRemoteRequest,

                onChanged: (v) {
                  vm.updateDnsSettings(
                    v,
                    vm.primaryDns,
                    vm.secondaryDns,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 Primary DNS
            _dnsField(
              controller: primaryCtrl,
              label: "DNS الأساسي",
              hint: "8.8.8.8",
              icon: Icons.dns,
            ),

            const SizedBox(height: 15),

            /// 🔹 Secondary DNS
            _dnsField(
              controller: secondaryCtrl,
              label: "DNS الاحتياطي",
              hint: "1.1.1.1",
              icon: Icons.dns_rounded,
            ),

            const SizedBox(height: 30),

            /// 🔹 Save Button
            Container(
              height: 55,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1E3C72),
                    Color(0xff3A6EA5),
                  ],
                ),

                borderRadius: BorderRadius.circular(15),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1E3C72).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0,6),
                  )
                ],
              ),

              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "حفظ الإعدادات",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),

                onPressed: () {
                  vm.updateDnsSettings(
                    vm.allowRemoteRequest,
                    primaryCtrl.text,
                    secondaryCtrl.text,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= DNS FIELD =================

  Widget _dnsField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0,4),
          )
        ],
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xff1E3C72)),
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}