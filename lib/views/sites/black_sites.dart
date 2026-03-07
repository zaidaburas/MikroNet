import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/sites_controller.dart';
import '../widgets/app_scaffold_layout.dart';

class BlockedSitesView extends StatelessWidget {
  const BlockedSitesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DataMgmtVM>(context);

    return AppScaffoldLayout(
      title: "المواقع المحظورة",
      footerText: "Micronet Security System",

      /// الزر العائم
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xff1E3C72),
                Color(0xff3A6EA5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff1E3C72).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: const Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              final ctrl = TextEditingController();

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("إضافة موقع للحظر"),
                  content: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: "مثال: facebook.com",
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("إلغاء"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        vm.addBlocked(ctrl.text);
                        Navigator.pop(context);
                      },
                      child: const Text("إضافة"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      /// محتوى الصفحة
      body: vm.blockedSites.isEmpty
          ? const Center(
              child: Text(
                "لا توجد مواقع محظورة حالياً",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vm.blockedSites.length,
              itemBuilder: (context, i) {
                final site = vm.blockedSites[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.block,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          site,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => vm.removeBlocked(site),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
