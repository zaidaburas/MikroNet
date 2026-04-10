import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/users/hosts_controller.dart';
import '/models/users_model.dart';
import '../widgets/shared/layouts/sub_page_header.dart';

class HostsView extends GetView<HostsController> {
  const HostsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => HostsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        body: Column(
          children: [
            Obx(() => PremiumHeader(
              title: "اكتشاف الأجهزة",
              subtitle: "إجمالي الأجهزة المرتبطة: ${controller.hosts.length}",
              icon: Icons.devices_other_rounded,
            )),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.hosts.isEmpty) return const Center(child: Text("لا توجد أجهزة مكتشفة"));

                return RefreshIndicator(
                  onRefresh: controller.fetchHosts,
                  child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: controller.hosts.length,
                  itemBuilder: (context, i) => _buildHostCard(controller.hosts[i]),
                ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(HostUserModel h) {
    bool isBlocked = h.type==UserType.blocked;
    bool isBybass = h.type==UserType.bypassed;
    bool isAuth = h.type==UserType.authorized;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isBlocked ? Colors.red : isBybass?Colors.green:isAuth?Colors.blue: Colors.orange).withOpacity(0.1),
          child: Icon(isBlocked ? Icons.block : Icons.important_devices, color: isBlocked ? Colors.red : isBybass?Colors.green:isAuth?Colors.blue: Colors.orange),
        ),
        title: Text(h.label == "Unknown" ? "جهاز غير معروف" : h.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${h.srcAddress} • ${h.macAddress}\nمتصل منذ: ${h.uptime}\n${isBlocked?"محظور":isBybass?"مجاني":isAuth?"نشط":"غير نشط"}", style: const TextStyle(fontSize: 10)),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _openActionSheet(h),
        ),
      ),
    );
  }

  void _openActionSheet(HostUserModel h) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(h.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _actionTile("تسمية الجهاز", Icons.edit, Colors.indigo, () {
              Get.back();
              _showRenameDialog(h);
            }),
            _actionTile(h.label.contains("Block") ? "فك الحظر" : "حظر الجهاز", Icons.block, Colors.red, () {
              Get.back();
              controller.toggleBlock(h);
            }),
            _actionTile("وصول مجاني (Bypass)", Icons.bolt, Colors.amber.shade800, () {
              Get.back();
              controller.makeBypass(h);
            }),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(HostUserModel h) {
    final ctrl = TextEditingController(text: h.label);
    Get.defaultDialog(
      title: "تسمية الجهاز",
      content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "اسم الجهاز")),
      onConfirm: () {
        Get.back();
        controller.renameDevice(h, ctrl.text);
      },
    );
  }

  Widget _actionTile(String t, IconData i, Color c, VoidCallback onTap) => ListTile(
    leading: Icon(i, color: c),
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
    onTap: onTap,
  );
}