import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/users_controller.dart';
import '../../model/active_user.dart';

// استيراد المكونات الموحدة
import '../widgets/shared/layouts/sub_page_header.dart'; // الهيدر الفرعي
import '../widgets/shared/layouts/app_mini_footer.dart'; // الفوتر الموحد
import '../widgets/shared/typography/section_title.dart'; // عنوان الأقسام

class ActiveUsersView extends StatelessWidget {
  const ActiveUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveUsersVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF8FAFC),
          body: Column(
            children: [
              // 1. الهيدر الفرعي الموحد
              const PremiumHeader(
                title: "المتصلين حالياً",
                subtitle: "مراقبة وإدارة أجهزة الشبكة النشطة",
                icon: Icons.wifi_tethering_rounded,
              ),

              // 2. قسم الفلترة (تم تحسينه ليكون بداخل ListView أو كـ Static)
              _buildFilters(),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionTitle(title: "قائمة الأجهزة المتصلة"),
              ),

              // 3. القائمة الرئيسية
              Expanded(child: _buildList()),

              // 4. الفوتر الموحد v4.5
              const AppMiniFooter(sectionName: "Active Users Monitor"),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= 2. قسم الفلترة المطور ================= */
  Widget _buildFilters() {
    return Consumer<ActiveUsersVM>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              _filterBtn(vm, "ALL", "جميع المتصلين", Icons.group_rounded),
              const SizedBox(width: 12),
              _filterBtn(vm, "CARD", "مستخدمي الكروت", Icons.style_rounded),
            ],
          ),
        );
      },
    );
  }

  Widget _filterBtn(ActiveUsersVM vm, String key, String title, IconData icon) {
    bool active = vm.filter == key;
    return Expanded(
      child: InkWell(
        onTap: () => vm.setFilter(key),
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

  /* ================= 3. القائمة مع العمليات ================= */
  Widget _buildList() {
    return Consumer<ActiveUsersVM>(
      builder: (context, vm, _) {
        final users = vm.filteredUsers;
        if (users.isEmpty)
          return const Center(child: Text("لا يوجد متصلين حالياً"));

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, i) {
            final u = users[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.blue.shade50),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02), blurRadius: 10)
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (u.isBlocked ? Colors.red : Colors.green)
                      .withOpacity(0.1),
                  child: Icon(u.isBlocked ? Icons.block : Icons.person,
                      color: u.isBlocked ? Colors.red : Colors.green),
                ),
                title: Text(u.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                subtitle: Text("${u.ip} • ${u.speed}",
                    style:
                        const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                trailing: const Icon(Icons.more_horiz_rounded,
                    color: Colors.blueGrey),
                onTap: () => _showOptionsSheet(context, vm, u),
              ),
            );
          },
        );
      },
    );
  }

  /* ================= 4. قائمة العمليات (Actions Sheet) ================= */
  void _showOptionsSheet(
      BuildContext context, ActiveUsersVM vm, ActiveUser user) {
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
            Text(user.name,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A))),
            const Divider(height: 40),
            _actionTile("تعديل مسمى الجهاز", Icons.edit_note_rounded,
                const Color(0xFF6366F1), () {
              Navigator.pop(context);
              _showRenameDialog(context, vm, user);
            }),
            _actionTile(
                "قطع الاتصال فوراً", Icons.link_off_rounded, Colors.orange, () {
              vm.disconnect(user);
              Navigator.pop(context);
            }),
            _actionTile(
                user.isBlocked ? "فك حظر المستخدم" : "حظر المستخدم",
                user.isBlocked ? Icons.lock_open_rounded : Icons.block_flipped,
                user.isBlocked ? Colors.green : Colors.red, () {
              user.isBlocked ? vm.unblock(user) : vm.block(user);
              Navigator.pop(context);
            }),
            _actionTile(
                "تحويل لمستخدم مجاني", Icons.card_giftcard_rounded, Colors.blue,
                () {
              vm.makeFree(user);
              Navigator.pop(context);
            }),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  /* ================= 5. نافذة التسمية المباشرة ================= */
  void _showRenameDialog(
      BuildContext context, ActiveUsersVM vm, ActiveUser user) {
    final TextEditingController nameCtrl =
        TextEditingController(text: user.name);
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
                vm.updateUserName(user, nameCtrl.text);
                Navigator.pop(context);
              },
              child: const Text("حفظ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

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
