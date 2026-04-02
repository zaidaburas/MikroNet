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
              
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // child: SectionTitle(title: "قائمة الأجهزة المتصلة "),
                    child: Row(
                      children: [
                        SectionTitle(title: "${controller.filteredDevices} جهاز "),
                        
                      ],
                    ),
                  ),
                  Visibility(
                    visible: controller.filter=="ALL",
                    child: const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      Text("( أحمر=محظور - ",style: TextStyle(color: Colors.red),),
                      Text("أزرق=متصل بكرت - ",style: TextStyle(color: Colors.blue),),
                      Text("أصفر=بدون كرت - ",style: TextStyle(color: Colors.orange),),
                      Text("أخضر=مجان )",style: TextStyle(color: Colors.green),),
                                        ],),
                    ),
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
    return GetBuilder<UsersController>(
      builder: (controller) {
        return _buildSharedUsersList(
          isLoading: controller.isLoading,
          items: controller.hostUsers,
          emptyMessage: "لا توجد أجهزة حالياً",
          iconColorBuilder: (user) => _getHostColor(user),
          iconDataBuilder: (user) => Icons.person,
          titleBuilder: (user) => user.label=='Unknown'?'بلا تسمية':user.label,
          titleBuilder2: (user) => user.macAddress,
          // subtitleBuilder: (user) => "${user.address == user.clientIp ? user.address : '${user.clientIp} <=> ${user.address}'} • ${formatBytes(int.parse(user.upload))}/${formatBytes(int.parse(user.download))}",
          upload: (user) => formatBytes(int.parse(user.upload)),
          download: (user) => formatBytes(int.parse(user.download)),
          address: (user) => user.address,
          onTap: (user) => _showOptionsSheet(controller,user)
        );
      }
    );
  }

  Widget _buildActiveList(BuildContext context,UsersController controller) {
    return GetBuilder<UsersController>(
      builder: (controller) {
        return _buildSharedUsersList(
          isLoading: controller.isLoading,
          items: controller.activeUsers,
          emptyMessage: "لا يوجد مستخدمين نشطين", // أضفت رسالة افتراضية هنا
          iconColorBuilder: (user) => Colors.blue,
          iconDataBuilder: (user) => Icons.person,
          titleBuilder: (user) => user.username,
          titleBuilder2: (user) => user.label != "Unknown" ? user.label : user.macAddress,
          // subtitleBuilder: (user) => "${user.address} • ${formatBytes(int.parse(user.upload))}/${formatBytes(int.parse(user.download))}",
          upload: (user) => formatBytes(int.parse(user.upload)),
          download: (user) => formatBytes(int.parse(user.download)),
          address: (user) => user.address,
          onTap: (user) => _showOptionsSheet(controller,user)
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
    required String Function(T item) titleBuilder2,
    required String Function(T item) upload,
    required String Function(T item) download,
    required String Function(T item) address,
    IconData uploadIcon=Icons.arrow_upward,
    IconData downloadIcon=Icons.arrow_downward,
    // Widget titleBuilder2=const Text(
    //   "",style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),),
    // required String Function(T item) subtitleBuilder,
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleBuilder(item),style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                ),
                Text(titleBuilder2(item),style: const TextStyle(
                      fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ),
                // titleBuilder2
                
              ],
            ),
            // titleAlignment: ListTileTitleAlignment.center,
            subtitle: Row(
              children: [
                Text(
                  "ip: ${address(item)}",
                  style: const TextStyle(fontSize: 11, color: Colors.black),
                ),
                Text(
                  " ${upload(item)}",
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
                Icon(uploadIcon,size: 11,color: Colors.red,),
                // const Text(" )",style: TextStyle(fontSize: 11, color: Colors.blueGrey),),
                Text(
                  " ${download(item)}",
                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                ),
                Icon(downloadIcon,size: 11,color: Colors.blue),
                // const Text(" )",style: TextStyle(fontSize: 11, color: Colors.blueGrey),),
              ],
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
  void _showOptionsSheet(UsersController controller,dynamic user){
    buildCustomOptionsSheet(
      title: user.label,
      actions: [
        ActionItem(
          title: "تعديل مسمى الجهاز",
          icon: Icons.edit_note_rounded,
          color: const Color(0xFF6366F1),
          onTap: () {
            // استبدل الـ context هنا أيضاً بـ Get.dialog إذا أمكن
            _showHostRenameDialog(controller, user);
          },
        ),
        ActionItem(
          title: "قطع الاتصال فوراً",
          icon: Icons.link_off_rounded,
          color: Colors.orange,
          onTap: () => controller.disconnect(user.id),
        ),
        // ActionItem(
        //   title: user.type == "blocked" ? "فك حظر المستخدم" : "حظر المستخدم",
        //   icon: user.type == "blocked" ? Icons.lock_open_rounded : Icons.block_flipped,
        //   color: user.type == "blocked" ? Colors.green : Colors.red,
        //   onTap: () {
        //     user.type == "blocked"
        //         ? controller.unblock(user.id)
        //         : controller.block(user.id);
        //   },
        // ),
        // ActionItem(
        //   title: "تحويل لمستخدم مجاني",
        //   icon: Icons.card_giftcard_rounded,
        //   color: Colors.blue,
        //   onTap: () => controller.makeFree(user.macAddress),
        // ),
      ],
      controller: controller,
      mac: user.macAddress
    );
  }

  void buildCustomOptionsSheet({
    required String title,
    required List<ActionItem> actions,
    required UsersController controller,
    required String mac
  }) {
    Get.bottomSheet(
      GetBuilder<UsersController>(
        builder: (controller) {
          return Container(
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Divider(height: 40),
                // توليد عناصر القائمة ديناميكياً
                ...actions.map((action) => _actionTile(
                      action.title,
                      action.icon,
                      action.color,
                      () {
                        Get.back(); // إغلاق BottomSheet أولاً
                        action.onTap(); // ثم تنفيذ الدالة الممررة
                      },
                    )),
                const SizedBox(height: 15),
                const Text("تغيير حالة الجهاز",style:
                TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(15)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedStatus,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: "regular", child: Text("عادي")),
                        DropdownMenuItem(value: "bypassed", child: Text("مجاني")),
                        DropdownMenuItem(
                            value: "blocked", child: Text("محظور")),
                      ],
                      onChanged: (v) {
                        controller.selectedStatus = v!;
                        controller.update();
                      },
                    ),
                  ),
                ),
          
                // زر الحفظ الموحد
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.editStatus(mac);
                      Get.back();
                    },
                    child: const Text("حفظ التعديل",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /* ================= 5. نافذة التسمية المباشرة ================= */
  void _showHostRenameDialog(UsersController controller, dynamic user) {
    final TextEditingController nameCtrl =
        TextEditingController(text: user.label);
    Get.dialog(
      // context: context,
      // builder: (_) => 
      AlertDialog(
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
              onPressed: () => Get.back(),
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
                Get.back();
              },
              child: const Text("حفظ",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),

    );
  }

  

  Color _getHostColor(HostUserModel user) {
    return 
    user.type == "blocked" ? Colors.red 
    : (user.type == "bypass" ? Colors.green 
    : user.type == "auth" ? Colors.blue 
    : Colors.orange);
  }

  // IconData _getHostIcon(HostUserModel user) {
  //   return 
  //   user.type == "bypass" ? Icons.done_outline 
  //   : (user.type == "auth" ? Icons.link 
  //   : Icons.link_off);
  // }

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

class ActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  ActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}