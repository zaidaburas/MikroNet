import 'package:get/get.dart';
import 'package:mikronet/api/users_api.dart';
import 'package:mikronet/models/users_model.dart';
import 'package:mikronet/services/response.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

class UsersController extends GetxController {
  List<ActiveUserModel> activeUsers = [];
  List<HostUserModel> hostUsers = [];
  int filteredDevices=0;
  // 1. إضافة متغير حالة التحميل
  bool isLoading = false; 
  String filter = "ALL";
  String selectedStatus="regular";

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
    // await getAllHosts();
    // await getAllActive();
    setFilter("ALL");
    isLoading = false;
    update(); // إخبار الواجهة بإخفاء دائرة التحميل وعرض البيانات
  }

  // 3. إضافة بارامتر showDialog للتحكم في ظهور النافذة
  Future<void> getAllActive() async {
    // if (showDialog) showLoadingDialog();
    
    AppResponse response = await UsersApi.getAllActive();
    
    // if (showDialog) Get.back();

    if (!response.status) {
      showErrorDialog(content: response.message);
      return; // إيقاف التنفيذ في حال الخطأ
    }
    
    List<ActiveUserModel> result = [];
    for (var i in response.data) {
      result.add(ActiveUserModel.fromMikrotik(i));
    }
    
    activeUsers = result;
    update();
  }

  Future<void> getAllHosts() async {
    // if (showDialog) showLoadingDialog();
    
    AppResponse response = await UsersApi.getAllHosts();
    
    // if (showDialog) Get.back();

    if (!response.status) {
      showErrorDialog(content: response.message);
      return; // إيقاف التنفيذ في حال الخطأ
    }
    List<HostUserModel> result = [];
    for (var i in response.data) {
      // i["comment"]=i["comment"]=="Unknown"?"غير مسمى":i["comment"];
      result.add(HostUserModel.fromMikrotik(i));
    }



    hostUsers = result;
    update();
  }

  Future<void> setFilter(String newFilter) async {
    isLoading = true;
    // update();
    filter = newFilter;
    update(); 
      
    // يمكنك استخدام showDialog هنا لأن الواجهة قد تم بناؤها بالفعل
    if (filter == "CARD") {
      await getAllActive();
      filteredDevices=activeUsers.length;
      isLoading = false;
      update();
    } else {
      await getAllHosts();
      filteredDevices=hostUsers.length;
      isLoading = false;
      update();
    }
  // }
  }

  Future<void> _removeHost(HostUserModel user) async{
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

  Future<void> _removeActive(ActiveUserModel user) async{
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
      _removeActive(user);
      return;
    }
    var user=hostUsers.firstWhere((a)=>a.id==userId);
    _removeHost(user);
  }
  
  Future<void> editStatus(String mac)async{
    isLoading=true;
    update();
    var host=hostUsers.firstWhere((a)=>a.macAddress==mac);
    String userId=await UsersApi.getUserId(host.toMikrotik());
    if (userId.startsWith("*")) {
      AppResponse response=await UsersApi.editDevice(userId, {"type":selectedStatus});
      showErrorDialog(content: response.message);
      isLoading=false;
      update();
      getInitialData();
      return;
    }
    AppResponse response=await UsersApi.saveDevice(
      macAddress: host.macAddress,
      srcAddress: host.clientIp,
      type: selectedStatus
    );
    showErrorDialog(title: "1" ,content: response.message);
    isLoading=false;
    update();
    getInitialData();
  }

  Future<void> _blockActive(ActiveUserModel user) async{
    String id =await UsersApi.getUserId(user.toMikrotik());
    if(id.startsWith("*")){
      await UsersApi.editDevice(id, {"type":"blocked"});
      return;
    }
    AppResponse response= await UsersApi.blockDevice(macAddress: user.macAddress);
    showErrorDialog(title: response.message);
  }

  Future<void> _blockHost(HostUserModel user) async{
    String id =await UsersApi.getUserId(user.toMikrotik());
    if(id.startsWith("*")){
      await UsersApi.editDevice(id, {"type":"blocked","address":user.clientIp});
      return;
    }
    AppResponse response= await UsersApi.blockDevice(macAddress: user.macAddress);
    showErrorDialog(title: response.message);
  }
  
  Future<void> block(String userId, {bool isActive = false}) async{
    isLoading=true;
    update();
    if (isActive) {
      var active=activeUsers.firstWhere((a)=>a.id==userId);
      _blockActive(active);
      isLoading=false;
      await getAllActive();
      return;
    }
    var host=hostUsers.firstWhere((a)=>a.id==userId);
    _blockHost(host);
    isLoading=false;
    await getAllHosts();
  }

  void unblock(String userId, {bool isActive = false}) {}
  // void block(String userId, {bool isActive = false}) {}
  // void makeFree(String userId, {bool isActive = false}) {}

  Future<bool> _makeFree(HostUserModel user) async{
    String userId= await UsersApi.getUserId(user.toMikrotik());
    if(!userId.startsWith("*")){
      AppResponse response= await UsersApi.bypassDevice(
        macAddress: user.macAddress,
        srcAddress: user.clientIp,
      );
      return response.status;
    }

    AppResponse response= await UsersApi.editDevice(userId, {"type":"bypassed","comment":"bypassed"});
    return response.status;
  }

  Future<void> makeFree(String mac, {bool isActive = false}) async{
    isLoading=true;
    update();
    var host=hostUsers.firstWhere((a)=>a.macAddress==mac);
    bool r=await _makeFree(host);
    showErrorDialog(content: r.toString());
    isLoading=false;
    update();
    await getAllActive();
    await getAllHosts();
  }

  Future<void> makeFree0(String userId, {bool isActive = false}) async{
    isLoading=true;
    update();
    if (isActive) {
      var active=activeUsers.firstWhere((a)=>a.id==userId);
      var host=hostUsers.firstWhere((a)=>a.address==active.address);
      AppResponse response= await UsersApi.bypassDevice(
        macAddress: host.macAddress,
        srcAddress: host.clientIp,
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
      label: "zaid bybass"
    );
    showErrorDialog(title: response.message);
    isLoading=false;
    await getAllHosts();
  }

  
  


  Future<void> updateUserName(dynamic user, String text)async {
    if (text==user.label) {
      showErrorDialog(title: "done",content: "done");
      return;
    }
    isLoading=true;
    update();

    String getUserId=await UsersApi.getUserId(user.toMikrotik());
    AppResponse response =await UsersApi.editDevice(getUserId,{"comment":text} );
    // 
    isLoading=false;
    update();
    if (!response.status) {
      showErrorDialog(content: response.message);
      return;
    }
    user.label=text;
    update();
    // await getInitialData();
    showErrorDialog(title: "done",content: response.message);
  }

  Future<void> getBlock()async{
    isLoading=true;
    update();
    AppResponse response=await UsersApi.getBlockedHosts();
    isLoading=false;
    update();
    showErrorDialog(title: "${response.data.length}_${response.message}",content: response.data.toString());
  }

  Future<void> labelUserDevice(dynamic user, String text)async {
    if (text==user.label) {
      // isLoading=false;
      // update();
      showErrorDialog(title: "done",content: "done");
      return;
    }
    isLoading=true;
    update();
    AppResponse response =await UsersApi.labelDevice(
      macAddress: user.macAddress,
      label: text
      // srcAddress: user.srcAddress,
    );
    isLoading=false;
    update();
    if (!response.status) {
      showErrorDialog(content: response.message);return;
    }
    user.label=text;
    update();
    showErrorDialog(title: "done",content: response.message);
  }

  Future<void> labelUserDevice0(HostUserModel user, String text)async {
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
