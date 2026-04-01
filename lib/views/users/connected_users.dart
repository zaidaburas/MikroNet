import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 1. استيراد GetX بدلاً من Provider
import 'package:mikronet/controllers/helpers/functions.dart';
import 'package:mikronet/controllers/users/users_controller.dart';
import 'package:mikronet/models/users_model.dart';

// استيراد المكونات الموحدة
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class ActiveUsersView extends StatelessWidget {
  // final UsersController controller;
  const ActiveUsersView({super.key,});
  // final UsersController controller=Get.put(UsersController());
  @override
  Widget build(BuildContext context) {
    // 2. حقن الكنترولر في الذاكرة (يقوم مقام ChangeNotifierProvider)
    

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<UsersController>(
        init: UsersController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xffF8FAFC),
            body: 
              Column(
                children: [
                  const PremiumHeader(
                    title: "المتصلين حالياً",
                    subtitle: "مراقبة وإدارة أجهزة الشبكة النشطة",
                    icon: Icons.wifi_tethering_rounded,
                  ),
                  
                  _buildFilters(controller),
              
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SectionTitle(title: "قائمة الأجهزة المتصلة "),
                  ),
              
                  Expanded(child: _buildUsersList(context,controller.filter=="ALL",controller)),
              
                  const AppMiniFooter(sectionName: "Active Users Monitor"),
                ],
              ),
              
            
            floatingActionButton: FloatingActionButton(
              onPressed: controller.getBlock,
              child: const Icon(Icons.add),
            ),
          );
        }
      ),
    );
  }

  /* ================= قسم الفلترة ================= */
  Widget _buildFilters(UsersController controller) {
    // 3. استبدال Consumer بـ GetBuilder
    // return GetBuilder<UsersController>(
    //   init: controller,
    //   builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              _filterBtn("ALL", "جميع المتصلين", Icons.group_rounded,controller),
              const SizedBox(width: 12),
              _filterBtn("CARD", "مستخدمي الكروت", Icons.style_rounded,controller),
            ],
          ),
        );
    //   },
    // );
  }

  Widget _filterBtn( String key, String title, IconData icon,UsersController controller) {
    bool active = controller.filter == key;
    return Expanded(
      child: InkWell(
        onTap: () => controller.setFilter(key),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1E3A8A) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: active ? Colors.transparent : Colors.blue.shade50),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.2),
                        blurRadius: 8)
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: active ? Colors.white : Colors.blueGrey),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= القائمة الرئيسية ================= */
    Widget _buildHostsList(BuildContext context,UsersController controller) {
    return _buildSharedUsersList(
      isLoading: controller.isLoading,
      items: controller.hostUsers,
      emptyMessage: "لا توجد أجهزة حالياً",
      iconColorBuilder: (user) => user.type == "unauth" ? Colors.red : (user.type == "auth" ? Colors.blue : Colors.green),
      iconDataBuilder: (user) => user.type == "unauth" ? Icons.link_off : (user.type == "auth" ? Icons.link : Icons.done_outline),
      titleBuilder: (user) => "${user.label} \n ${user.macAddress} ",
      subtitleBuilder: (user) => "${user.address == user.clientIp ? user.address : '${user.clientIp} <=> ${user.address}'} • ${formatBytes(int.parse(user.upload))}/${formatBytes(int.parse(user.download))}",
      onTap: (user) => _showOptionsHostsSheet(context, user,controller),
    );
  }

  Widget _buildActiveList(BuildContext context,UsersController controller) {
    return GetBuilder<UsersController>(
      init: controller,
      builder: (controller) {
        return _buildSharedUsersList(
          isLoading: controller.isLoading,
          items: controller.activeUsers,
          emptyMessage: "لا يوجد مستخدمين نشطين", // أضفت رسالة افتراضية هنا
          iconColorBuilder: (user) => Colors.green,
          iconDataBuilder: (user) => Icons.person,
          titleBuilder: (user) => "${user.username} \n ${user.label != "Unknown" ? user.label : user.macAddress} ",
          subtitleBuilder: (user) => "${user.address} • ${formatBytes(int.parse(user.upload))}/${formatBytes(int.parse(user.download))}",
          onTap: (user) => _showOptionsActiveSheet(context, controller, user),
        );
      },
    );
  }

    Widget _buildSharedUsersList<T>({
    required bool isLoading,
    required List<T> items,
    required String emptyMessage,
    required Color Function(T item) iconColorBuilder,
    required IconData Function(T item) iconDataBuilder,
    required String Function(T item) titleBuilder,
    required String Function(T item) subtitleBuilder,
    required void Function(T item) onTap,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      );
    }

    if (items.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) {
        final item = items[i];
        final iconColor = iconColorBuilder(item);
        final iconData = iconDataBuilder(item);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.blue.shade50),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(iconData, color: iconColor),
            ),
            title: Text(
              titleBuilder(item),
              style: const TextStyle(
                  fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
            ),
            titleAlignment: ListTileTitleAlignment.center,
            subtitle: Text(
              subtitleBuilder(item),
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
            ),
            trailing: const Icon(Icons.more_horiz_rounded, color: Colors.blueGrey),
            onTap: () => onTap(item),
          ),
        );
      },
    );
  }


  
  Widget _buildUsersList(BuildContext context,bool hosts,UsersController controller){
    if(hosts){
      return _buildHostsList(context,controller);
    }
    return _buildActiveList(context,controller);
  }
  // ملاحظة: دوال _showOptionsSheet و _showRenameDialog و _actionTile تبقى كما هي تماماً!
  // ...

  /* ================= 4. قائمة العمليات (Actions Sheet) ================= */
  void _showOptionsHostsSheet(
      BuildContext context, HostUserModel user,UsersController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(user.label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A))),
            const Divider(height: 40),
            _actionTile("تعديل مسمى الجهاز", Icons.edit_note_rounded,
                const Color(0xFF6366F1), () {
              Navigator.pop(context);
              _showHostRenameDialog(context, controller, user);
            }),
            _actionTile(
                "قطع الاتصال فوراً", Icons.link_off_rounded, Colors.orange, () {
              controller.disconnect(user.id);
              Navigator.pop(context);
            }),
            _actionTile(
                user.type=="blocked" ? "فك حظر المستخدم" : "حظر المستخدم",
                user.type=="blocked" ? Icons.lock_open_rounded : Icons.block_flipped,
                user.type=="blocked" ? Colors.green : Colors.red, () {
              user.type=="blocked" ? controller.unblock(user.id) : controller.block(user.id);
              Navigator.pop(context);
            }),
            _actionTile(
                "تحويل لمستخدم مجاني", Icons.card_giftcard_rounded, Colors.blue,
                () {
              controller.makeFree(user.id);
              Navigator.pop(context);
            }),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _showOptionsActiveSheet(
      BuildContext context, UsersController controller, ActiveUserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(user.label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A))),
            const Divider(height: 40),
            _actionTile("تعديل مسمى الجهاز", Icons.edit_note_rounded,
                const Color(0xFF6366F1), () {
              Navigator.pop(context);
              // _showRenameDialog(context, controller, user);
            }),
            _actionTile(
                "قطع الاتصال فوراً", Icons.link_off_rounded, Colors.orange, () {
              controller.disconnect(user.id,isActive: true);
              Navigator.pop(context);
            }),
            _actionTile(
              "حظر المستخدم",
              Icons.person,
              Colors.red, () {
              controller.block(user.id,isActive: true);
              Navigator.pop(context);
            }),
            _actionTile(
                "تحويل لمستخدم مجاني", Icons.card_giftcard_rounded, Colors.blue,
                () {
              controller.makeFree(user.id,isActive: true);
              Navigator.pop(context);
            }),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  /* ================= 5. نافذة التسمية المباشرة ================= */
  void _showHostRenameDialog(
      BuildContext context, UsersController controller, HostUserModel user) {
    final TextEditingController nameCtrl =
        TextEditingController(text: user.label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("تسمية الجهاز",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: nameCtrl,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF1F5F9),
            hintText: "أدخل الاسم الجديد",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                user.label=="Unknown"?
                controller.labelUserDevice(user, nameCtrl.text)
                :
                controller.updateUserName(user, nameCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("حفظ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _showActiveRenameDialog(
      BuildContext context, UsersController controller, ActiveUserModel user) {
    final TextEditingController nameCtrl =
        TextEditingController(text: user.label);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("تسمية الجهاز",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: nameCtrl,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xffF1F5F9),
            hintText: "أدخل الاسم الجديد",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                // controller.updateUserName(user, nameCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("حفظ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // void _showActiveRenameDialog

  Widget _actionTile(String t, IconData i, Color c, VoidCallback f) {
    return ListTile(
      onTap: f,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(i, color: c, size: 24),
      ),
      title: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 14)),
      trailing: const Icon(Icons.arrow_back_ios_new_rounded,
          size: 14, color: Colors.black12),
    );
  }


}
