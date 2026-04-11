import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '/api/backup_api.dart';
import '/controllers/dialog_helper.dart';

class BackupRestoreController extends GetxController {
  final nameCtrl = TextEditingController();

  // حالة حقول الاختيار (Checkboxes)
  RxBool isLoginsChecked = true.obs;
  RxBool isTemplatesChecked = true.obs;
  RxBool isBatchesChecked = true.obs;

  @override
  void onInit() {
    super.onInit();
    // تعيين اسم افتراضي للنسخة بناءً على التاريخ
    nameCtrl.text = "Backup_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}";
  }

  // ==========================================
  // دالة إنشاء النسخة الاحتياطية (Backup)
  // ==========================================
  Future<void> createBackup() async {
    if (nameCtrl.text.trim().isEmpty) {
      showMsgDialog(message: "يرجى إدخال اسم النسخة الاحتياطية");
      return;
    }

    if (!isLoginsChecked.value && !isTemplatesChecked.value && !isBatchesChecked.value) {
      showMsgDialog(message: "يرجى تحديد عنصر واحد على الأقل للنسخ الاحتياطي");
      return;
    }

    showLoadingDialog();
    
    // 1. طلب تصدير البيانات من الـ API
    var response = await BackupApi.exportData(
      includeLogins: isLoginsChecked.value,
      includeTemplates: isTemplatesChecked.value,
      includeBatches: isBatchesChecked.value,
      backupName: nameCtrl.text.trim(),
    );

    hideDialog();

    if (response.status && response.data != null) {
      try {
        // 2. تحويل البيانات (Map) إلى نص (JSON String) ثم إلى Bytes
        String jsonString = jsonEncode(response.data);
        Uint8List fileBytes = Uint8List.fromList(utf8.encode(jsonString));
        
        // 3. فتح نافذة الحفظ وتمرير الـ Bytes مباشرة للمكتبة لتقوم هي بحفظه
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'حفظ النسخة الاحتياطية',
          fileName: '${nameCtrl.text.trim()}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: fileBytes, // <-- تمرير البيانات هنا
        );

        // 4. التحقق من نجاح العملية (المكتبة قامت بالحفظ فعلاً إذا لم يرجع null)
        if (outputFile != null) {
          // لا حاجة لاستخدام File(outputFile).writeAsString بعد الآن!
          showMsgDialog(message: "تم حفظ النسخة الاحتياطية بنجاح!");
        }
      } catch (e) {
        showMsgDialog(message: "حدث خطأ أثناء إنشاء الملف:\n${e.toString()}");
      }
    } else {
      // عرض رسالة الخطأ القادمة من الـ API
      showMsgDialog(message: response.message);
    }
  }

  // ==========================================
  // دالة استعادة النسخة الاحتياطية (Restore)
  // ==========================================
  Future<void> restoreBackup() async {
    try {
      // 1. فتح مستكشف الملفات لاختيار ملف JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        
        // 2. تحويل النص المقروء إلى Map
        Map<String, dynamic> backupData = jsonDecode(jsonString);

        showLoadingDialog();
        
        // 3. إرسال البيانات للـ API ليقوم بفكها وحفظها
        var response = await BackupApi.importData(backupData);
        
        hideDialog();

        // 4. عرض النتيجة النهائية للمستخدم
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      hideDialog();
      showMsgDialog(message: "حدث خطأ أثناء قراءة الملف:\n${e.toString()}");
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }
}