import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/controllers/print/add_batch_controller.dart';
import 'package:mikronet/models/print_model.dart';
// import 'package:mikronet/models/print_model.dart';
import '/controllers/print/list_controller.dart';
import 'add_batch.dart';
// import '../packages/add_batch.dart';
// import 'page_preview.dart'; // استيراد صفحة المعاينة

class BatchesView extends StatefulWidget {
  const BatchesView({super.key});

  @override
  State<BatchesView> createState() => _BatchesViewState();
}

class _BatchesViewState extends State<BatchesView> {
  // تعريف الكنترولر
  final controller = BatchesController();
  final searchCtrl = TextEditingController();
  String filter = "ALL";

  @override
  Widget build(BuildContext context) {
    // جلب البيانات من الكنترولر
    var batches = controller.allBatches; 

    // منطق البحث
    if (searchCtrl.text.isNotEmpty) {
      batches = batches.where((b) => b.name.toLowerCase().contains(searchCtrl.text.toLowerCase())).toList();
    }

    // منطق الفلترة (تم تعديل الوصول للبيانات لتناسب Map)
    batches = batches.where((b) {
      // final sold = b['sold'] ?? 0;
      // final remaining = b['remaining'] ?? (b['total'] ?? 0);

      const sold = 1;
      const remaining = 0;
      
      if (filter == "FULL") return sold == 0;
      if (filter == "USING") return remaining > 0 && sold > 0;
      if (filter == "ENDED") return remaining == 0;
      return true;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<BatchesController>(
        init: BatchesController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Column(
              children: [
                _buildBalancedHeader(context),
                _buildSmallStats(controller.allBatches.length),
                _buildSearchRow(),
                _buildFilterTabs(),
                Expanded(child: _buildBatchesList(controller)),
                _buildFooter(),
              ],
            ),
          );
        }
      ),
    );
  }

  /* ================= الهيدر ================= */
  Widget _buildBalancedHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 35),
            const SizedBox(height: 8),
            const Text(
              "دفعات الكروت والاستهلاك",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= العداد العلوي ================= */
  Widget _buildSmallStats(int count) {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Text(
          "إجمالي الدفعات: $count",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A)),
        ),
      ),
    );
  }

  /* ================= البحث والإضافة ================= */
  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "بحث عن دفعة...",
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF1E3A8A)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AddBatchView(controller: BatchesFormController()))
              ).then((_) {
                controller.update();
                // setState(() {});
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= الفلاتر ================= */
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          _filterItem("ALL", "الكل"),
          _filterItem("FULL", "ممتلئة"),
          _filterItem("USING", "قيد الاستهلاك"),
          _filterItem("ENDED", "منتهية"),
        ],
      ),
    );
  }

  Widget _filterItem(String key, String title) {
    final active = filter == key;
    return GestureDetector(
      onTap: () => setState(() => filter = key),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /* ================= قائمة الدفعات ================= */
  Widget _buildBatchesList(BatchesController controller) {
    if (controller.allBatches.isEmpty) return const Center(child: Text("لا توجد دفعات حالياً"));

    return GetBuilder<BatchesController>(
      builder: (controller) {
        if(controller.isLoading){
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
          itemCount: controller.allBatches.length,
          itemBuilder: (_, i) {
            final b = controller.allBatches[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    subtitle: Text("الانشاء : ${b.createdAt.toString().split(" ").first} ", style: const TextStyle(fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.blue), 
                        onPressed: () {
                          _showEditBatchDialog(context, controller, b);
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => AddBatchView(controller: controller, editIndex: i, batch: b)))
                          //     .then((_) => setState(() {}));
                        }),
                        IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent), 
                        onPressed: () {
                          _showDeleteBatchDialog(context, controller, b);
                          // controller.batches.removeAt(i);
                          setState(() {});
                        }),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 10,
                    // subtitle: Text("اللاحقة: ${b.cardSuffix} | البادئة: ${b.cardPrefix}", style: const TextStyle(fontSize: 11)),
                      children: [
                        _buildStatMini(Icons.confirmation_number_outlined, "عدد الكروت", b.generatedCards.length),
                        _buildStatMini(Icons.sell_outlined, "الباقة",  b.cardsProfile),
                        _buildStatMini(Icons.login_rounded, "البادئة",  b.cardPrefix),
                        _buildStatMini(Icons.logout_rounded, "اللاحقة", b.cardSuffix ),
                      ],
                    ),
                  ),
                  _buildPrintAction( b.toDatabase(), 
                  onTap: (){
                      // controller.getBatchPreview(b);
                      controller.getBatchPreview(b.id);
                    }
                  ),
                  const Divider(height: 5,),
                  _buildPrintAction( 
                    b.toDatabase() ,
                    text: "عرض الكروت",
                    textColor: Colors.orange,
                    btnIcon: const Icon(Icons.view_agenda_outlined, size: 18, color: Colors.orange),
                    onTap: (){
                      controller.getBatchCards(b.id);
                    }
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  /* ================= نافذة خيارات الحذف ================= */
  void _showDeleteBatchDialog(BuildContext context, BatchesController controller, dynamic batch) {
    // الخيار الافتراضي: 3 (حذف من السيرفر وقاعدة البيانات معاً) ليكون الإجراء الشامل هو الافتراضي
    int selectedOption = 2; 

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return GetBuilder<BatchesController>(
              builder: (controller) {
                if (controller.isDeleteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                        SizedBox(width: 10),
                        Text("تأكيد الحذف", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "هل أنت متأكد من رغبتك في حذف الدفعة '${batch.name}'؟\nالرجاء تحديد نطاق الحذف المناسب:",
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        
                        // الخيار الأول: سيرفر فقط
                        _buildDeleteOptionCard(
                          title: "من السيرفر (المايكروتك) فقط",
                          value: 1,
                          groupValue: selectedOption,
                          onChanged: (val) => setDialogState(() => selectedOption = val!),
                        ),
                        
                        // الخيار الثاني: قاعدة بيانات فقط
                        _buildDeleteOptionCard(
                          title: "من قاعدة البيانات (التطبيق) فقط",
                          value: 2,
                          groupValue: selectedOption,
                          onChanged: (val) => setDialogState(() => selectedOption = val!),
                        ),
                        
                        // الخيار الثالث: كلاهما
                        _buildDeleteOptionCard(
                          title: "من السيرفر وقاعدة البيانات معاً",
                          value: 3,
                          groupValue: selectedOption,
                          isDestructive: true, // لإعطائه لون أحمر تحذيري
                          onChanged: (val) => setDialogState(() => selectedOption = val!),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () async{
                          await controller.deleteBatch(batch, selectedOption);
                          // controller.isDeleteLoading=true;
                          // controller.update();
                          // ======= هنا تضع منطق الحذف الخاص بك =======
                          if (selectedOption == 1) {
                            // كود الحذف من المايكروتك فقط
                            print("جارِ الحذف من السيرفر فقط...");
                          } else if (selectedOption == 2) {
                            // كود الحذف من sqflite فقط
                            print("جارِ الحذف من قاعدة البيانات فقط...");
                          } else if (selectedOption == 3) {
                            // كود الحذف من الاثنين معاً
                            print("جارِ الحذف من السيرفر وقاعدة البيانات...");
                          }
                          
                          // إغلاق النافذة
                          // Navigator.pop(context);
                          
                          // تحديث الواجهة لإخفاء الدفعة المحذوفة
                          setState(() {});
                        },
                        child: const Text("تأكيد الحذف", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }
            );
          }
        );
      }
    );
  }

  /* ================= تصميم خيار الحذف (كارت اختيار) ================= */
  Widget _buildDeleteOptionCard({
    required String title,
    required int value,
    required int groupValue,
    required ValueChanged<int?> onChanged,
    bool isDestructive = false,
  }) {
    bool isSelected = value == groupValue;
    
    // الألوان تتغير بناءً على حالة الاختيار وهل هو إجراء خطير (Destructive) أم لا
    Color activeColor = isDestructive ? Colors.redAccent : const Color(0xFF2563EB);
    Color bgColor = isSelected ? activeColor.withOpacity(0.08) : Colors.transparent;
    Color borderColor = isSelected ? activeColor : Colors.grey.withOpacity(0.3);

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? activeColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? activeColor : Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= نافذة تعديل بيانات الدفعة ================= */
  void _showEditBatchDialog(BuildContext context, BatchesController ctrl, PrintBatchesModel batch) {
    // تجهيز القيم الافتراضية للحقول من بيانات الدفعة الحالية
    TextEditingController nameController = TextEditingController(text: batch.name);
    // افتراض أن المودل الخاص بك يحتوي على حقل createdAt من نوع DateTime
    DateTime selectedDate = batch.createdAt; 

    showDialog(
      context: context,
      builder: (context) {
        // نستخدم StatefulBuilder لتحديث حالة التاريخ داخل الـ Dialog فقط
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.edit_square, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 10),
                    Text("تعديل بيانات الدفعة", style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // حقل اسم الدفعة
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "اسم الدفعة",
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        prefixIcon: const Icon(Icons.title, color: Colors.blueGrey, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // حقل تاريخ الإنشاء (يفتح منتقي التاريخ)
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            // تخصيص لغة الـ DatePicker لتكون عربية إذا أردت
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF1E3A8A), // لون الهيدر
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "تاريخ الإنشاء",
                          labelStyle: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                          prefixIcon: const Icon(Icons.calendar_month_rounded, color: Colors.blueGrey, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        // تنسيق عرض التاريخ
                        child: Text(
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () async{
                      await controller.editBatch(batch, nameController.text, selectedDate);
                      setState(() {});
                      // controller.update();
                    },
                    child: const Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildStatMini(IconData icon, String label, dynamic val) {
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text("$val", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrintAction(Map b,{
    String text="معاينة وطباعة الدفعة",
    Color textColor=Colors.green,
    Icon btnIcon=const Icon(Icons.print_rounded, size: 18, color: Colors.green),
    void Function()? onTap
  }) {
    return InkWell(
      onTap: onTap,
      // () {
        // onTap;
        // الانتقال لصفحة المعاينة مع تمرير بيانات الدفعة المختارة
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => TemplatePreviewPage(
        //       controller: controller.printTemplatesController,
        //       templateIndex: 0, // يمكن تغييره ليسمح باختيار القالب قبل الطباعة
        //       batchData: {
        //         'total': b['total'],
        //         'prefix': b['prefix'],
        //         'suffix': b['suffix'],
        //         'name': b['name'],
        //       },
        //     ),
        //   ),
        // );
      // },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            btnIcon,
            const SizedBox(width: 10),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text("نظام إدارة الشبكة v2.8", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

