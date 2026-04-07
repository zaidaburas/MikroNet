
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/api/print_api.dart';
import 'package:mikronet/api/profiles_api.dart';
import 'package:mikronet/controllers/helpers/functions.dart';
import 'package:mikronet/models/print_model.dart';
import 'package:mikronet/models/profiles_model.dart';
import 'package:mikronet/models/response.dart';
// import 'package:mikronet/services/response.dart';
import 'package:mikronet/views/helpers/dialogs.dart';
import 'package:mikronet/views/prints/batches/generated_cards.dart';
import 'package:mikronet/views/prints/templates/pdf_view.dart';

class BatchesFormController extends GetxController{
  List<Map<String, dynamic>> passwordTypes=[
    {"id": "none", "label": "بدون \n", "icon": Icons.minimize_outlined},
    {"id": "diff", "label": "ارقام مختلفة \n", "icon": Icons.pin_outlined},
    {"id": "same", "label": "مطابقة اسم المستخدم", "icon": Icons.abc_rounded},
  ];
  Map dataInsert={};
  List<PrintTemplatesModel> allTemplates=[];
  List<ProfilesModel> allProfiles=[];
  List<String> generatedUsernames=[];
  List<String> generatedPasswords=[];
  List<GeneratedCardsModel> generatedCards = [];


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
      AppResponse<List<ProfilesModel>> result=await ProfilesApi.getProfiles();
      allProfiles=result.data??[];
      // List<ProfilesModel> temp=[];
      // if (result.status && result.data !=null ) {
      //   for (var i in result.data) {
      //     temp.add(ProfilesModel.fromMikrotik(i));
      //   }
      //   allProfiles=temp;
      // }
      update();
    } catch (e) {
      showErrorDialog(content: "Get Profiles Error : ${e.toString()}");
    }
  }

  Future<void> generateCards()async{
    var profile=allProfiles.firstWhere((p)=>p.id==selectedProfile.value);
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
    generatedCards=List.generate(
      generatedUsernames.length, 
      (i){
        return GeneratedCardsModel(
          id: 0, 
          username: generatedUsernames[i], 
          batchId: 0, 
          password: generatedPasswords[i], 
          profileName: profile.name, 
          isAdd: false
        );
      }
    );
  }

  Future<void> addBatch2()async{
    try {
      List<Map<String, dynamic>> cards=generatedCards.map((c)=>c.toDatabase()).toList();
      Map<String, dynamic> data={
        'name':batchName.text.trim(),
        'created_at':dateTime.microsecondsSinceEpoch ,
        'template_id':selectedTemplate.value,
        'generated_cards':'cards',
        'cards_profile':selectedProfile.value,
        'card_prefix':prefix.text.trim(),
        'card_suffix':suffix.text.trim(),
      };
      var response=await PrintBatchesApi.addOneBatch(data);
      if(response>0){
        // response =await PrintBatchesApi.addBatchCards(cards, response);
      }
      if (response>0) {
        showSuccessDialog();
      }
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> handlePreview()async{
    try {
      validation();
    } catch (e) {
      showErrorDialog(content: e.toString());
      return;
    }

    PrintTemplatesModel template=allTemplates.firstWhere(
      (t)=>t.id==selectedTemplate.value
    );
    if(!template.withPassword && selectedPasswordType=="same"){
      bool confirm=await showConfirmDialog(
        content: "القالب بدون كلمة مرور ونمط توليد كلمة المرور مشابه لاسم المستخدم هل انت متاكد ",
      );
      if(!confirm){return;}
    }
    preview();
  }
  
  Future<void> handleGenerate()async{
    try {
      validation();
    } catch (e) {
      showErrorDialog(content: e.toString());
      return;
    }

    PrintTemplatesModel template=allTemplates.firstWhere(
      (t)=>t.id==selectedTemplate.value
    );
    // var profile=allProfiles.firstWhere((p)=>p.id==selectedProfile.value);
    if(!template.withPassword && selectedPasswordType=="same"){
      bool confirm=await showConfirmDialog(
        content: "القالب بدون كلمة مرور ونمط توليد كلمة المرور مشابه لاسم المستخدم هل انت متاكد ",
      );
      if(!confirm){return;}
    }
    generateCards();
    // List<Map<String, dynamic>> generatedCards=List.generate(
    //   generatedUsernames.length, 
    //   (i)=>{'username': generatedUsernames[i], 'password': generatedPasswords[i], 'profile': profile.name, 'isAdded': true},
    // );
    await addBatch2();
    Get.off( GeneratedCardsView(generatedCards));
  }
  
  void preview(){
    PrintTemplatesModel template=allTemplates.firstWhere(
      (t)=>t.id==selectedTemplate.value
    );
    generateCards();
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
      throw "please select template";
    }
    if(selectedProfile.value==""){throw "please select profile";}

    if(batchName.text.trim().isEmpty ||
    numOfCards.text.trim().isEmpty ||
    usernameLength.text.trim().isEmpty){
      throw "fill all fields";
    }
    var template=allTemplates.firstWhere((t)=>t.id==selectedTemplate.value);
    if(template.withPassword){
      switch (selectedPasswordType) {
        case "none":
          throw "القالب مع كلمة مرور ونمط توليد كلمة المرور بلا ";
        case "same":
          throw "القالب مع كلمة مرور ونمط توليد كلمة المرور مشابه لاسم المستخدم ";
        default:
        if(passwordLength.text.trim().isEmpty){
          throw "ادخل طول كلمة المرور ";
        }
      }
    }else{
      switch (selectedPasswordType) {
        // case "same":
        //   throw "";
        case "diff":
          throw "لايمكن ان يكون نمط كلمة المرور مختلف بينما القالب بدون كلمة مرور";
        default:
      }
    }
    
  }




  void init(){
    usernameLength.text="7";
    passwordLength.text="5";
    update();
    // selectedTemplate=allTemplates.isEmpty?0.obs:allTemplates[0].id.obs;
    // selectedProfile=allProfiles.isEmpty?"".obs:allProfiles[0].name.obs;
  }

  
  @override
  void onInit() {
    super.onInit();
    init();
    // getAllBatches();
    // getAllBatches2();
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

}


void showSuccessDialog() {
  Get.dialog(
    // context: context,
    // barrierDismissible: false,
    // builder: (ctx) => 
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.green, size: 70),
          const SizedBox(height: 15),
          const Text("عملية ناجحة",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const Text("تم إنشاء الدفعة. هل تطبعها الآن؟",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 25),
          Row(children: [
            Expanded(
                child: TextButton(
                    onPressed: () {
                      Get.back();
                      // Navigator.pop(ctx);
                      // Navigator.pop(context);
                    },
                    child: const Text("لاحقاً"))),
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      // Navigator.pop(ctx);
                      // controller
                      //     .printBatchToPdf(nameCtrl.text, selectedTemplate);
                      // Navigator.pop(context);
                    },
                    child: const Text("طباعة PDF"))),
          ])
        ],
      ),
    ),
  );
}


