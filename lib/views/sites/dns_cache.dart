import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/sites_controller.dart';
import '../widgets/app_scaffold_layout.dart';

class DnsCacheView extends StatelessWidget {
  const DnsCacheView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DataMgmtVM>(context);

    return AppScaffoldLayout(
      title: "DNS Cache",
      footerText: "MikroTik DNS Monitor",

      /// 🔥 الزر العائم الفخم المرفوع
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xff1E3C72),
                Color(0xff3A6EA5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff1E3C72).withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: vm.clearCache,
            child: const Icon(
              Icons.delete_sweep,
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// بطاقة الإحصائية
            Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff1E3C72),
                    Color(0xff3A6EA5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.dns,
                    color: Colors.white,
                    size: 35,
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "عدد سجلات DNS",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      Text(
                        "${vm.mikrotikSites.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            /// قائمة المواقع
            Expanded(
              child: ListView.builder(
                itemCount: vm.mikrotikSites.length,
                itemBuilder: (context, i) {

                  final site = vm.mikrotikSites[i];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),

                    child: Row(
                      children: [

                        /// أيقونة الموقع
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xff1E3C72)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.language,
                            color: Color(0xff1E3C72),
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// معلومات الموقع
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                site['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                site['address']!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// زر الحذف
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              vm.deleteSite(site['id']!),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}