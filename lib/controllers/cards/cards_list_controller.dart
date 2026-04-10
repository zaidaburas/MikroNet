import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/services/mikrotik_client.dart';
import '../dialog_helper.dart';
import '../../core/routes/app_pages.dart';
import '../../models/cards_model.dart';
import '../../models/response.dart';
import '../../api/cards_api.dart';

class CardsListController extends GetxController {
  RxString filter = "الكل".obs;
  RxString searchQuery = "".obs;
  
  RxList<CardModel> allCards = <CardModel>[].obs;
  RxList<CardModel> filteredCards = <CardModel>[].obs;
  
  RxBool isLoading = true.obs;
  int _requestCounter = 0;

  // متحكمات الحقول لإضافة كرت جديد
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final pkgCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _fetchCards(); // جلب البيانات عند فتح الشاشة
  }

  @override
  void onClose() {
    close();
    userCtrl.dispose();
    passCtrl.dispose();
    pkgCtrl.dispose();
    super.onClose();
  }

  Future<void> close()async{
    // await MikrotikClient.cancel();
    if(isLoading.value){
      MikrotikClient.cancelCommand('users_profiles');
      print('\n \n \n \n \n \n \n \n \n \n');
      print('users_profiles');
      print('\n \n \n \n \n \n \n \n \n \n');
      MikrotikClient.cancelCommand('users');
      print('\n \n \n \n \n \n \n \n \n \n');
      print('users');
      print('\n \n \n \n \n \n \n \n \n \n');
    }
  }

  void goBack() {
    Get.back();
  }

  void setFilter(String newFilter) {
    filter.value = newFilter;
    _applyFilters();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // التعديل الرئيسي لفصل الحالات
  void _applyFilters() {
    var result = allCards.toList();

    if (filter.value != "الكل") {
      result = result.where((c) {
        if (filter.value == "نشطة") return c.status == "active";
        if (filter.value == "جديدة") return c.status == "normal";
        // افتراض أن أي حالة غير active أو normal تعتبر منتهية
        if (filter.value == "منتهية") return c.status != "active" && c.status != "normal"; 
        return false;
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((c) => 
        c.username.toLowerCase().contains(query) || 
        c.profile.toLowerCase().contains(query)
      ).toList();
    }

    filteredCards.assignAll(result);
  }

  void goToCardDetails(CardModel card) {
    Get.toNamed(AppRoutes.cardDetails, arguments: card);
  }

  void goToCardSessions(String username) {
    Get.toNamed(AppRoutes.cardSessions, arguments: username);
  }

  void showAddCardDialog() {
    userCtrl.clear();
    passCtrl.clear();
    pkgCtrl.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("إضافة كرت جديد", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(userCtrl, "اسم المستخدم", Icons.person_outline),
            _dialogField(passCtrl, "كلمة المرور", Icons.lock_outline),
            _dialogField(pkgCtrl, "الباقة", Icons.inventory_2_outlined),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => _addNewCard(),
            child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(i, size: 18, color: const Color(0xFF1E3A8A)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Future<void> _fetchCards() async {
    final currentId = ++_requestCounter;
    isLoading.value = true;
    
    try {
      AppResponse<List<CardModel>> response = await CardsApi.getAllCards();

      if (currentId != _requestCounter) return;

      if (response.status && response.data != null) {
        allCards.assignAll(response.data!);
        _applyFilters();
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      if (currentId == _requestCounter) {
        showMsgDialog(message: "Error fetching cards: $e");
      }
    } finally {
      if (currentId == _requestCounter) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _addNewCard() async {
    if (userCtrl.text.isEmpty || pkgCtrl.text.isEmpty) {
      showMsgDialog(message: "يرجى تعبئة اسم المستخدم والباقة على الأقل");
      return;
    }

    Get.back(); 
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))), barrierDismissible: false);

    try {
      AppResponse<void> response = await CardsApi.addOneCard(
        customer: "admin", 
        username: userCtrl.text,
        password: passCtrl.text,
        profile: pkgCtrl.text,
      );
      
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.status) {
        showMsgDialog(message: "تم إضافة الكرت بنجاح");
        _fetchCards(); // إعادة جلب البيانات لتحديث القائمة
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      showMsgDialog(message: "Error adding card: $e");
    }
  }
}

extension CardModelExt on CardModel {
  String get package => profile;
  
  // التعديل هنا ليعكس الحالات الثلاث
  String get statusDisplay {
    if (status == "active") return "نشطة";
    if (status == "normal") return "جديدة";
    return "منتهية";
  }
}