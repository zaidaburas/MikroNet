
import 'dart:convert';
import 'dart:typed_data';

import 'package:mikronet/api/print_api.dart';

class PrintTemplatesModel {
  final int id;
  final String name;
  final String passwordType;
  final Uint8List imageData;
  final double rows;
  final double columns;
  final double usernameLength;
  final double passwordLength;
  final double fontsize;
  final String usernamePattern;
  final String passwordPattern;
  final Map usernameLocation;
  final Map passwordLocation;

  PrintTemplatesModel({
    required this.id,
    required this.name,
    required this.passwordType,
    required this.imageData,
    required this.rows,
    required this.columns,
    required this.usernameLength,
    required this.passwordLength,
    required this.fontsize,
    required this.usernamePattern,
    required this.passwordPattern,
    required this.usernameLocation,
    required this.passwordLocation,
  });

  static PrintTemplatesModel fromDatabase(Map data){
    return PrintTemplatesModel(
      id: data["id"], 
      name: data["name"], 
      passwordType: data["password_type"], 
      imageData: base64Decode(data["image"]), 
      rows: data["rows"], 
      columns: data["columns"], 
      usernameLength: data["username_length"], 
      passwordLength: data["password_length"], 
      fontsize: data["fontsize"], 
      usernamePattern:data["username_pattern"] , 
      passwordPattern: data["password_pattern"], 
      usernameLocation: {
        "x": data["username_location_x"] ,
        "y": data["username_location_y"] ,
      }, 
      passwordLocation: {
        "x": data["password_location_x"] ,
        "y": data["password_location_y"] ,
      }, 
    );
  }

  Map<String, dynamic> toDatabase(){
    return {
      "name": name, 
      "password_type": passwordType, 
      "image": base64Encode(imageData), 
      "rows": rows, 
      "columns": columns, 
      "username_length": usernameLength , 
      "password_length": passwordLength, 
      "fontsize": fontsize, 
      "username_pattern":usernamePattern , 
      "password_pattern": passwordPattern, 
      "username_location_x":usernameLocation["x"],
      "username_location_y":usernameLocation["y"],
      "password_location_x":passwordLocation["x"],
      "password_location_y":passwordLocation["y"],
    };
  }
 

}







class PrintBatchesModel {
  final int id;
  final String name;
  final String createdAt;
  final PrintTemplatesModel? template;
  final String generatedCards;
  final String cardsType;
  final String cardPrefix;
  final String cardSuffix;

  PrintBatchesModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.template,
    required this.generatedCards,
    required this.cardsType,
    required this.cardPrefix,
    required this.cardSuffix,
  });

  static Future<PrintBatchesModel> fromDatabase(Map data)async{
    PrintTemplatesModel? model;
    // PrintTemplatesApi api=PrintTemplatesApi();
    Map templateData=await PrintTemplatesApi.getTemplateData(data["template_id"]);
    model=templateData.isEmpty? null : PrintTemplatesModel.fromDatabase(templateData);
    return PrintBatchesModel(
      id: data["id"], 
      name: data["name"], 
      createdAt: data["created_at"], 
      template: model, 
      generatedCards: data["generated_cards"], 
      cardsType: data["cards_type"], 
      cardPrefix: data["card_prefix"], 
      cardSuffix: data["card_suffix"], 
    );
  }

  Map toDatabase(){
    String templateId="unknown";
    if(template!=null)templateId=template!.id.toString();
    return {
      "name": name, 
      "created_at": createdAt, 
      "template_id": templateId, 
      "generated_cards": generatedCards, 
      "cards_type": cardsType, 
      "card_prefix": cardPrefix , 
      "card_suffix": cardSuffix, 
    };
  }
 

}




