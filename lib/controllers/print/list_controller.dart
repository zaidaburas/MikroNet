import 'package:get/get.dart';
import 'package:mikronet/views/prints/batches/generated_cards.dart';
import 'package:mikronet/views/prints/templates/pdf_view.dart';
import '/views/helpers/dialogs.dart';
import '/api/print_api.dart';
import '/models/print_model.dart';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// ... (نفس الاستيرادات السابقة)



class BatchesController extends GetxController{

  
  List<PrintBatchesModel> allBatches=[];
  // List<GeneratedCardsModel> generatedCards = [];
  

  

  Future<void> getBatchCards(int id)async{
    try {
      await getAllBatches2();
      var r= allBatches.firstWhere((b)=>b.id==id);
      var cards=List.generate(r.cards.length, (i){
        return GeneratedCardsModel.fromDatabase(r.cards[i]);
      });
      Get.to(GeneratedCardsView(cards));
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> getBatchPreview(int batchId)async{
    try {
      var batch = allBatches.firstWhere((b)=>b.id==batchId);
      var response=await PrintTemplatesApi.getTemplateData(batch.templateId);
      PrintTemplatesModel template=PrintTemplatesModel.fromDatabase(response);
      
      var cards=List.generate(batch.cards.length, (i){
        return GeneratedCardsModel.fromDatabase(batch.cards[i]);
      });
      List usernames=cards.map((c)=>c.username).toList();
      List passwords=cards.map((c)=>c.password).toList();
      Get.to(PdfView(
        usernames: usernames, 
        passwords: passwords, 
        template: template,
        saveFile: false,
      ));
      // showErrorDialog(content: passwords.toString());
      // Get.to(GeneratedCardsView(cards));
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> getAllBatches2()async{
    try {
      List result=await PrintBatchesApi.getAllBatches2();
      // var cards=await PrintBatchesApi.get
      // var cards=List.generate(r.length, (i){
      //   return GeneratedCardsModel.fromDatabase(r[i]);
      // });
      List<PrintBatchesModel> temp=[];
      // print(result[0].toString());
      if (result.isNotEmpty) {
        for (var i in result) {
          temp.add(PrintBatchesModel.fromDatabase(i)); 
        }
        allBatches=temp;
      }
      update();
    } catch (e) {
      showErrorDialog(title: "error in get batches2",content: e.toString());
    }
  }

  
  

  


  @override
  void onInit() {
    super.onInit();
    // getAllBatches();
    getAllBatches2();
  }

  

  


  



  




  
  
  



}






