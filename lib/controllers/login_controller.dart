import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/models/login_model.dart';
import 'package:mikronet/models/mikrotik_model.dart';
import 'package:mikronet/views/helpers/dialogs.dart';
import 'package:mikronet/views/home_page.dart';


class LoginController extends GetxController{
  LoginDataModel loginModel=LoginDataModel();
  late MikrotikAdapter client;
  List savedLogin=[];

  TextEditingController hostController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  // Future<void> initialData()async{}
  Future<void> addRouterData()async{
    try {
      int r=await loginModel.saveLoginData(
        {
          "host":hostController.text,
          'name': nameController.text,
          'username': userController.text,
          'password': passwordController.text,
          'port': portController.text.toString(),
        }
      );
      if(r>0)showErrorDialog(title: "Done",content: "done",titleColor: Colors.green);
      // getSavedLogins();
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }
  
  Future<void> getSavedLogins()async{
    savedLogin=await loginModel.getSavedLoginData();
    update();
  }
  
  Future<void> deleteRouterData(int id)async{
    await loginModel.deleteLoginData(id);
    getSavedLogins();
  }


  bool emptyFields(){
    if(!(
      hostController.text.isNotEmpty &&
      userController.text.isNotEmpty &&
      passwordController.text.isNotEmpty &&
      portController.text.isNotEmpty
    )){
      return true;
    }
    return false;
  }

  void fillInputFields(int loop){
    hostController.text =
        savedLogin[loop]['host'];
    userController.text =
        savedLogin[loop]['username'];
    passwordController.text =
        savedLogin[loop]['password'];
    portController.text =
        savedLogin[loop]['port'].toString();
    nameController.text = savedLogin[loop]['name'];
    update();
  }

  Future<void> connectToRouter()async{
    if(emptyFields()){
      showErrorDialog(content: 'fill_all_fields');
      return;
    }

    try {
      client = MikrotikAdapter(
        address: hostController.text.trim(),
        user: userController.text.trim(),
        password: passwordController.text.trim(),
        port: int.parse(portController.text),
        useSsl: false,
        timeout: const Duration(seconds: 25),
        verbose: true,
      );
      showLoadingDialog();
      bool loginSuccess =
          await client.login().timeout(const Duration(seconds: 20));
      Get.back();
      if (loginSuccess) {
        Get.to(
          // HomeView()
          HomePage(mikrotik: client)
        );
      } 
      else {
        showErrorDialog(title: "Error",content: "login feild");
      }
    } catch (e) {
      showErrorDialog(title: "Error",content: "حدث خطأ أثناء عملية الدخول : \n ${e.toString()}");
    }
    
  }

  @override
  void onInit() {
    super.onInit();
    hostController.text = '1.1.1.1'; 
    userController.text = 'user'; 
    passwordController.text = 'userpass'; 
    portController.text = '8727'; 
    nameController.text = 'Network';
    getSavedLogins();

  }
}



