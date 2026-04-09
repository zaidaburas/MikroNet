import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dialog_helper.dart'; // تأكد من المسار
import '/api/users_api.dart';
import '/models/users_model.dart';
import '/models/response.dart';

class HostsController extends GetxController {
  RxList<HostUserModel> hosts = <HostUserModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHosts();
  }

  // جلب كافة الأجهزة المكتشفة من الراوتر
  Future<void> fetchHosts() async {
    isLoading.value = true;
    try {
      AppResponse<List<HostUserModel>> response = await UsersApi.getAllHosts();
      if (response.status) {
        hosts.assignAll(response.data ?? []);
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      showMsgDialog(message: "خطأ في الاتصال: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- العمليات الأساسية ---

  // 1. تسمية الجهاز (Labeling)
  Future<void> renameDevice(HostUserModel host, String newName) async {
    if (newName.isEmpty) return;
    _showLoading();
    var res = await UsersApi.labelDevice(
      macAddress: host.macAddress,
      label: newName,
      
    );
    _hideLoading();
    if (res.status) fetchHosts();
  }
  Future<void> rename1(HostUserModel user, String newName) async {
    if (newName.isEmpty) return;
    AppResponse<void> res;
    _showLoading();
    if(user.label == "Unknown"){
    res = await UsersApi.labelDevice(
      macAddress: user.macAddress,
      label: newName,
     
    );
    }else{
      var device = await UsersApi.getUserId({
        "mac-address":user.macAddress,
      });
      res = await UsersApi.editDevice(device.data.toString(),label: newName);
    }
    _hideLoading();
    if (res.status) fetchHosts();
  }


  // 2. حظر الجهاز (Blocking)
  Future<void> toggleBlock(HostUserModel host) async {
    bool isBlocked = host.label.toLowerCase().contains("block") || host.type == "unauth";
    _showLoading();
    AppResponse<void> res;
    if (isBlocked && host.id != "Unknown") {
      res = await UsersApi.removeDevice(id: host.id); // إزالة الحظر من IP-Binding
    } else {
      res = await UsersApi.blockDevice(macAddress: host.macAddress, label: "Blocked: ${host.label}");
    }
    _hideLoading();
    if (res.status) fetchHosts();
  }

  // 3. التحويل لوصول مجاني (Bypass)
  Future<void> makeBypass(HostUserModel host) async {
    _showLoading();
    var res = await UsersApi.bypassDevice(macAddress: host.macAddress, label: host.label);
    _hideLoading();
    if (res.status) fetchHosts();
  }

  // ميثودات مساعدة لواجهة المستخدم
  void _showLoading() => Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
  void _hideLoading() { if (Get.isDialogOpen ?? false) Get.back(); }
}