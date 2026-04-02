import 'package:flutter/material.dart';
import 'package:get/get.dart'; // تم استبدال Provider بـ GetX
import 'package:mikronet/controllers/users/devices_controller.dart';
import 'package:mikronet/models/users_model.dart';



// استيراد المكونات الموحدة v4.5
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class DevicesView extends StatelessWidget {
  const DevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // حقن المتحكم هنا ليكون متاحاً لجميع الـ GetBuilder في الصفحة
    // Get.put(DevicesController());
    // Get.put(DevicesController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<DevicesController>(
        init: DevicesController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xffF8FAFC),
          
            // زر الإضافة جهة اليسار بارتفاع متناسق
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
            floatingActionButton: GetBuilder<DevicesController>(
              builder: (controller) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 10),
                  child: FloatingActionButton(
                    backgroundColor: const Color(0xff1E3A8A),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    onPressed: () => _showAddDeviceSheet(context, controller),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 30),
                  ),
                );
              },
            ),
          
            body: Column(
              children: [
                // 1. الهيدر الفرعي الموحد
                const PremiumHeader(
                  title: "إدارة الأجهزة",
                  subtitle: "التحكم في الأجهزة المسجلة والمحظورة",
                  icon: Icons.devices_other_rounded,
                ),
          
                // 2. الفلاتر بستايل الكبسولة الموحد
                _buildFiltersSection(),
          
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  // child: SectionTitle(title: "قائمة الأجهزة ${controller.filteredDevices.length}"),
                  child: Row(children: [
                    SectionTitle(title: "${controller.filteredDevices.length} جهاز "),
                    const Text("( أحمر=محظور - ",style: TextStyle(color: Colors.red),),
                    const Text("أصفر=عادي - ",style: TextStyle(color: Colors.orange),),
                    const Text("أخضر=مجان )",style: TextStyle(color: Colors.green),),
                  ],),
                ),
          
                // 3. القائمة الرئيسية
                Expanded(child: _buildDevicesList(context)),
          
                // 4. الفوتر الموحد v4.5
                const AppMiniFooter(sectionName: "Devices Management"),
              ],
            ),
          );
        }
      ),
    );
  }

  /* ================= 2. FILTERS SECTION ================= */
  Widget _buildFiltersSection() {
    return GetBuilder<DevicesController>(
      builder: (controller) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _filterTab(controller, "ALL", "الكل"),
              _filterTab(controller, "SAVED", "محفوظة"),
              _filterTab(controller, "UNSAVED", "غير محفوظة"),
              _filterTab(controller, "BLOCKED", "محظورة"),
              _filterTab(controller, "FREE", "مجانية"),
            ],
          ),
        );
      },
    );
  }

  Widget _filterTab(DevicesController controller, String key, String title) {
    bool isSelected = controller.filter == key;
    return InkWell(
      onTap: () => controller.setFilter(key),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.blue.shade50),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.2),
                      blurRadius: 8)
                ]
              : [],
        ),
        child: Text(title,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }

  /* ================= 3. DEVICES LIST ================= */
  Widget _buildDevicesList(BuildContext context) {
    return GetBuilder<DevicesController>(
      builder: (controller) {
        final devices = controller.filteredDevices;
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          );
        }

        if (devices.isEmpty) {
          return const Center(child: Text("لا توجد أجهزة حالياً"));
        }

        return ListView.builder(
          itemCount: devices.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, i) {
            final d = devices[i];
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getStatusColor(d).withOpacity(0.1),
                  child: Icon(Icons.smartphone_rounded,
                      color: _getStatusColor(d), size: 22),
                ),
                title: Text(d.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                subtitle: Text("${d.clientIp} • ${d.macAddress}",
                    style:
                        const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                trailing: const Icon(Icons.more_horiz_rounded,
                    color: Colors.blueGrey),
                // onTap: () => _showOptionsSheet(context, controller, d, i),
                onTap: () => _showEditDeviceSheet(context, controller, d, i),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(DevicesModel d) {
    if (d.type.isBlocked) return Colors.red;
    if (d.type.isFree) return Colors.green;
    return Colors.orange;
  }

  /* ================= 4. ADD DEVICE SHEET ================= */
  void _showAddDeviceSheet(BuildContext context, DevicesController controller) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 25),
                  const Text("إضافة جهاز جديد",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 25),
                  _modernField(controller.nameCtrl, "اسم الجهاز", Icons.badge_outlined),
                  _modernField(controller.ipCtrl, "IP Address", Icons.wifi_rounded),
                  _modernField(controller.macCtrl, "MAC Address", Icons.memory_rounded),

                  // Dropdown المنسق
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
                        onChanged: (v) => setStateSheet(() {
                          controller.selectedStatus = v!;
                          controller.update();
                        }),
                      ),
                    ),
                  ),

                  // Dropdown المنسق 2
                  Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedServer,
                        isExpanded: true,
                        items: List.generate(controller.servers.length, (i){
                          return DropdownMenuItem(value: controller.servers[i], child: Text(controller.servers[i]));
                        }),
                        onChanged: (v) => setStateSheet(() {
                          controller.selectedServer = v!;
                          controller.update();
                        }),
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
                        controller.addManualDevice();
                        Navigator.pop(context);
                      },
                      child: const Text("حفظ الجهاز",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDeviceSheet(BuildContext context,DevicesController controller, DevicesModel d,int index) {
    // final TextEditingController nameCtrl = TextEditingController(text: d.label);
    controller.nameCtrl.text=d.label;
    controller.selectedStatus=d.toMikrotik()["type"];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GetBuilder<DevicesController>(
        builder: (controller) {
          return Container(
            padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(_).viewInsets.bottom + 30),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 25),
                const Text("إدارة الجهاز",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 25),
                _modernField(controller.nameCtrl, "أدخل مسمى للجهاز", Icons.edit_note_rounded),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 0),
                    onPressed: () {
                      controller.rename(d, controller.nameCtrl.text);
                      Navigator.pop(context);
                    },
                    child: const Text("حفظ المسمى الجديد",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(thickness: 0.8)),
                _customDropDowm(
                  items: ["regular","bypassed","blocked"], 
                  selectedServer: controller.selectedStatus, 
                  onChanged: (v){
                    controller.selectedStatus=v;
                    controller.update();
                  }
                ),
                _actionTile("حذف الجهاز", Icons.delete_forever_rounded, Colors.grey,
                    () {
                  controller.delete(d);
                  Navigator.pop(context);
                }),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _saveButton({
    String text ="حفظ الجهاز",
    required void Function() onPressed
  }){
    return
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
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }

  Widget _customDropDowm({
    required List<String> items,
    required String selectedServer,
    required void Function(String) onChanged
  }){
    return
    Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: const Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedServer,
          isExpanded: true,
          items: List.generate(items.length, (i){
            return DropdownMenuItem(value: items[i], child: Text(items[i]));
          }),
          onChanged:(value) => onChanged,
          // => setStateSheet(() {
          //   controller.selectedServer = v!;
          //   controller.update();
          // }),
        ),
      ),
    );
  }

  /* ================= 5. OPTIONS SHEET ================= */
  void _showOptionsSheet(BuildContext context, DevicesController controller, DevicesModel d,int index) {
    // final TextEditingController nameCtrl = TextEditingController(text: d.label);
    controller.nameCtrl.text=d.label;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(_).viewInsets.bottom + 30),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("إدارة الجهاز",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 25),
            _modernField(controller.nameCtrl, "أدخل مسمى للجهاز", Icons.edit_note_rounded),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0),
                onPressed: () {
                  controller.rename(d, controller.nameCtrl.text);
                  Navigator.pop(context);
                },
                child: const Text("حفظ المسمى الجديد",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 0.8)),
            _actionTile("حظر الجهاز", Icons.block, Colors.red, () {
              controller.block(d);
              Navigator.pop(context);
            }),
            _actionTile("فك الحظر", Icons.lock_open_rounded, Colors.green, () {
              controller.unblock(d);
              Navigator.pop(context);
            }),
            _actionTile(
                "تحويل لمجاني", Icons.card_giftcard_rounded, Colors.blue, () {
              controller.makeFree(d);
              Navigator.pop(context);
            }),
            _actionTile("حذف الجهاز", Icons.delete_forever_rounded, Colors.grey,
                () {
              controller.delete(d);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _modernField(
      TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: const Color(0xffF1F5F9),
            borderRadius: BorderRadius.circular(15)),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              icon: Icon(icon, color: const Color(0xff1E3A8A), size: 22)),
        ),
      ),
    );
  }

  Widget _actionTile(String t, IconData i, Color c, VoidCallback f) {
    return ListTile(
      onTap: f,
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(i, color: c, size: 22)),
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
