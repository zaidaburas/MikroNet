import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/api/profiles_api.dart';
import 'package:mikronet/controllers/helpers/functions.dart';
import 'package:mikronet/models/profiles_model.dart';
import 'package:mikronet/models/response.dart';
import 'package:mikronet/views/prints/templates/pdf_view.dart';
import '/views/helpers/dialogs.dart';
import '/api/print_api.dart';
import '/models/print_model.dart';

class BatchesController extends GetxController{
  List<Map<String, dynamic>> passwordTypes=[
    {"id": "none", "label": "بدون", "icon": Icons.minimize_outlined},
    {"id": "diff", "label": "ارقام مختلفة", "icon": Icons.pin_outlined},
    {"id": "same", "label": "مطابقة اسم المستخدم", "icon": Icons.abc_rounded},
  ];
  Map dataInsert={};
  List<PrintBatchesModel> allBatches=[];
  List<PrintTemplatesModel> allTemplates=[];
  List<ProfilesModel> allProfiles=[];
  List<String> generatedUsernames=[];
  List<String> generatedPasswords=[];

  



  Future<void> getAllBatches()async{
    try {
      List result=await PrintBatchesApi.getAllBatches();
      List<PrintBatchesModel> temp=[];
      if (result.isNotEmpty) {
        for (var i in result) {
          temp.add(PrintBatchesModel.fromDatabase(i));
        }
        allBatches=temp;
      }
      update();
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }


  Future<void> getAllTemplates()async{
    try {
      List result=await PrintTemplatesApi.getAllTemplates();
      List<PrintTemplatesModel> temp=[];
      if (result.isNotEmpty) {
        for (var i in result) {
          temp.add(PrintTemplatesModel.fromDatabase(i));
        }
        allTemplates=temp;
      }
      update();
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }


  Future<void> getallProfiles()async{
    try {
      AppResponse result=await ProfilesApi.getProfiles();
      List<ProfilesModel> temp=[];
      if (result.status && result.data !=null ) {
        for (var i in result.data) {
          temp.add(ProfilesModel.fromMikrotik(i));
        }
        allProfiles=temp;
      }
      update();
    } catch (e) {
      showErrorDialog(content: "Get Profiles Error : ${e.toString()}");
    }
  }

  Future<void> generateCards()async{}

  Future<void> addBatch()async{
    try {
      // k
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }



  @override
  void onInit() {
    super.onInit();
    init();
    getAllBatches();
    getAllTemplates();
    getallProfiles();
  }

  @override
  void update([List<Object>? ids, bool condition = true]) {
    dataInsert={
      "name":batchName.text,
      "total":numOfCards.text,
      "profile":selectedProfile.value,
      "template_id":selectedTemplate.value,
      "password_type":selectedPasswordType ,
      "card_prefix":prefix.text,
      "card_suffix":suffix.text ,
      "username_length":usernameLength.text ,
      "password_length":passwordLength.text ,
    };
    dataInsert["profile"]=selectedProfile.value;
    super.update(ids, condition);
  }

  void init(){
    usernameLength.text="7";
    passwordLength.text="5";
    update();
    // selectedTemplate=allTemplates.isEmpty?0.obs:allTemplates[0].id.obs;
    // selectedProfile=allProfiles.isEmpty?"".obs:allProfiles[0].name.obs;
  }


  // Form Variables

  TextEditingController batchName=TextEditingController();
  TextEditingController numOfCards=TextEditingController();
  TextEditingController prefix=TextEditingController();
  TextEditingController suffix=TextEditingController();
  TextEditingController usernameLength=TextEditingController();
  TextEditingController passwordLength=TextEditingController();
  RxInt selectedTemplate=0.obs;
  RxString selectedProfile="".obs;
  String selectedPasswordType="none";
  DateTime dateTime=DateTime.now();




  void preview(){
    PrintTemplatesModel template=allTemplates.firstWhere(
      (t)=>t.id==selectedTemplate.value
    );
    generatedUsernames=generateUniqueRandomStrings(
        count: int.parse(numOfCards.text.trim()),
        length: int.parse(usernameLength.text),
        prefix: prefix.text,
        suffix: suffix.text
      );
    if(dataInsert["password_type"]=="diff"){
      generatedPasswords=generateUniqueRandomStrings(
        count: int.parse(numOfCards.text.trim()),
        length: int.tryParse(passwordLength.text)??5,
      );
    }
    else if(dataInsert["password_type"]=="same"){
      generatedPasswords=generatedUsernames;
    }
    else{
      generatedPasswords=List.generate(int.parse(numOfCards.text), (i)=>"");
    }
    Get.to(
      PdfView(
        usernames: generatedUsernames,
        passwords: generatedPasswords, 
        template: template,
        saveFile: false,
      )
    );
  }

  void validation(){
    if(selectedTemplate.value==0){
      showErrorDialog(content: "please select profile");
      return;
    }
    // var template
    if(batchName.text.trim().isEmpty ||
    numOfCards.text.trim().isEmpty ||
    usernameLength.text.trim().isEmpty){
      showErrorDialog(content: "fill all fields");
    }
  }







}