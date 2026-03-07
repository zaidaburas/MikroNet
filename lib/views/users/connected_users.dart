import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/users_controller.dart';
import '../../model/active_user.dart';

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
              _buildModernHeader(context),
              _buildFilters(), // قسم الفلترة (الكل / كروت)
              Expanded(child: _buildList()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= 1. الهيدر المطور ================= */
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xff0F172A), Color(0xff1E3C72), Color(0xff2563EB)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.wifi_tethering_rounded, color: Color(0xff1E3C72), size: 30),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("المتصلين حالياً", 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= 2. قسم الفلترة المطور ================= */
  Widget _buildFilters() {
    return Consumer<ActiveUsersVM>(
      builder: (context, vm, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              _filterBtn(vm, "ALL", "جميع المتصلين"),
              const SizedBox(width: 10),
              _filterBtn(vm, "CARD", "مستخدمي الكروت"),
            ],
          ),
        );
      },
    );
  }

  Widget _filterBtn(ActiveUsersVM vm, String key, String title) {
    bool active = vm.filter == key;
    return Expanded(
      child: InkWell(
        onTap: () => vm.setFilter(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xff1E3C72) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: active ? Colors.transparent : Colors.blue.shade50),
            boxShadow: active ? [BoxShadow(color: const Color(0xff1E3C72).withOpacity(0.2), blurRadius: 8)] : [],
          ),
          child: Center(
            child: Text(title, 
              style: TextStyle(color: active ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13)),
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
        if (users.isEmpty) return const Center(child: Text("لا يوجد متصلين حالياً"));

        return ListView.builder(
          itemCount: users.length,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemBuilder: (_, i) {
            final u = users[i];
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
                  backgroundColor: (u.isBlocked ? Colors.red : Colors.green).withOpacity(0.1),
                  child: Icon(u.isBlocked ? Icons.block : Icons.person, color: u.isBlocked ? Colors.red : Colors.green),
                ),
                title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${u.ip} • ${u.speed}", style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                onTap: () => _showOptionsSheet(context, vm, u), // تفتح قائمة العمليات
              ),
            );
          },
        );
      },
    );
  }

  /* ================= 4. قائمة العمليات (Actions Sheet) ================= */
  void _showOptionsSheet(BuildContext context, ActiveUsersVM vm, ActiveUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),

            // العملية 1: تعديل المسمى (تفتح Dialog التسمية)
            _actionTile("تعديل مسمى الجهاز", Icons.edit_note_rounded, Colors.indigo, () {
              Navigator.pop(context);
              _showRenameDialog(context, vm, user);
            }),

            // العملية 2: قطع الاتصال
            _actionTile("قطع الاتصال فوراً", Icons.link_off_rounded, Colors.orange, () {
              vm.disconnect(user);
              Navigator.pop(context);
            }),

            // العملية 3: الحظر / فك الحظر
            _actionTile(user.isBlocked ? "فك حظر المستخدم" : "حظر المستخدم", 
              user.isBlocked ? Icons.lock_open_rounded : Icons.block_flipped, 
              user.isBlocked ? Colors.green : Colors.red, () {
              user.isBlocked ? vm.unblock(user) : vm.block(user);
              Navigator.pop(context);
            }),

            // العملية 4: تحويل لمجاني
            _actionTile("تحويل لمستخدم مجاني", Icons.card_giftcard_rounded, Colors.blue, () {
              vm.makeFree(user);
              Navigator.pop(context);
            }),
            
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /* ================= 5. نافذة التسمية المباشرة ================= */
  void _showRenameDialog(BuildContext context, ActiveUsersVM vm, ActiveUser user) {
    final TextEditingController nameCtrl = TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تسمية الجهاز", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: const Color(0xffF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(border: InputBorder.none, hintText: "أدخل الاسم الجديد"),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.grey))),
          _gradientBtnSmall("حفظ", () {
            vm.updateUserName(user, nameCtrl.text);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  /* ================= ويدجيت مساعدة ================= */
  Widget _actionTile(String t, IconData i, Color c, VoidCallback f) {
    return ListTile(
      onTap: f,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(i, color: c, size: 22),
      ),
      title: Text(t, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800, fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
    );
  }

  Widget _gradientBtnSmall(String t, VoidCallback f) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff059669), Color(0xff10B981)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: f,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        child: Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooter() => Container(
    height: 35, width: double.infinity, color: const Color(0xff0F172A), 
    child: const Center(child: Text("Active Users Monitor v4.5", style: TextStyle(color: Colors.white38, fontSize: 10)))
  );
}
