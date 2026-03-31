import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api/login_model.dart';
// import '/models/mikrotik_model.dart';
import '/services/mikrotik_client.dart';
import '/views/helpers/dialogs.dart';
import '/views/home_page.dart';
// import '/views/test.dart';


class LoginController extends GetxController{
  LoginDataApi loginModel=LoginDataApi();
  // late MikrotikAdapter client;
  List savedLogin=[];

  TextEditingController hostController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  // Future<void> initialData()async{}
  Future<void> addRouterData()async{
    try {
      int r=await LoginDataApi.saveLoginData(
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
    savedLogin=await LoginDataApi.getSavedLoginData();
    update();
  }
  
  Future<void> deleteRouterData(int id)async{
    await LoginDataApi.deleteLoginData(id);
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
      // MikrotikClient 
      MikrotikClient.init(
        address: hostController.text.trim(),
        user: userController.text.trim(),
        password: passwordController.text.trim(),
        port: int.parse(portController.text),
        useSsl: false,
        timeout: 25,
        verbose: true,
      );
      // client = MikrotikAdapter(
      //   address: hostController.text.trim(),
      //   user: userController.text.trim(),
      //   password: passwordController.text.trim(),
      //   port: int.parse(portController.text),
      //   useSsl: false,
      //   timeout: const Duration(seconds: 25),
      //   verbose: true,
      // );
      showLoadingDialog();
      bool loginSuccess =
          await MikrotikClient.login().timeout(const Duration(seconds: 20));
      Get.back();
      if (loginSuccess) {
        Get.to(
          // HomeView()
          // TestBatchesScreen(mikrotikAdapter: client)
          HomePage()
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
    // hostController.text = 'localhost'; 
    userController.text = 'user'; 
    passwordController.text = 'userpass'; 
    portController.text = '8727'; 
    nameController.text = 'Network';
    getSavedLogins();

  }
}



