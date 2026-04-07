import 'package:get/get.dart';
import 'package:mikronet/api/cards_api.dart';
import 'package:mikronet/api/print_api.dart';
import 'package:mikronet/models/print_model.dart';
import 'package:mikronet/services/response.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

class GeneratedCardsController extends GetxController {
  GeneratedCardsController(this.generatedCards);
  
  List<GeneratedCardsModel> generatedCards;
  List customers = [];
  bool isUploading = false; 

  // @override
  // void onInit() {
  //   super.onInit();
  //   getCustomers();
  // }

  // Future<void> getCustomers() async {
  //   try {
  //     customers = await CardsApi.getCustomers();
  //     update();
  //   } catch (e) {
  //     print("Error fetching customers: $e");
  //   }
  // }
  
  // قمنا بتعديل الدالة لترجع bool لمعرفة هل نجحت الإضافة أم لا
  Future<bool> createCard(int index, GeneratedCardsModel card) async {
    try {
      // 1. حماية من انهيار التطبيق إذا لم يتم جلب العملاء
      if (customers.isEmpty) {
        throw "قائمة العملاء فارغة. يرجى الانتظار أو التحقق من الاتصال.";
      }

      // AppResponse response = await CardsApi.addOneCard(
      //   customer: customers[0]['login'], 
      //   username: card.username, 
      //   password: card.password, 
      //   profile: card.profileName
      // );

      // 2. تحديث قاعدة البيانات المحلية (تأكد من تعديل دالة changeCardType لتقبل اسم المستخدم أو الـ id)
      // await PrintBatchesApi.changeCardType(card.username, response.status);
      
      // 3. تحديث حالة الكرت بطريقة آمنة (حتى لو كان isAdd من نوع final)
      generatedCards[index] = GeneratedCardsModel(
         id: card.id,
         username: card.username,
         batchId: card.batchId,
         password: card.password,
         profileName: card.profileName,
        //  isAdd: response.status,
         isAdd: true,
      );
      
      update(); // تحديث واجهة المستخدم

      // if (!response.status) {
      //   print("خطأ في الكرت ${card.username}: ${response.message}");
      //   return false; // فشل
      // }
      
      return true; // نجاح
    } catch (e) {
      print("خطأ استثنائي في الكرت ${card.username}: ${e.toString()}");
      return false; // فشل
    }
  }

  // ==========================================
  // دوال التحكم بالرفع للسيرفر
  // ==========================================
  Future<void> startUploadingToServer() async {
    // التحقق المسبق قبل بدء الحلقة
    if (customers.isEmpty) {
       showErrorDialog(content: "لا يمكن بدء الإرسال، لم يتم التعرف على العملاء من المايكروتك بعد.");
       return;
    }

    if (isUploading) return;
    isUploading = true;
    update();

    int successCount = 0;
    int failCount = 0;

    for (int i = 0; i < generatedCards.length; i++) {
      if (!isUploading) break; // توقف إذا ضغط المستخدم إيقاف
      
      if (!generatedCards[i].isAdd) {
        // تمرير الـ index والكرت
        bool isSuccess = await createCard(i, generatedCards[i]);
        
        if (isSuccess) {
          successCount++;
        } else {
          failCount++;
          // خيار إضافي: إذا كنت تريد إيقاف العملية بالكامل عند أول خطأ، أزل التعليق عن السطرين التاليين:
          isUploading = false;
          break; 
        }
      }
    }
    
    isUploading = false;
    update();

    // إظهار تنبيه نهائي واحد فقط يوضح النتيجة بدلاً من مئات الديالوجات
    String resultMessage = "تم إيقاف العملية.\nنجح: $successCount \nفشل: $failCount";
    Get.snackbar(
      "نتيجة الإرسال", 
      resultMessage, 
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4)
    );
  }

  void stopUploading() {
    isUploading = false;
    update();
  }
}
