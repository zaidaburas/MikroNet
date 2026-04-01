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
    filter = "ALL";
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

  Future<void> removeHost(HostUserModel user) async{
    isLoading=true;
    update();
    AppResponse response= await UsersApi.removeOneHost(user.clientIp);
    showErrorDialog(title: response.message);
    isLoading=false;
    if (response.status) {
      hostUsers.remove(user);
    }
    update();
    // await getAllHosts();
  }

  Future<void> removeActive(ActiveUserModel user) async{
    isLoading=true;
    update();
    AppResponse response= await UsersApi.removeOneActive(user.username);
    showErrorDialog(title: response.message);
    isLoading=false;
    if (response.status) {
      activeUsers.remove(user);
    }
    update();
    // await getAllHosts();
  }

  Future<void> disconnect(String userId, {bool isActive = false}) async{
    if (isActive) {
      var user=activeUsers.firstWhere((a)=>a.id==userId);
      removeActive(user);
      return;
    }
    var user=hostUsers.firstWhere((a)=>a.id==userId);
    removeHost(user);
  }
  
  Future<void> block(String userId, {bool isActive = false}) async{
    isLoading=true;
    update();
    if (isActive) {
      var active=activeUsers.firstWhere((a)=>a.id==userId);
      var host=hostUsers.firstWhere((a)=>a.address==active.address);
      AppResponse response= await UsersApi.blockDevice(
        macAddress: host.macAddress,
        srcAddress: host.clientIp,
        dstAddress: host.address,
        label: "zaid block"
      );
      showErrorDialog(title: response.message);
      isLoading=false;
      await getAllActive();
      return;
    }
    var host=hostUsers.firstWhere((a)=>a.id==userId);
    AppResponse response= await UsersApi.blockDevice(
      macAddress: host.macAddress,
      srcAddress: host.clientIp,
      dstAddress: host.address,
      label: "zaid block"
    );
    showErrorDialog(title: response.message);
    isLoading=false;
    await getAllHosts();
  }

  void unblock(String userId, {bool isActive = false}) {}
  // void block(String userId, {bool isActive = false}) {}
  // void makeFree(String userId, {bool isActive = false}) {}

  Future<void> makeFree(String userId, {bool isActive = false}) async{
    isLoading=true;
    update();
    if (isActive) {
      var active=activeUsers.firstWhere((a)=>a.id==userId);
      var host=hostUsers.firstWhere((a)=>a.address==active.address);
      AppResponse response= await UsersApi.bypassDevice(
        macAddress: host.macAddress,
        srcAddress: host.clientIp,
        dstAddress: host.address,
        label: "zaid bybass"
      );
      showErrorDialog(title: response.message);
      isLoading=false;
      await getAllActive();
      return;
    }
    var host=hostUsers.firstWhere((a)=>a.id==userId);
    AppResponse response= await UsersApi.bypassDevice(
      macAddress: host.macAddress,
      srcAddress: host.clientIp,
      dstAddress: host.address,
      label: "zaid bybass"
    );
    showErrorDialog(title: response.message);
    isLoading=false;
    await getAllHosts();
  }

  
  


  Future<void> updateUserName(HostUserModel user, String text)async {
    isLoading=true;
    update();

    String getUserId=await UsersApi.getUserId(user.toMikrotik());
    AppResponse response =await UsersApi.editDevice(getUserId,{"comment":text} );
    // 
    isLoading=false;
    if (!response.status) {
      showErrorDialog(content: response.message);
      return;
    }
    await getInitialData();
    showErrorDialog(title: "done",content: response.message);
  }

  Future<void> getBlock()async{
    isLoading=true;
    update();
    AppResponse response=await UsersApi.getBlockedHosts();
    isLoading=false;
    update();
    showErrorDialog(title: "${response.data.length}_${response.message}",content: response.data.toString());
    // { address: 172.16.253.2, mac-address: , 
    // interface: LAN1,published: false, status: permanent,
    // vrf: main, invalid: false, dhcp: false, 
    // dynamic: false, complete: true, disabled: false},
  }

  Future<void> labelUserDevice(HostUserModel user, String text)async {
    isLoading=true;
    update();
    if (text==user.label) {
      isLoading=false;
      showErrorDialog(title: "done",content: "done");
      return;
    }
    AppResponse response =await UsersApi.labelDevice(
      macAddress: user.macAddress,
      label: text
      // srcAddress: user.srcAddress,
    );
    // Get.back();
    isLoading=false;
    if (!response.status) {
      showErrorDialog(content: response.message);
    }
    showErrorDialog(title: "done",content: response.message);
  }

  // labelUserDevice(HostUserModel user, String text) {}
}
