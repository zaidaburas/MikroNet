
import 'package:mikronet/models/cards_model.dart';
import 'package:mikronet/models/database_model.dart';
import 'package:mikronet/models/mikrotik_model.dart';

class PrintBatchesModel extends DBModel {
 Future<List> getAllBatches()async{
  return await select("batches");
 }

 Future<Map> getBatchData(int id)async{
  List result=await select("batches","id=$id");
  return result.isEmpty?{}:result[0];
 }

 Future<List> getBatchWith(String where)async{
  return await select("batches",where);
 }

 Future<int> addOneBatch(Map data)async{
  return await insert("batches", data as Map<String, dynamic>);
 }

 Future<int> batchEdit(int id, Map data)async{
  return await update("batches", data as Map<String, dynamic> ,"id=$id");
 }

 Future<int> deleteFromLocal(int id)async{
  return await delete("batches","id=$id");
 }

 Future<String> deleteFromServer(int id,MikrotikAdapter mikrotik)async{
  try {
    Map batch=await getBatchData(id);
    String cards=batch["generated_cards"];
    CardsModel model =CardsModel(mikrotik: mikrotik);
    await model.deleteCardsBatch(cards);
    return "done";
  } catch (e) {
    throw Exception(e.toString());
  }
 }

 Future<String> deleteBatch(int id,MikrotikAdapter mikrotik)async{
  try {
    await deleteFromServer(id, mikrotik);
    await deleteFromLocal(id);
    return "done";
  } catch (e) {
    throw Exception(e.toString());
  }
 }
 


}



