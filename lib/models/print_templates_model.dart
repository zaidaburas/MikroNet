
import 'package:mikronet/models/database_model.dart';

class PrintTemplatesModel extends DBModel {
 Future<List> getAllTemplates()async{
  return await select("templates");
 }

 Future<Map> getTemplateData(int id)async{
  List result=await select("templates","id=$id");
  return result.isEmpty?{}:result[0];
 }

 Future<int> addOneTemplate(Map data)async{
  return await insert("templates", data as Map<String, dynamic>);
 }

 Future<int> templateEdit(int id, Map data)async{
  return await update("templates", data as Map<String, dynamic> ,"id=$id");
 }

 Future<int> deleteTemplate(int id)async{
  return await delete("templates","id=$id");
 }
 


}