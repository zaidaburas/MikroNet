import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dialog_helper.dart';
import '../../api/cards_api.dart';
import '../../models/cards_model.dart';
import '../../models/response.dart';
import 'cards_list_controller.dart'; 

class CardDetailsController extends GetxController {
  final CardModel card;

  CardDetailsController({required this.card});

  late TextEditingController userCtrl;
  late TextEditingController passCtrl;
  late TextEditingController packageCtrl;
  
  RxString status = "".obs; 

  @override
  void onInit() {
    super.onInit();
    userCtrl = TextEditingController(text: card.username);
    passCtrl = TextEditingController(text: card.password);
    packageCtrl = TextEditingController(text: card.package);
    status.value = card.statusDisplay;
  }

  @override
  void onClose() {
    userCtrl.dispose();
    passCtrl.dispose();
    packageCtrl.dispose();
    super.onClose();
  }


  Future<void> saveChanges() async {
    _showLoading("جاري حفظ التعديلات...");

    try {
      AppResponse<void> response = await CardsApi.cardEdit(
        username: card.username, 
        data: {
          "username": userCtrl.text,
          "password": passCtrl.text,
        }
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.status) {
        Get.back();
        showMsgDialog(message: "تم حفظ التعديلات بنجاح");
        if (Get.isRegistered<CardsListController>()) {
          Get.find<CardsListController>().onInit();
        }
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      showMsgDialog(message: "Error saving changes: $e");
    }
  }

  Future<void> changeStatus(String newStatus) async {
    showMsgDialog(message: "تغيير الحالة مباشرة غير مدعوم حالياً");
  }

  Future<void> deleteCard() async {
    _showLoading("جاري حذف الكرت...");
    
    try {
      AppResponse<void> response = await CardsApi.deleteCard(card.username);
      
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.status) {
        Get.back(); // close confirm dialog if open
        Get.back(); // return to list
        showMsgDialog(message: "تم حذف الكرت بنجاح");
        if (Get.isRegistered<CardsListController>()) {
          Get.find<CardsListController>().onInit();
        }
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      showMsgDialog(message: "Error deleting card: $e");
    }
  }
  Future<void> _deleteCard() async {
  _showLoading("جاري حذف الكرت...");
  
  try {
    AppResponse<void> response = await CardsApi.deleteCard(card.username);
    
    // إغلاق ديالوج التحميل دائماً عند انتهاء الطلب
    if (Get.isDialogOpen ?? false) Get.back();

    if (response.status) {
      // بما أننا أغلقنا ديالوج التأكيد سابقاً، نحتاج Get.back واحدة فقط للعودة للقائمة
      Get.back(); 
      showMsgDialog(message: "تم حذف الكرت بنجاح");
      
      // تحديث القائمة السابقة إذا كانت موجودة
      if (Get.isRegistered<CardsListController>()) {
        // يفضل استدعاء دالة جلب البيانات مباشرة بدلاً من onInit
        Get.find<CardsListController>().onInit(); 
      }
    } else {
      showMsgDialog(message: response.message);
    }
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    showMsgDialog(message: "Error deleting card: $e");
  }
}

  void goBack() {
    Get.back();
  }

  // lib/controller/cards/card_details_controller.dart

void showDeleteConfirm() {
  showConfirmDialog(
    message: "هذا الإجراء سيقوم بإزالة الكرت من السيرفر بشكل دائم. هل أنت متأكد؟",
    onConfirm: () async {
      // 1. إغلاق ديالوج التأكيد أولاً
      //Get.back(); 
      
      // 2. تأخير بسيط جداً (100 ميكرو ثانية كافية) لضمان تنظيف الـ Stack
      await Future.delayed(const Duration(milliseconds: 1));
      
      // 3. استدعاء دالة الحذف التي تظهر الـ Loading
      deleteCard(); 
    },
  );
}

  void _showLoading(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            const SizedBox(width: 20),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
