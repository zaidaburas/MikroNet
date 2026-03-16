import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/api/print_api.dart';
import 'dart:typed_data';

import 'package:mikronet/models/print_model.dart';
// import 'package:mikronet/views/helpers/dialogs.dart'; // مسار الـ dialogs الخاص بك
import 'package:image_picker/image_picker.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

class TestTemplatesScreen extends StatefulWidget {
  const TestTemplatesScreen({Key? key}) : super(key: key);

  @override
  _TestTemplatesScreenState createState() => _TestTemplatesScreenState();
}

class _TestTemplatesScreenState extends State<TestTemplatesScreen> {
  final PrintTemplatesApi _api = PrintTemplatesApi(); // نستخدم الـ API هنا
  List<PrintTemplatesModel> _templates = []; // اللستة أصبحت من نوع Model
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // دالة لجلب كل البيانات وتحويلها إلى Models
  Future<void> _loadTemplates() async {
    try {
      // setState(() => _isLoading = true);
      final List data = await PrintTemplatesApi.getAllTemplates().timeout(Duration(seconds: 20));
      showErrorDialog(title: data.length.toString(),content: data.toString());
      // _showTemplatePreviewDialog(PrintTemplatesModel.fromDatabase(data[0]));
      Get.dialog(
        AlertDialog(
          title: const Text('معاينة القالب', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // استدعاء ويدجت المعاينة الذي صنعناه مسبقاً
              Image.memory(PrintTemplatesModel.fromDatabase(data[0]).imageData),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        )
      );
      
      setState(() {
        // تحويل كل Map قادم من قاعدة البيانات إلى PrintTemplatesModel
        _templates = data.map((e) => PrintTemplatesModel.fromDatabase(e)).toList();
        _isLoading = false;
      });
    } on Exception catch (e) {
      _isLoading = false;
      showErrorDialog(content: e.toString());
    }
  }

  // دالة لاختيار الصورة من المعرض وحفظها
  Future<void> _pickImageAndSaveTemplate() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();

        // تجهيز بيانات القالب باستخدام المودل الخاص بك
        PrintTemplatesModel newModel = PrintTemplatesModel(
          id: 0, // لن يتم استخدامه في الإضافة لأنه AutoIncrement
          name: 'قالب مخصص ${DateTime.now().minute}',
          passwordType: 'letters_numbers',
          imageData: imageBytes, 
          rows: 10,
          columns: 3,
          usernameLength: 8,
          passwordLength: 8,
          fontsize: 12,
          usernamePattern: 'user_*',
          passwordPattern: 'pass_*',
          usernameLocation: {"x": 15.0, "y": 25.0},
          passwordLocation: {"x": 15.0, "y": 35.0},
        );

        // حفظ القالب في قاعدة البيانات باستخدام دالة toDatabase()
        await PrintTemplatesApi.addOneTemplate(newModel.toDatabase());
        
        _loadTemplates(); 
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ القالب مع الصورة بنجاح! ✅'), backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم اختيار أي صورة.')),
          );
        }
      }
    } catch (e) {
      showErrorDialog(content: e.toString());
      print("Error: $e");
    }
  }

  // دالة لاختبار التعديل (يمكن تمرير Map مباشرة للتعديل الجزئي)
  Future<void> _editTemplate(int id) async {
    Map<String, dynamic> updatedData = {
      'name': 'قالب مُعدل',
      'fontsize': 18, 
    };

    await PrintTemplatesApi.templateEdit(id, updatedData);
    _loadTemplates();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل القالب بنجاح')));
  }

  // دالة لاختبار الحذف
  Future<void> _deleteTemplate(int id) async {
    await PrintTemplatesApi.deleteTemplate(id);
    _loadTemplates();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح')));
  }

  // دالة لعرض تفاصيل
  Future<void> _viewSingleTemplate(int id) async {
    final data = await PrintTemplatesApi.getTemplateData(id);
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

    // دالة لعرض معاينة القالب ببيانات تجريبية
  void _showTemplatePreviewDialog(PrintTemplatesModel template) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('معاينة القالب', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // استدعاء ويدجت المعاينة الذي صنعناه مسبقاً
              CardPreviewWidget(
                template: template,
                sampleUsername: '87654321', // بيانات تجريبية للمعاينة
                samplePassword: '87654321', // بيانات تجريبية للمعاينة
              ),
              const SizedBox(height: 15),
              const Text(
                'هذه معاينة تقريبية لشكل الكرت باستخدام بيانات افتراضية.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
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
                    final PrintTemplatesModel template = _templates[index]; // استخدام المودل
                    final int id = template.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          // عرض الصورة المحفوظة إن وجدت
                          backgroundImage: MemoryImage(template.imageData),
                        ),
                        title: Text(template.name),
                        subtitle: Text('ID: $id | Font Size: ${template.fontsize}'),
                        trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    // زر المعاينة الجديد الذي أضفناه
    IconButton(
      icon: const Icon(Icons.preview, color: Colors.purple),
      onPressed: () => _showTemplatePreviewDialog(template), // نمرر كائن القالب كاملاً
      tooltip: 'معاينة القالب',
    ),
    IconButton(
                              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              onPressed: () => _viewSingleTemplate(id), 
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _editTemplate(id), 
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTemplate(id), 
                            ),
    // الأزرار السابقة...
    IconButton(
      icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
      onPressed: () => _viewSingleTemplate(id), // عرض تفاصيل البيانات كنص
      tooltip: 'البيانات الخام',
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

                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                            
                        //   ],
                        // ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImageAndSaveTemplate,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('إضافة قالب بصورة حقيقية'),
      ),
    );
  }
}
















