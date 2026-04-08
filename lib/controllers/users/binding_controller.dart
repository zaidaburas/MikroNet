import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/api/users_api.dart';
import 'package:mikronet/models/users_model.dart';
import 'package:mikronet/services/mikrotik_client.dart';
import 'package:mikronet/models/response.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

class DevicesController extends GetxController{
  final nameCtrl = TextEditingController();
  final ipCtrl = TextEditingController();
  final macCtrl = TextEditingController();
  String selectedStatus = "regular";


  List<DevicesModel> _devices=[];
  bool isLoading=false;
  String _filter = "ALL";
  String get filter => _filter;
  List servers=["all"];
  String selectedServer="all";

  Future<void> initial()async{
    await getAll();
    await getServers();
  }

  Future<void> getServers() async{
    List s=await MikrotikClient.printData(commands: ["/ip/hotspot/print","?disabled=no"]);
    List serversNames=s.map((e)=>e["name"]).toList();
    servers.addAll(serversNames);
  }

  Future<void> getAll() async {
    isLoading=true;
    update();
    AppResponse<List<SavedUserModel>> response = await UsersApi.getAlISavedUsers();
    
    if (!response.status) {
      showErrorDialog(content: response.message);
      isLoading=false;
      update();
      return; // إيقاف التنفيذ في حال الخطأ
    }
    
    List<DevicesModel> result = [];
    // for (var i in response.data) {
    //  // result.add(DevicesModel.fromMikrotik(i));
    // }
    //_devices = response.data;
    isLoading=false;
    update();
  }

  void setFilter(String value) {
    _filter = value;
    update();
  }

  List<DevicesModel> get filteredDevices {
    if (_filter == "BLOCKED") {
      return _devices.where((d) => d.type.isBlocked).toList();
    }

    if (_filter == "FREE") {
      return _devices.where((d) => d.type.isFree).toList();
    }

    if (_filter == "SAVED") {
      return _devices.where((d) => d.label!="Unknown").toList();
    }

    if (_filter == "UNSAVED") {
      return _devices.where((d) => d.label=="Unknown").toList();
    }

    if (_filter == "NORMAL") {
      return _devices.where((d) => d.type.isNormal).toList();
    }

    return _devices;
  }

  @override
  void onInit() {
    initial();
    super.onInit();
    // initial();
  }

  /* ================= إضافة جهاز يدوي ================= */

  Future<void> addManualDevice()async {

    if (macCtrl.text.trim().isEmpty) return;

    bool exists =_devices.any((d) => d.macAddress.toLowerCase() == macCtrl.text.toLowerCase());

    if (exists) return;

    isLoading=true;
    update();

    AppResponse response=(await UsersApi.saveDevice(
      macAddress: macCtrl.text.trim(),
      srcAddress: ipCtrl.text.trim(),
      label: nameCtrl.text.trim(),
      server: selectedServer,
      type: selectedStatus
    )) as AppResponse;

    isLoading=false;
    if (!response.status) {
      showErrorDialog(content: response.message);
      return;
    }

    getAll();

    // update();
  }

  Future<void> rename(DevicesModel d, String newName)async {
    isLoading=true;
    update();
    AppResponse r=(await UsersApi.editDevice(d.id,label:newName.trim())) as AppResponse;
    if (!r.status) {
      showErrorDialog(content: r.message);
      return;
    }
    isLoading=false;
    d.label=newName.trim();
    // getAll();
    update();
  }

  Future<void> block(DevicesModel d)async {
    if (d.type.isBlocked) {
      showErrorDialog(content: "already blocked");
      return;
    }
    isLoading=true;
    update();
    AppResponse r=(await UsersApi.editDevice(d.id, type: "blocked")) as AppResponse;
    if (!r.status) {
      showErrorDialog(content: r.message);
      return;
    }
    isLoading=false;
    d.type.isBlocked=true;
    d.type.isNormal=false;
    d.type.isFree=false;
    update();
  }

  Future<void> unblock(DevicesModel d)async {
    if (!d.type.isBlocked) {showErrorDialog(content: "already Unblocked");
      return;
    }
    isLoading=true;
    update();
    AppResponse r=(await UsersApi.editDevice(d.id, type:"regular")) as AppResponse;
    if (!r.status) {
      showErrorDialog(content: r.message);
      return;
    }
    isLoading=false;
    d.type.isBlocked=false;
    d.type.isNormal=true;
    d.type.isFree=false;
    update();
  }

  Future<void> makeFree(DevicesModel d)async {
    if (d.type.isFree) {
      showErrorDialog(content: "already Free");
      return;
    }
    isLoading=true;
    update();
    AppResponse r=(await UsersApi.editDevice(d.id, type:"bypassed")) as AppResponse;
    if (!r.status) {
      showErrorDialog(content: r.message);
      return;
    }
    isLoading=false;
    d.type.isBlocked=false;
    d.type.isNormal=false;
    d.type.isFree=true;
    update();
    // getAll();
  }

  Future<void> delete(DevicesModel d)async {
    isLoading=true;
    update();
    AppResponse r=(await UsersApi.removeDevice(id: d.id)) as AppResponse;
    if (!r.status) {
      showErrorDialog(content: r.message);
      return;
    }
    isLoading=false;
    _devices.remove(d);
    update();
    // getAll();
  }

  
}