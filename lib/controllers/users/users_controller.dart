import 'package:get/get.dart';
import 'package:mikronet/api/users_api.dart';
import 'package:mikronet/models/users_model.dart';
import 'package:mikronet/services/response.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

class UsersController extends GetxController {
  List<ActiveUserModel> activeUsers = [];
  List<HostUserModel> hostUsers = [];
  
  // 1. إضافة متغير حالة التحميل
  bool isLoading = false; 
  String filter = "ALL";

  @override
  void onInit() {
    super.onInit();
    // 2. استدعاء دالة مخصصة للتحميل الأولي
    getInitialData(); 
  }

  Future<void> getInitialData() async {
    isLoading = true;
    update(); // إخبار الواجهة بإظهار دائرة التحميل

    // استدعاء الدوال بدون إظهار النوافذ المنبثقة (Dialogs)
    await getAllHosts(showDialog: false);
    await getAllActive(showDialog: false);

    isLoading = false;
    update(); // إخبار الواجهة بإخفاء دائرة التحميل وعرض البيانات
  }

  // 3. إضافة بارامتر showDialog للتحكم في ظهور النافذة
  Future<void> getAllActive({bool showDialog = true}) async {
    if (showDialog) showLoadingDialog();
    
    AppResponse response = await UsersApi.getAllActive();
    
    if (showDialog) Get.back();

    if (!response.status) {
      showErrorDialog(content: response.message);
      return; // إيقاف التنفيذ في حال الخطأ
    }
    
    List<ActiveUserModel> result = [];
    for (var i in response.data) {
      result.add(ActiveUserModel.fromMikrotik(i));
    }
    
    activeUsers = result;
    if (showDialog) update();
  }

  Future<void> getAllHosts({bool showDialog = true}) async {
    if (showDialog) showLoadingDialog();
    
    AppResponse response = await UsersApi.getAllHosts();
    
    if (showDialog) Get.back();

    if (!response.status) {
      showErrorDialog(content: response.message);
      return; // إيقاف التنفيذ في حال الخطأ
    }
    
    List<HostUserModel> result = [];
    for (var i in response.data) {
      result.add(HostUserModel.fromMikrotik(i));
    }
    
    hostUsers = result;
    if (showDialog) update();
  }

  Future<void> setFilter(String newFilter) async {
    if (filter != newFilter) {
      filter = newFilter;
      update(); // تحديث شكل الزر فوراً
      
      // يمكنك استخدام showDialog هنا لأن الواجهة قد تم بناؤها بالفعل
      if (filter == "CARD") {
        await getAllActive(showDialog: true);
      } else {
        await getAllHosts(showDialog: true);
      }
    }
  }

  void disconnect(String userId, {bool isActive = false}) {}
  void unblock(String userId, {bool isActive = false}) {}
  void block(String userId, {bool isActive = false}) {}
  void makeFree(String userId, {bool isActive = false}) {}

  // Future<void> updateUserName(HostUserModel user, String text)async{
  //   try {
  //     String getUserId=await UsersApi.getUserId(user.toMap());
  //     showErrorDialog(content: getUserId,title: "fine");
  //   } catch (e) {
  //     showErrorDialog(content: e.toString());
  //   }
  // }
  Future<void> updateUserName(HostUserModel user, String text)async {
    isLoading=true;
    update();
    String getUserId=await UsersApi.getUserId(user.toMap());
    AppResponse response =await UsersApi.editDevice(getUserId,label: text);
    Get.back();
    isLoading=false;
    if (!response.status) {
      showErrorDialog(content: response.message);
    }
    showErrorDialog(title: "done",content: response.message);
  }

  Future<void> labelUserDevice(HostUserModel user, String text)async {
    isLoading=true;
    update();
    AppResponse response =await UsersApi.labelDevice(
      macAddress: user.macAddress,
      label: text
      // srcAddress: user.srcAddress,
    );
    Get.back();
    isLoading=false;
    if (!response.status) {
      showErrorDialog(content: response.message);
    }
    showErrorDialog(title: "done",content: response.message);
  }

  // labelUserDevice(HostUserModel user, String text) {}
}
