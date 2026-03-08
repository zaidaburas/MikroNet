
import 'package:mikronet/views/helpers/dialogs.dart';

import 'database_model.dart';

class LoginDataModel extends DBModel{

  Future<List> getSavedLoginData()async{
    return await select("saved_logins");
  }

  Future<Map<String,dynamic>> getOneLogin(int id)async{
    List data =await select("saved_logins","id=$id");
    Map<String,dynamic> result=data[0];
    return result;
  }

  Future<int> saveLoginData(Map<String,dynamic> data)async{
    return await insert("saved_logins", data);
  }

  Future<int> editLoginData(int id,Map<String,dynamic> data)async{
    return await update("saved_logins", data,"id=$id");
  }

  Future<int> deleteLoginData(int id)async{
    return await delete("saved_logins", "id=$id");
  }
}