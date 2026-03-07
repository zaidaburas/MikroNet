import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/devices_controller.dart';
import '../../model/device.dart';

class DevicesView extends StatelessWidget {
  const DevicesView({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DevicesVM(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xffF8FAFC),

          // يثبت الزر أقصى اليمين
          // يثبت الزر أقصى اليمين (في RTL start = يمين)
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

          floatingActionButton: Consumer<DevicesVM>(
            builder: (context, vm, _) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 100), // 👈 يرفعه شوي
                child: FloatingActionButton(
                  backgroundColor: const Color(0xff1E3C72),
                  elevation: 8,
                  onPressed: () {
                    _showAddDeviceSheet(context, vm);
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              );
            },
          ),
          body: Column(
            children: [
              _buildModernHeader(context),
              _buildFilters(),
              Expanded(child: _buildList()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDeviceSheet(BuildContext context, DevicesVM vm) {
    final nameCtrl = TextEditingController();
    final ipCtrl = TextEditingController();
    final macCtrl = TextEditingController();
    String status = "NORMAL";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 25,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // المقبض العلوي
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // أيقونة علوية
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1E3C72), Color(0xff2563EB)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.devices,
                        color: Colors.white, size: 26),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "إضافة جهاز ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  _modernField(nameCtrl, "اسم الجهاز", Icons.badge_outlined),
                  _modernField(ipCtrl, "IP Address", Icons.wifi),
                  _modernField(macCtrl, "MAC Address", Icons.memory),

                  const SizedBox(height: 10),

                  // Dropdown منسق
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue.shade50),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: "NORMAL", child: Text("عادي")),
                          DropdownMenuItem(value: "FREE", child: Text("مجاني")),
                          DropdownMenuItem(
                              value: "BLOCKED", child: Text("محظور")),
                        ],
                        onChanged: (v) {
                          setStateSheet(() {
                            status = v!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // زر حفظ احترافي
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff059669), Color(0xff10B981)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        vm.addManualDevice(
                          name: nameCtrl.text,
                          ip: ipCtrl.text,
                          mac: macCtrl.text,
                          status: status,
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        "حفظ الجهاز",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modernField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xffF1F5F9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade50),
        ),
        child: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            icon: Icon(icon, color: const Color(0xff1E3C72)),
          ),
        ),
      ),
    );
  }

  /* ================= 1. الهيدر المطور (ستايل استوديو التصميم) ================= */
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
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.devices_other_rounded,
                        color: Color(0xff1E3C72), size: 30),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("إدارة الأجهزة",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
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
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= 2. الفلاتر المحدثة بستايل الكبسولة ================= */
  Widget _buildFilters() {
    return Consumer<DevicesVM>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            children: [
              _filterBtn(vm, "ALL", "الكل"),
              _filterBtn(vm, "SAVED", "محفوظة"),
              _filterBtn(vm, "BLOCKED", "محظورة"),
              _filterBtn(vm, "FREE", "مجانية"),
            ],
          ),
        );
      },
    );
  }

  Widget _filterBtn(DevicesVM vm, String key, String title) {
    bool active = vm.filter == key;
    return InkWell(
      onTap: () => vm.setFilter(key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xff1E3C72) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: active ? Colors.transparent : Colors.blue.shade50),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: const Color(0xff1E3C72).withOpacity(0.2),
                      blurRadius: 8)
                ]
              : [],
        ),
        child: Text(title,
            style: TextStyle(
                color: active ? Colors.white : Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }

  /* ================= 3. القائمة الأنيقة ================= */
  Widget _buildList() {
    return Consumer<DevicesVM>(
      builder: (context, vm, _) {
        final devices = vm.filteredDevices;
        if (devices.isEmpty)
          return const Center(child: Text("لا توجد أجهزة حالياً"));

        return ListView.builder(
          itemCount: devices.length,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemBuilder: (_, i) {
            final d = devices[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade50),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02), blurRadius: 10)
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(d).withOpacity(0.1),
                  child:
                      Icon(Icons.smartphone_rounded, color: _getStatusColor(d)),
                ),
                title: Text(d.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${d.ip} • ${d.mac}",
                    style: const TextStyle(fontSize: 11)),
                trailing:
                    const Icon(Icons.more_vert_rounded, color: Colors.grey),
                onTap: () => _showOptionsSheet(context, vm, d),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(Device d) {
    if (d.isBlocked) return Colors.red;
    if (d.isFree) return Colors.blue;
    return Colors.green;
  }

  /* ================= 4. قائمة العمليات وتعديل المسمى ================= */
  void _showOptionsSheet(BuildContext context, DevicesVM vm, Device d) {
    final TextEditingController nameCtrl = TextEditingController(text: d.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: MediaQuery.of(_).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("تعديل وإدارة الجهاز",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // حقل المسمى بستايل الاستوديو
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xffF1F5F9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade50),
              ),
              child: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: "أدخل مسمى للجهاز",
                  border: InputBorder.none,
                  icon: Icon(Icons.edit_note_rounded, color: Color(0xff1E3C72)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _gradientBtn("حفظ المسمى الجديد", Icons.save_rounded,
                [const Color(0xff059669), const Color(0xff10B981)], () {
              vm.rename(d, nameCtrl.text);
              Navigator.pop(context);
            }),

            const Divider(height: 30),

            _actionTile("حظر الجهاز", Icons.block, Colors.red, () {
              vm.block(d);
              Navigator.pop(context);
            }),
            _actionTile("فك الحظر", Icons.lock_open_rounded, Colors.green, () {
              vm.unblock(d);
              Navigator.pop(context);
            }),
            _actionTile(
                "تحويل لمجاني", Icons.card_giftcard_rounded, Colors.blue, () {
              vm.makeFree(d);
              Navigator.pop(context);
            }),
            _actionTile("حذف الجهاز", Icons.delete_forever_rounded, Colors.grey,
                () {
              vm.delete(d);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  /* ================= ويدجيت مساعدة ================= */
  Widget _actionTile(String t, IconData i, Color c, VoidCallback f) {
    return ListTile(
      onTap: f,
      leading: Icon(i, color: c),
      title: Text(t,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontSize: 14)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black12),
    );
  }

  Widget _gradientBtn(
      String t, IconData i, List<Color> colors, VoidCallback f) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: f,
        icon: Icon(i, color: Colors.white),
        label: Text(t,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
        height: 35,
        width: double.infinity,
        color: const Color(0xff0F172A),
        child: const Center(
            child: Text("Devices Management v4.5",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold))));
  }
}
