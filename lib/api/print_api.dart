
import '/api/cards_api.dart';
import '/api/database_api.dart';

class PrintTemplatesApi {
 static Future<List> getAllTemplates()async{
  return await DBApi.select("templates");
 }

 static Future<Map> getTemplateData(int id)async{
  List result=await DBApi.select("templates","id=$id");
  return result.isEmpty?{}:result[0];
 }

 static Future<int> addOneTemplate(Map data)async{
  return await DBApi.insert("templates", data as Map<String, dynamic>);
 }

 static Future<int> templateEdit(int id, Map data)async{
  return await DBApi.update("templates", data as Map<String, dynamic> ,"id=$id");
 }

 static Future<int> deleteTemplate(int id)async{
  return await DBApi.delete("templates","id=$id");
 }
 


}





class PrintBatchesApi {
 static Future<List> getAllBatches()async{
  return await DBApi.select("batches");
 }

 static Future<Map> getBatchData(int id)async{
  List result=await DBApi.select("batches","id=$id");
  return result.isEmpty?{}:result[0];
 }

 static Future<List> getBatchWith(String where)async{
  return await DBApi.select("batches",where);
 }

 static Future<int> addOneBatch(Map data)async{
  return await DBApi.insert("batches", data as Map<String, dynamic>);
 }

 static Future<int> batchEdit(int id, Map data)async{
  return await DBApi.update("batches", data as Map<String, dynamic> ,"id=$id");
 }

 static Future<int> deleteFromLocal(int id)async{
  return await DBApi.delete("batches","id=$id");
 }

 static Future<String> deleteFromServer(int id)async{
  try {
    Map batch=await getBatchData(id);
    String cards=batch["generated_cards"];
    List ids= await CardsApi.getIdsByUsernames( cards.split(",") );
    await CardsApi.deleteCardsBatch(ids);
    return "done";
  } catch (e) {
    throw Exception(e.toString());
  }
 }

 static Future<String> deleteBatch(int id)async{
  try {
    await deleteFromServer(id);
    await deleteFromLocal(id);
    return "done";
  } catch (e) {
    throw Exception(e.toString());
  }
 }
 


}



