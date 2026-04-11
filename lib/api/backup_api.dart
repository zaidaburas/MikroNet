import '/models/response.dart';
import '/models/login_model.dart';
import '/models/print_model.dart';
import '/api/login_api.dart';
import '/api/print_api.dart';

class BackupApi {
  
  // ==========================================
  // دالة تصدير البيانات (تجميع النسخة الاحتياطية)
  // ==========================================
  static Future<AppResponse<Map<String, dynamic>>> exportData({
    required bool includeLogins,
    required bool includeTemplates,
    required bool includeBatches,
    required String backupName,
  }) async {
    try {
      Map<String, dynamic> backupFileContent = {};
      List<String> savedKeys = [];

      // 1. جلب بيانات الدخول باستخدام الموديل
      if (includeLogins) {
        var loginRes = await LoginApi.getSavedLoginData();
        if (loginRes.status && loginRes.data != null) {
          // البيانات تأتي كـ List<LoginModel> جاهزة، نقوم بتحويلها فقط لـ Map للحفظ
          backupFileContent["logins"] = loginRes.data!.map((e) => e.toDatabase()).toList();
          savedKeys.add("logins");
        }
      }

      // 2. جلب القوالب باستخدام الموديل
      if (includeTemplates) {
        List templatesRes = await PrintTemplatesApi.getAllTemplates();
        List<Map<String, dynamic>> templatesList = [];
        for (var map in templatesRes) {
          // نمرر البيانات للموديل للتحقق والترتيب ثم نعيدها كـ Map
          PrintTemplatesModel model = PrintTemplatesModel.fromDatabase(map);
          templatesList.add(model.toDatabase());
        }
        backupFileContent["templates"] = templatesList;
        savedKeys.add("templates");
      }

      // 3. جلب الدفعات باستخدام الموديل
      if (includeBatches) {
        List batchesRes = await PrintBatchesApi.getAllBatches2();
        List<Map<String, dynamic>> batchesList = [];
        for (var map in batchesRes) {
          PrintBatchesModel model = PrintBatchesModel.fromDatabase(map);
          batchesList.add(model.toDatabase());
        }
        backupFileContent["batches"] = batchesList;
        savedKeys.add("batches");
      }

      // 4. إنشاء ترويسة الملف (Metadata)
      backupFileContent["metadata"] = {
        "backup_name": backupName,
        "created_at": DateTime.now().toIso8601String(),
        "keys": savedKeys,
      };

      return AppResponse(
        status: true, 
        message: "تم تجميع البيانات بنجاح", 
        data: backupFileContent
      );
      
    } catch (e) {
      return AppResponse(status: false, message: "خطأ أثناء تجميع البيانات: ${e.toString()}");
    }
  }

  // ==========================================
  // دالة استيراد البيانات (استعادة النسخة الاحتياطية)
  // ==========================================
  static Future<AppResponse<void>> importData(Map<String, dynamic> backupData) async {
    try {
      // التحقق من صحة هيكل الملف
      if (!backupData.containsKey("metadata") || !backupData["metadata"].containsKey("keys")) {
        return AppResponse(status: false, message: "ملف النسخة الاحتياطية غير صالح أو تالف.");
      }

      List<dynamic> keys = backupData["metadata"]["keys"];

      // 1. استعادة بيانات الدخول
      if (keys.contains("logins") && backupData["logins"] != null) {
        List logins = backupData["logins"];
        for (var item in logins) {
          LoginModel model = LoginModel.fromDatabase(item);
          await LoginApi.saveLoginData(model);
        }
      }

      // 2. استعادة القوالب
      if (keys.contains("templates") && backupData["templates"] != null) {
        List templates = backupData["templates"];
        for (var item in templates) {
          PrintTemplatesModel model = PrintTemplatesModel.fromDatabase(item);
          await PrintTemplatesApi.addOneTemplate(model.toDatabase());
        }
      }

      // 3. استعادة الدفعات والكروت بذكاء
      if (keys.contains("batches") && backupData["batches"] != null) {
        List batches = backupData["batches"];
        for (var item in batches) {
          PrintBatchesModel model = PrintBatchesModel.fromDatabase(item);
          List cardsData = item["cards"] ?? [];
          
          // تحضير الدفعة للحفظ (بدون الـ ID لتجنب التعارض وبدون قائمة الكروت للـ DB)
          Map<String, dynamic> batchToSave = model.toDatabase();
          batchToSave.remove("id");
          batchToSave.remove("cards"); 

          // إضافة الدفعة والحصول على الـ ID الجديد
          int newBatchId = await PrintBatchesApi.addOneBatch(batchToSave);
          
          // تحضير وإضافة الكروت وربطها بالدفعة الجديدة
          if (cardsData.isNotEmpty) {
            List<Map<String, dynamic>> cardsToInsert = [];
            for (var c in cardsData) {
              GeneratedCardsModel cardModel = GeneratedCardsModel.fromDatabase(c);
              Map<String, dynamic> cardMap = cardModel.toDatabase();
              cardMap["batch_id"] = newBatchId; // ربط الكرت بالدفعة الجديدة
              cardMap.remove("id"); // إزالة الـ ID القديم
              cardsToInsert.add(cardMap);
            }
            await PrintBatchesApi.addBatchCards(cardsToInsert, newBatchId);
          }
        }
      }

      return AppResponse(status: true, message: "تم استعادة البيانات بنجاح!");
      
    } catch (e) {
      return AppResponse(status: false, message: "خطأ أثناء استعادة البيانات: ${e.toString()}");
    }
  }
}