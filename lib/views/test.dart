import 'package:flutter/material.dart';
import 'package:mikronet/models/mikrotik_model.dart';
import 'package:mikronet/models/print_batches_model.dart';
import 'dart:typed_data';

import 'package:mikronet/models/print_templates_model.dart';
import 'package:mikronet/views/helpers/dialogs.dart'; // مهم للتعامل مع حقل الـ BLOB (image)
import 'package:image_picker/image_picker.dart';

// استدعِ المودل الخاص بك هنا
// import 'package:mikronet/models/print_templates_model.dart';

class TestTemplatesScreen extends StatefulWidget {
  const TestTemplatesScreen({Key? key}) : super(key: key);

  @override
  _TestTemplatesScreenState createState() => _TestTemplatesScreenState();
}

class _TestTemplatesScreenState extends State<TestTemplatesScreen> {
  final PrintTemplatesModel _model = PrintTemplatesModel();
  List _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // دالة لجلب كل البيانات وعرضها
  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    final data = await _model.getAllTemplates();
    setState(() {
      _templates = data;
      _isLoading = false;
    });
  }

  final ImagePicker _picker = ImagePicker();

  // دالة لاختيار الصورة من المعرض وحفظها مع القالب
  Future<void> _pickImageAndSaveTemplate() async {
    try {
      // 1. فتح المعرض لاختيار الصورة
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 2. تحويل الصورة المحددة إلى Uint8List (الصيغة المناسبة لحقل BLOB)
        Uint8List imageBytes = await pickedFile.readAsBytes();

        // 3. تجهيز بيانات القالب متضمنة الصورة الفعلية
        Map<String, dynamic> newTemplateData = {
          'name': 'قالب كروت مخصص ${DateTime.now().minute}',
          'password_type': 'letters_numbers',
          'photo': pickedFile.name, // حفظ اسم أو مسار الصورة كمرجع نصي
          'image': imageBytes, // <--- هنا نضع الصورة المحولة (BLOB)
          'rows': 10,
          'columns': 3,
          'username_length': 8,
          'password_length': 8,
          'fontsize': 12,
          'username_pattern': 'user_*',
          'password_pattern': 'pass_*',
          'username_location_x': 15.0,
          'username_location_y': 25.0,
          'password_location_x': 15.0,
          'password_location_y': 35.0,
        };

        // 4. حفظ القالب في قاعدة البيانات باستخدام المودل الخاص بك
        await _model.addOneTemplate(newTemplateData);
        
        // 5. تحديث الواجهة لعرض البيانات الجديدة
        _loadTemplates(); 
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ القالب مع الصورة بنجاح! ✅'), backgroundColor: Colors.green),
          );
        }
      } else {
        // في حال قام المستخدم بفتح المعرض وتراجع دون اختيار صورة
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم اختيار أي صورة.')),
          );
        }
      }
    } catch (e) {
      showErrorDialog(content: e.toString());
      // print("حدث خطأ أثناء اختيار أو حفظ الصورة: $e");
    }
  }

  // دالة لاختبار إضافة قالب ببيانات وهمية
  Future<void> _addDummyTemplate() async {
    try {
      Map<String, dynamic> dummyData = {
        'name': 'قالب كروت جديد ${DateTime.now().second}',
        'password_type': 'numbers',
        'photo': 'path/to/photo.jpg',
        'image': Uint8List(0), // بيانات وهمية فارغة لحقل الـ BLOB
        'rows': 5,
        'columns': 2,
        'username_length': 6,
        'password_length': 6,
        'fontsize': 14,
        'username_pattern': 'user_*',
        'password_pattern': 'pass_*',
        'username_location_x': 10.5,
        'username_location_y': 20.0,
        'password_location_x': 10.5,
        'password_location_y': 30.0,
      };

      await _model.addOneTemplate(dummyData);
      _loadTemplates(); // تحديث القائمة بعد الإضافة
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة القالب بنجاح')));
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  // دالة لاختبار التعديل
  Future<void> _editTemplate(int id) async {
    Map<String, dynamic> updatedData = {
      'name': 'قالب مُعدل',
      'fontsize': 18, // تعديل حجم الخط كمثال
    };

    await _model.templateEdit(id, updatedData);
    _loadTemplates();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل القالب بنجاح')));
  }

  // دالة لاختبار الحذف
  Future<void> _deleteTemplate(int id) async {
    await _model.deleteTemplate(id);
    _loadTemplates();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح')));
  }

  // دالة لاختبار جلب قالب واحد وعرضه في Dialog
  Future<void> _viewSingleTemplate(int id) async {
    final data = await _model.getTemplateData(id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل القالب رقم $id'),
        content: Text(data.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار قوالب الطباعة'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const Center(child: Text('لا توجد قوالب مضافة بعد.'))
              : ListView.builder(
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final int id = template['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(template['name'] ?? 'بدون اسم'),
                        subtitle: Text('ID: $id | Font Size: ${template['fontsize']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () => _viewSingleTemplate(id), // عرض تفاصيل
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _editTemplate(id), // تعديل
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTemplate(id), // حذف
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _pickImageAndSaveTemplate, // استدعاء دالة اختيار الصورة
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('إضافة قالب بصورة حقيقية'),
            ),

    );
  }
}



  




// import 'package:flutter/material.dart';

// استدعِ المودلات الخاصة بك هنا
// import 'package:mikronet/models/print_batches_model.dart';
// import 'package:mikronet/models/mikrotik_model.dart'; // تأكد من المسار

class TestBatchesScreen extends StatefulWidget {
  final MikrotikAdapter mikrotikAdapter;
  const TestBatchesScreen({Key? key,required this.mikrotikAdapter}) : super(key: key);

  @override
  _TestBatchesScreenState createState() => _TestBatchesScreenState();
}

class _TestBatchesScreenState extends State<TestBatchesScreen> {
  final PrintBatchesModel _model = PrintBatchesModel();
  List _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  // جلب كل الدفعات وعرضها
  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    final data = await _model.getAllBatches();
    setState(() {
      _batches = data;
      _isLoading = false;
    });
  }

  // إضافة دفعة كروت ببيانات وهمية وقصيرة
  Future<void> _addDummyBatch() async {
    Map<String, dynamic> dummyData = {
      'name': 'دفعة كروت فئة شهر ${DateTime.now().minute}',
      'created_at': DateTime.now().toString(),
      'template_id': 1, // رقم قالب افتراضي
      'generated_cards': 'card1,card2,card3', // عدد كروت قليل للتجربة
      'cards_type': '30 Days',
      'card_prefix': 'net_',
      'card_suffix': '_26'
    };

    await _model.addOneBatch(dummyData);
    _loadBatches();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الدفعة بنجاح!')),
      );
    }
  }

  // تعديل اسم الدفعة للتجربة
  Future<void> _editBatch(int id) async {
    Map<String, dynamic> updatedData = {
      'name': 'دفعة معدلة ${DateTime.now().second}',
    };

    await _model.batchEdit(id, updatedData);
    _loadBatches();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل الدفعة بنجاح!')),
      );
    }
  }

  // الحذف المحلي (من التطبيق فقط)
  Future<void> _deleteLocal(int id) async {
    await _model.deleteFromLocal(id);
    _loadBatches();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحذف المحلي بنجاح!')),
      );
    }
  }

  // الحذف الشامل (من التطبيق وسيرفر المايكروتيك)
  Future<void> _deleteFull(int id) async {
    try {
      // ملاحظة: هنا يجب أن تمرر كائن المايكروتيك الفعلي المتصل بالشبكة
      // MikrotikAdapter myMikrotik = MikrotikAdapter(...); 
      await _model.deleteBatch(id, widget.mikrotikAdapter);

      // للتجربة فقط، سأقوم باستدعاء الحذف المحلي لتجنب خطأ نقص الكائن
      // await _model.deleteFromLocal(id); 
      
      _loadBatches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الحذف من القاعدة والمايكروتيك بنجاح! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // عرض تفاصيل الدفعة والكروت المولدة فيها
  Future<void> _viewSingleBatch(int id) async {
    final data = await _model.getBatchData(id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'بدون اسم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تاريخ الإنشاء: ${data['created_at']}'),
            const SizedBox(height: 10),
            Text('نوع الكروت: ${data['cards_type']}'),
            const SizedBox(height: 10),
            const Text('الكروت المولدة:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(data['generated_cards'] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة دفعات الكروت'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? const Center(child: Text('لا توجد دفعات مضافة بعد.'))
              : ListView.builder(
                  itemCount: _batches.length,
                  itemBuilder: (context, index) {
                    final batch = _batches[index];
                    final int id = batch['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(batch['name'] ?? 'بدون اسم'),
                        subtitle: Text('عدد الكروت: ${batch['generated_cards'].split(',').length} | القالب: ${batch['template_id']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () => _viewSingleBatch(id),
                              tooltip: 'عرض التفاصيل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _editBatch(id),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.orange),
                              onPressed: () => _deleteLocal(id),
                              tooltip: 'حذف محلي فقط',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _deleteFull(id),
                              tooltip: 'حذف من السيرفر والقاعدة',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDummyBatch,
        icon: const Icon(Icons.add),
        label: const Text('إضافة دفعة تجريبية'),
      ),
    );
  }
}









