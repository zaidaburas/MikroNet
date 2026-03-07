import 'package:flutter/material.dart';
import '../../Controllers/packages_controller.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  final controller = PackagesController();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final gigasCtrl = TextEditingController();
  final megasCtrl = TextEditingController();
  final uptimeCtrl = TextEditingController();
  final speedCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final packages = controller.getPackages();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF1E3A8A),
          onPressed: () => _openUpsertSheet(),
          label: const Text("إضافة باقة",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon:
              const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildList(packages)),
          ],
        ),
      ),
    );
  }

  /* ---------------- HEADER ---------------- */

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 25, top: 50),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_tethering_rounded,
              color: Colors.white, size: 40),
          const SizedBox(height: 10),
          const Text("إدارة باقات الشبكة",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("عدد الباقات المتوفرة: ${controller.getPackages().length}",
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  /* ---------------- LIST ---------------- */

  Widget _buildList(List<PackageItem> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final p = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  p.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                trailing: Text("${p.price} ريال",
                    style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
              ),
              const Divider(indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoCell(Icons.timer_outlined, "الصلاحية",
                        "${p.days}ي ${p.hours}س"),
                    _infoCell(Icons.data_usage_rounded, "البيانات",
                        "${p.gigas}ج ${p.megas}م"),
                    _infoCell(Icons.speed_rounded, "السرعة", p.speedLimit),
                  ],
                ),
              ),
              _buildActions(p, i),
            ],
          ),
        );
      },
    );
  }

  Widget _infoCell(IconData icon, String label, String value) => Column(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade400),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value,
              textAlign: TextAlign.right,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );

  /* ---------------- SECTION LABEL ---------------- */

  Widget _sectionLabel(String title) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1E3A8A))),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------- SHEET ---------------- */

  void _openUpsertSheet({PackageItem? item, int? index}) {
    if (item != null) {
      nameCtrl.text = item.name;
      priceCtrl.text = item.price;
      daysCtrl.text = item.days.toString();
      hoursCtrl.text = item.hours.toString();
      gigasCtrl.text = item.gigas.toString();
      megasCtrl.text = item.megas.toString();
      uptimeCtrl.text = item.uptimeLimit;
      speedCtrl.text = item.speedLimit;
    } else {
      nameCtrl.clear();
      priceCtrl.clear();
      daysCtrl.clear();
      hoursCtrl.clear();
      gigasCtrl.clear();
      megasCtrl.clear();
      uptimeCtrl.clear();
      speedCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "تفاصيل الباقة المتقدمة",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              _field(nameCtrl, "اسم الباقة", Icons.badge_outlined),
              _field(priceCtrl, "سعر البيع", Icons.payments_outlined,
                  isNum: true),
              _sectionLabel("تحديد الرصيد"),
              Row(
                children: [
                  Expanded(
                      child: _field(
                          gigasCtrl, "جيجا بايت", Icons.storage_rounded,
                          isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(
                          megasCtrl, "ميجا بايت", Icons.sd_card_rounded,
                          isNum: true)),
                ],
              ),
              _sectionLabel("تحديد الصلاحية"),
              Row(
                children: [
                  Expanded(
                      child: _field(
                          daysCtrl, "عدد الأيام", Icons.calendar_month,
                          isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(hoursCtrl, "عدد الساعات", Icons.more_time,
                          isNum: true)),
                ],
              ),
              _sectionLabel("تحديد الوقت"),
              _field(uptimeCtrl, "ساعات الارتباط (Uptime)", Icons.timer,
                  isNum: true),
              _sectionLabel("تحديد السرعة"),
              _field(
                speedCtrl,
                "مثال: 4M/4M",
                Icons.speed,
              ),
              const SizedBox(height: 20),
              _saveButton(item, index),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- TEXT FIELD ---------------- */

  Widget _field(TextEditingController c, String l, IconData i,
      {bool isNum = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Directionality(
        // 👈 هذا السطر مهم
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: c,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          textAlign: TextAlign.right,
          cursorColor: const Color(0xFF1E3A8A),
          decoration: InputDecoration(
            labelText: l,

            // نجبر الليبل يتموضع يمين
            floatingLabelAlignment: FloatingLabelAlignment.start,
            alignLabelWithHint: true,

            // نخلي نص الليبل RTL صريح
            labelStyle: const TextStyle(
              textBaseline: TextBaseline.alphabetic,
            ),

            prefixIcon: Icon(
              // الأيقونة تبقى يسار
              i,
              color: const Color(0xFF1E3A8A),
              size: 20,
            ),

            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 15,
            ),

            filled: true,
            fillColor: const Color(0xFFF8FAFC),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveButton(PackageItem? item, int? index) => InkWell(
        onTap: () {
          if (nameCtrl.text.isEmpty) return;

          final p = PackageItem(
            name: nameCtrl.text,
            price: priceCtrl.text,
            days: int.tryParse(daysCtrl.text) ?? 0,
            hours: int.tryParse(hoursCtrl.text) ?? 0,
            gigas: int.tryParse(gigasCtrl.text) ?? 0,
            megas: int.tryParse(megasCtrl.text) ?? 0,
            uptimeLimit: uptimeCtrl.text,
            speedLimit: speedCtrl.text,
          );

          setState(() {
            item == null
                ? controller.addPackage(p)
                : controller.updatePackage(index!, p);
          });

          Navigator.pop(context);
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text("حفظ الإعدادات",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      );

  Widget _buildActions(PackageItem p, int i) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
                onPressed: () => _openUpsertSheet(item: p, index: i),
                icon: const Icon(Icons.edit_outlined),
                label: const Text("تعديل")),
            const VerticalDivider(),
            TextButton.icon(
                onPressed: () => setState(() => controller.deletePackage(i)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("حذف", style: TextStyle(color: Colors.red))),
          ],
        ),
      );
}
