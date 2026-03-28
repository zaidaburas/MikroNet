
import 'dart:convert';
import 'dart:typed_data';

import '/api/print_api.dart';
import 'package:flutter/services.dart';

class LocationData{
  final double x;
  final double y;
  LocationData({
    required this.x,
    required this.y,
  });
}


  String templates="""
    CREATE TABLE templates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      password INTEGER,
      serial INTEGER DEFAULT 0,
      image BLOB NOT NULL,
      rows INTEGER,
      columns INTEGER,
      username_fontsize REAL,
      password_fontsize REAL,
      username_location_x REAL,
      username_location_y REAL,
      password_location_x REAL,
      password_location_y REAL
    );
  """;
class PrintTemplatesModel {
  final int id;
  final String name;
  final Uint8List image;
  final bool withPassword;
  final int numOfRows;
  final int numOfColumns;
  final double usernameFontSize;
  final double passwordFontSize;
  final LocationData usernameLocation;
  final LocationData passwordLocation;

  PrintTemplatesModel({
    required this.id,
    required this.name,
    required this.image,
    required this.withPassword,
    required this.numOfRows,
    required this.numOfColumns,
    required this.usernameFontSize,
    required this.passwordFontSize,
    required this.usernameLocation,
    required this.passwordLocation,
  });

  static PrintTemplatesModel fromDataForm(Map data){
    // Uint8List image=data["image"]??await getDefaultImage();
    return PrintTemplatesModel(
      id: data["id"], 
      name: data["name"], 
      image: data["image"] ,
      withPassword: (data["password"]==1), 
      numOfRows: data["rows"], 
      numOfColumns: data["columns"], 
      usernameFontSize: data["username_fontsize"], 
      passwordFontSize: data["password_fontsize"], 
      usernameLocation: LocationData(
        x: data["username_location_x"], 
        y: data["username_location_y"]
      ),
      // {
      //   "x":data["usernamelocationx"],
      //   "y":data["usernamelocationy"],
      // }, 
      passwordLocation: LocationData(
        x: data["password_location_x"], 
        y: data["password_location_y"]
      ),
      // {
      //   "x":data["passwordlocationx"],
      //   "y":data["passwordlocationy"],
      // },
    );

    
  }

  static PrintTemplatesModel fromDatabase(Map data){
    Uint8List img=base64Decode(data["image"] as String);
    return PrintTemplatesModel(
      id: data["id"], 
      name: data["name"], 
      image: img ,
      withPassword: (data["password"]==1), 
      numOfRows: data["rows"], 
      numOfColumns: data["columns"], 
      usernameFontSize: data["username_fontsize"], 
      passwordFontSize: data["password_fontsize"], 
      usernameLocation: LocationData(
        x: data["username_location_x"], 
        y: data["username_location_y"]
      ),
      // {
      //   "x":data["usernamelocationx"],
      //   "y":data["usernamelocationy"],
      // }, 
      passwordLocation: LocationData(
        x: data["password_location_x"], 
        y: data["password_location_y"]
      ),
      // {
      //   "x":data["passwordlocationx"],
      //   "y":data["passwordlocationy"],
      // },
    );

    
  }


  Map<String, dynamic> toDatabase(){
    String base64Image = base64Encode(image); 
    return {
      "name": name, 
      "password": withPassword?1:0, 
      "image": base64Image, 
      "rows": numOfRows, 
      "columns": numOfColumns, 
      "username_fontsize": usernameFontSize , 
      "password_fontsize": passwordFontSize, 
      "username_location_x":usernameLocation.x,
      "username_location_y":usernameLocation.y,
      "password_location_x":passwordLocation.x,
      "password_location_y":passwordLocation.y,
    };
  }


  Future<Uint8List> fetchImage(String img) async {
    return base64Decode(img);
  }


  
}

// class PrintTemplatesModel {

//   final int id;
//   final String name;
//   final String passwordType;
//   final Uint8List imageData;
//   final double rows;
//   final double columns;
//   final double usernameLength;
//   final double passwordLength;
//   final double fontsize;
//   final String usernamePattern;
//   final String passwordPattern;
//   final Map usernameLocation;
//   final Map passwordLocation;

//   PrintTemplatesModel({
//     required this.id,
//     required this.name,
//     required this.passwordType,
//     required this.imageData,
//     required this.rows,
//     required this.columns,
//     required this.usernameLength,
//     required this.passwordLength,
//     required this.fontsize,
//     required this.usernamePattern,
//     required this.passwordPattern,
//     required this.usernameLocation,
//     required this.passwordLocation,
//   });

//   static PrintTemplatesModel fromDatabase(Map data){
//     return PrintTemplatesModel(
//       id: data["id"], 
//       name: data["name"], 
//       passwordType: data["password_type"], 
//       imageData: base64Decode(data["image"]), 
//       rows: data["rows"], 
//       columns: data["columns"], 
//       usernameLength: data["username_length"], 
//       passwordLength: data["password_length"], 
//       fontsize: data["fontsize"], 
//       usernamePattern:data["username_pattern"] , 
//       passwordPattern: data["password_pattern"], 
//       usernameLocation: {
//         "x": data["username_location_x"] ,
//         "y": data["username_location_y"] ,
//       }, 
//       passwordLocation: {
//         "x": data["password_location_x"] ,
//         "y": data["password_location_y"] ,
//       }, 
//     );
//   }

//   Map<String, dynamic> toDatabase(){
//     return {
//       "name": name, 
//       "password_type": passwordType, 
//       "image": base64Encode(imageData), 
//       "rows": rows, 
//       "columns": columns, 
//       "username_length": usernameLength , 
//       "password_length": passwordLength, 
//       "fontsize": fontsize, 
//       "username_pattern":usernamePattern , 
//       "password_pattern": passwordPattern, 
//       "username_location_x":usernameLocation["x"],
//       "username_location_y":usernameLocation["y"],
//       "password_location_x":passwordLocation["x"],
//       "password_location_y":passwordLocation["y"],
//     };
//   }
 
// }







class PrintBatchesModel {
  final int id;
  final String name;
  final String createdAt;
  final PrintTemplatesModel? template;
  final String generatedCards;
  final String cardsProfile;
  final String cardPrefix;
  final String cardSuffix;

  PrintBatchesModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.template,
    required this.generatedCards,
    required this.cardsProfile,
    required this.cardPrefix,
    required this.cardSuffix,
  });

  static Future<PrintBatchesModel> fromDatabase(Map data)async{
    PrintTemplatesModel? model;
    // PrintTemplatesApi api=PrintTemplatesApi();
    Map templateData=await PrintTemplatesApi.getTemplateData(data["template_id"]);
    model=templateData.isEmpty? null : PrintTemplatesModel.fromDataForm(templateData);
    return PrintBatchesModel(
      id: data["id"], 
      name: data["name"], 
      createdAt: data["created_at"], 
      template: model, 
      generatedCards: data["generated_cards"], 
      cardsProfile: data["cards_profile"], 
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
      "cards_profile": cardsProfile, 
      "card_prefix": cardPrefix , 
      "card_suffix": cardSuffix, 
    };
  }
 

}




