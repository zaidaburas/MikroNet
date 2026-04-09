import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dialog_helper.dart'; 
import '/api/users_api.dart';
import '/models/users_model.dart';
import '/models/response.dart';

class ActiveSessionsController extends GetxController {
  RxList<ActiveUserModel> actives = <ActiveUserModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveSessions();
  }

  // جلب البيانات من السيرفر
  Future<void> fetchActiveSessions() async {
    isLoading.value = true;
    try {
      AppResponse<List<ActiveUserModel>> response = await UsersApi.getAllActive();
      if (response.status) {
        actives.assignAll(response.data ?? []);
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      showMsgDialog(message: "خطأ في الاتصال: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /* ---------------- الاجراءات والعمليات ---------------- */

  Future<void> disconnect(ActiveUserModel user) async {
    _showLoading();
    var res = await UsersApi.removeOneActive(user.username);
    _hideLoading();
    if (res.status) fetchActiveSessions();
  }

  Future<void> rename(ActiveUserModel user, String newName) async {
    if (newName.isEmpty) return;
    AppResponse<void> res;
    _showLoading();
    res = await UsersApi.labelDevice(
      macAddress: user.macAddress,
      label: newName,
    );
    /*if(user.label == "Unknown"){
    }else{
    var map = {
        "mac-address":user.macAddress,
        "comment": user.label
      };
      var device = await UsersApi.getUserId({
        "mac-address":user.macAddress,
        "comment": user.label
      });
      //showMsgDialog(message: map.toString());
      res = await UsersApi.editDevice(device.data.toString(),label: newName);
      
    }
    */
    _hideLoading();
    if (res.status) fetchActiveSessions();
  }

  Future<void> block(ActiveUserModel user) async {
    _showLoading();
    var res = await UsersApi.blockDevice(
      macAddress: user.macAddress,
      label: "Blocked: ${user.username}",
    );
    _hideLoading();
    if (res.status) {
      await UsersApi.removeOneActive(user.username);
      fetchActiveSessions();
    }
  }

  Future<void> makeFree(ActiveUserModel user) async {
    _showLoading();
    var res = await UsersApi.bypassDevice(
      macAddress: user.macAddress,
      label: "Free: ${user.username}",
    );
    _hideLoading();
    if (res.status) fetchActiveSessions();
  }

  void _showLoading() => Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
  void _hideLoading() { if (Get.isDialogOpen ?? false) Get.back(); }
}