// import 'package:mikronet/services/mikrotik_client.dart';

class TestBatchesScreen extends StatefulWidget {
  // final MikrotikClient mikrotikAdapter;
  const TestBatchesScreen({Key? key/*, required this.mikrotikAdapter*/}) : super(key: key);

  @override
  _TestBatchesScreenState createState() => _TestBatchesScreenState();
}

class _TestBatchesScreenState extends State<TestBatchesScreen> {
  final PrintBatchesApi _api = PrintBatchesApi(); // نستخدم الـ API
  List<PrintBatchesModel> _batches = []; // اللستة أصبحت من نوع Model
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  // جلب كل الدفعات وتحويلها لمودلز متكاملة (مع قوالبها)
  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    final List data = await PrintBatchesApi.getAllBatches();
    
    // بما أن fromDatabase تحتوي على await بداخلها، يجب استخدام Future.wait للتعامل مع اللستة
    List<PrintBatchesModel> parsedBatches = await Future.wait(
      data.map((e) => PrintBatchesModel.fromDatabase(e))
    );

    setState(() {
      _batches = parsedBatches;
      _isLoading = false;
    });
  }

  // إضافة دفعة عبر المودل
  Future<void> _addDummyBatch() async {
    PrintBatchesModel dummyModel = PrintBatchesModel(
      id: 0,
      name: 'دفعة كروت فئة شهر ${DateTime.now().minute}',
      createdAt: DateTime.now().toString(),
      template: null, // تم وضع null للتجربة
      generatedCards: 'card1,card2,card3',
      cardsType: '30 Days',
      cardPrefix: 'net_',
      cardSuffix: '_26',
    );

    await PrintBatchesApi.addOneBatch(dummyModel.toDatabase());
    _loadBatches();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الدفعة بنجاح!')),
      );
    }
  }

  Future<void> _editBatch(int id) async {
    Map<String, dynamic> updatedData = {
      'name': 'دفعة معدلة ${DateTime.now().second}',
    };

    await PrintBatchesApi.batchEdit(id, updatedData);
    _loadBatches();
  }

  Future<void> _deleteLocal(int id) async {
    await PrintBatchesApi.deleteFromLocal(id);
    _loadBatches();
  }

  Future<void> _deleteFull(int id) async {
    try {
      await PrintBatchesApi.deleteBatch(id);
      
      _loadBatches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف بنجاح! ✅'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                    final PrintBatchesModel batch = _batches[index]; // التعامل مع المودل النظيف
                    final int id = batch.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(batch.name),
                        // نصل لبيانات القالب مباشرة لأن المودل جلبها لنا مسبقاً
                        subtitle: Text('الكروت: ${batch.generatedCards.split(',').length} | القالب: ${batch.template?.name ?? 'بدون'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _editBatch(id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.orange),
                              onPressed: () => _deleteLocal(id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () => _deleteFull(id),
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





class CardPreviewWidget extends StatelessWidget {
  final PrintTemplatesModel template;
  final String sampleUsername;
  final String samplePassword;

  const CardPreviewWidget({
    Key? key,
    required this.template,
    required this.sampleUsername,
    required this.samplePassword,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدمنا LayoutBuilder لمعرفة حجم الحاوية المتاحة (اختياري لكنه مفيد)
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      // ميزة ClipRRect لمنع خروج الصورة أو النصوص عن حواف الحاوية
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // 1. الطبقة السفلية: صورة القالب
            // نستخدم Image.memory لأن الصورة محفوظة كـ Bytes (BLOB)
            Image.memory(
              template.imageData,
              fit: BoxFit.contain, // يمكنك تغييرها لـ cover حسب الاحتياج
              width: double.infinity,
            ),
            
            // 2. الطبقة العلوية الأولى: اسم المستخدم (يتم رسمه بناءً على الإحداثيات)
            Positioned(
              left: template.usernameLocation["x"]?.toDouble() ?? 0.0,
              top: template.usernameLocation["y"]?.toDouble() ?? 0.0,
              child: Text(
                sampleUsername,
                style: TextStyle(
                  fontSize: template.fontsize.toDouble(),
                  color: Colors.black, // يمكنك لاحقاً إضافة حقل للون الخط في المودل
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 3. الطبقة العلوية الثانية: كلمة المرور (نفس الفكرة)
            // نتأكد أولاً أن نوع القالب لا يخفي كلمة المرور
            if (template.passwordType != 'none')
              Positioned(
                left: template.passwordLocation["x"]?.toDouble() ?? 0.0,
                top: template.passwordLocation["y"]?.toDouble() ?? 0.0,
                child: Text(
                  samplePassword,
                  style: TextStyle(
                    fontSize: template.fontsize.toDouble(),
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
