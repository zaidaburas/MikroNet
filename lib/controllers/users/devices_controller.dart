import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dialog_helper.dart';
import '/api/users_api.dart';
import '/models/users_model.dart';
import '/models/response.dart';

class DevicesController extends GetxController {
  RxString filter = "ALL".obs;
  
  RxList<SavedUserModel> allDevices = <SavedUserModel>[].obs;
  RxList<SavedUserModel> filteredDevices = <SavedUserModel>[].obs;

  RxBool isLoading = true.obs;
  int _requestCounter = 0;

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
  }

  void goBack() {
    Get.back();
  }

  void setFilter(String key) {
    filter.value = key;
    _applyFilter();
  }

  void _applyFilter() {
    if (filter.value == "ALL") {
      filteredDevices.assignAll(allDevices);
    } else if (filter.value == "SAVED") {
      filteredDevices.assignAll(allDevices.where((d) => d.type == "regular" || d.type == "normal").toList());
    } else if (filter.value == "BLOCKED") {
      filteredDevices.assignAll(allDevices.where((d) => d.type == "blocked").toList());
    } else if (filter.value == "FREE") {
      filteredDevices.assignAll(allDevices.where((d) => d.type == "bypassed").toList());
    }
  }

  /// تأكيد تعديل المسمى
  void confirmRename(SavedUserModel device, String newName) {
    if (newName.isEmpty || newName == device.label) return;
    
    showConfirmDialog(
      message: "هل أنت متأكد من رغبتك في تغيير مسمى الجهاز إلى '$newName'؟",
      onConfirm: () {
        _executeRename(device, newName);
      },
    );
  }

  /// تأكيد الحظر
  void confirmBlock(SavedUserModel device) {
    showConfirmDialog(
      message: "هل أنت متأكد من حظر هذا الجهاز؟ لن يتمكن من الوصول للشبكة.",
      onConfirm: () {
        _executeAction(device, type: "blocked", msg: "تم حظر الجهاز بنجاح");
      },
    );
  }

  /// تأكيد فك الحظر
  void confirmUnblock(SavedUserModel device) {
    showConfirmDialog(
      message: "هل تريد فك الحظر عن هذا الجهاز والسماح له بالاتصال مجدداً؟",
      onConfirm: () {
        _executeAction(device, type: "regular", msg: "تم فك الحظر عن الجهاز");
      },
    );
  }

  /// تأكيد تحويل لمجاني
  void confirmMakeFree(SavedUserModel device) {
    showConfirmDialog(
      message: "هل أنت متأكد من منح هذا الجهاز وصولاً مجانياً للشبكة؟",
      onConfirm: () {
        _executeAction(device, type: "bypassed", msg: "تم تحويل الجهاز إلى مجاني");
      },
    );
  }

  /// تأكيد الحذف
  void confirmDelete(SavedUserModel device) {
    showConfirmDialog(
      message: "هل أنت متأكد من حذف هذا الجهاز من النظام نهائياً؟",
      onConfirm: () {
        _executeDelete(device);
      },
    );
  }

  /// إضافة جهاز يدوياً
  Future<void> addManualDevice({required String name, required String ip, required String mac, required String status}) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xff1E3C72))), barrierDismissible: false);
    
    String type = "regular";
    if(status == "FREE") type = "bypassed";
    if(status == "BLOCKED") type = "blocked";

    AppResponse<void> response;
    if(type == "blocked") {
      response = await UsersApi.blockDevice(macAddress: mac, srcAddress: ip, label: name);
    } else if (type == "bypassed") {
      response = await UsersApi.bypassDevice(macAddress: mac, srcAddress: ip, label: name);
    } else {
      response = await UsersApi.labelDevice(macAddress: mac, srcAddress: ip, label: name);
    }

    if (Get.isDialogOpen ?? false) Get.back();

    if (response.status) {
      fetchDevices(); 
      _showSuccess("تم بنجاح", "تمت إضافة الجهاز الجديد");
    } else {
      showMsgDialog(message: response.message);
    }
  }

  /// جلب البيانات
  Future<void> fetchDevices() async {
    final currentId = ++_requestCounter;
    isLoading.value = true;
    
    try {
      AppResponse<List<SavedUserModel>> response = await UsersApi.getAlISavedUsers();
      
      if (currentId != _requestCounter) return;

      if (response.status && response.data != null) {
        allDevices.assignAll(response.data!);
        _applyFilter();
      } else {
        showMsgDialog(message: response.message);
      }
    } catch (e) {
      if (currentId == _requestCounter) {
        showMsgDialog(message: "Error fetching devices: $e");
      }
    } finally {
      if (currentId == _requestCounter) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _executeRename(SavedUserModel device, String newName) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xff1E3C72))), barrierDismissible: false);
    
    AppResponse<void> response = await UsersApi.editDevice(device.id, label: newName);
    
    if (Get.isDialogOpen ?? false) Get.back();

    if (response.status) {
      int index = allDevices.indexWhere((e) => e.id == device.id);
      if (index != -1) {
        allDevices[index] = SavedUserModel(
          id: device.id, srcAddress: device.srcAddress, dstAddress: device.dstAddress,
          macAddress: device.macAddress, server: device.server, type: device.type, label: newName
        );
      }
      allDevices.refresh();
      _applyFilter();
      _showSuccess("تم بنجاح", "تم تغيير مسمى الجهاز");
    } else {
      showMsgDialog(message: response.message);
    }
  }

  Future<void> _executeAction(SavedUserModel device, {required String type, required String msg}) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xff1E3C72))), barrierDismissible: false);
    
    AppResponse<void> response = await UsersApi.editDevice(device.id, type: type);
    
    if (Get.isDialogOpen ?? false) Get.back();

    if (response.status) {
      int index = allDevices.indexWhere((e) => e.id == device.id);
      if (index != -1) {
        allDevices[index] = SavedUserModel(
          id: device.id, srcAddress: device.srcAddress, dstAddress: device.dstAddress,
          macAddress: device.macAddress, server: device.server, type: type, label: device.label
        );
      }
      allDevices.refresh();
      _applyFilter();
      _showSuccess("تمت العملية", msg);
    } else {
      showMsgDialog(message: response.message);
    }
  }

  Future<void> _executeDelete(SavedUserModel device) async {
    Get.dialog(const Center(child: CircularProgressIndicator(color: Colors.redAccent)), barrierDismissible: false);
    
    AppResponse<void> response = await UsersApi.removeDevice(id: device.id);
    
    if (Get.isDialogOpen ?? false) Get.back();

    if (response.status) {
      allDevices.removeWhere((e) => e.id == device.id);
      _applyFilter();
      _showSuccess("تم الحذف", "تم حذف الجهاز من النظام");
    } else {
      showMsgDialog(message: response.message);
    }
  }

  void _showSuccess(String title, String msg) {
    showMsgDialog(message: msg);
  }
}