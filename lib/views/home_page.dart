import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/views/prints/print_page.dart';
import '/api/cards_api.dart';
import '/api/profiles_api.dart';
import '/api/users_api.dart';
import '/models/cards_model.dart';
import '/models/users_model.dart';
import '/models/profiles_model.dart';
import '/services/mikrotik_client.dart';
import '/views/helpers/dialogs.dart';
import 'prints/templates/templates_form.dart';
import 'prints/templates/all_templates_view.dart';
// import '/views/test.dart';

import 'widgets/menu_item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('title'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildGridMenu(context),
            ),
          ),
        ],
      ),
      floatingActionButton: MaterialButton(
        onPressed: () async{
          try {
            // Get.to(TestTemplatesScreen());
            // List data=[];
            // await MikrotikClient.login();
            // UsersApi model=UsersApi();
            // var r=await model.getAlISavedUsers();
            // if(r.status){
            //   for (var i in r.data) {
            //     data.add(
            //       i.toMap()
            //     );
            //   }
            // }
            // else{
            //   data.add(r.message);
            // }
            // // showErrorDialog(title: "hhh",content: r.toString());
            // showErrorDialog(
            //   title: data.length.toString(),
            //   content: data.toString()
            // );
          }catch (e) {
            showErrorDialog(content: e.toString());
          }
        },
        onLongPress : () async{
          try {
            // Get.to(TestBatchesScreen());
            // List data=[];
            // await MikrotikClient.login();
            // UsersApi model=UsersApi();
            // var r=await model.getAlISavedUsers(where: "?.id=*48A");
            // if(r.status){
            //   for (var i in r.data!) {
            //     data.add(
            //       i.toMap()
            //     );
            //   }
            // }
            // else{
            //   data.add(r.message);
            // }
            // showErrorDialog(
            //   title: data.length.toString(),
            //   content: data.toString()
            // );
          } catch (e) {
            showErrorDialog(content: e.toString());
          }
        },
        // tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
    //throw UnimplementedError();
  }
  
  Future<void> fun1()async{
    Get.to(PrintOperationsView());
  }

  Future<void> fun2()async{
    try {
      List d=[];
      await MikrotikClient.login();
      var r=await UsersApi.labelDevice(
        macAddress: "12:9A:C4:EB:D7:E2"
      );
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun3()async{
    try {
      List d=[];
      await MikrotikClient.login();
      var r=await UsersApi.blockDevice(
        macAddress: "04:5E:A4:70:06:21",
        srcAddress: "4.0.0.20",
        label: "zz7354", 
        dstAddress: "4.0.0.9", 
      );
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun4()async{
    try {
      List d=[];
      await MikrotikClient.login();
      var r=await UsersApi.bypassDevice(
        macAddress: "04:5E:A4:70:06:21",
        srcAddress: "4.0.0.20",
        label: "zz7354", 
        dstAddress: "4.0.0.9", 
      );
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun5()async{
    try {
      List d=[];
      await MikrotikClient.login();
      var r=await UsersApi.removeDevice(id: "*487");
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }
  
  Future<void> fun6()async{
    // try {
    //   ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
    //   var r=await model.getAllProfiles();
    //   showErrorDialog(title: r.length.toString(),content: r.toString());
    // } catch (e) {
    //   showErrorDialog(content: e.toString());
    // }
  }


  Widget _buildGridMenu(BuildContext context) {
      final List<Map<String, dynamic>> menuData = [
        {"title": "template", "icon": Icons.credit_card_rounded, "view": fun1 },
        {"title": "edit", "icon": Icons.people_alt_rounded, "view": fun2 },
        {"title": "delete", "icon": Icons.print_rounded, "view": fun3 },
        {"title": "getProfilesLimitations", "icon": Icons.dns_rounded, "view": fun4 },
        {"title": "getProfile", "icon": Icons.analytics_rounded, "view": fun5 },
        {"title": "getAllProfiles", "icon": Icons.cloud_sync_rounded, "view": fun6 },
      ];

      return GridView.builder(
        padding: const EdgeInsets.only(top: 10, bottom: 30),
        itemCount: menuData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) => MenuItemCard(
          title: menuData[index]['title'],
          icon: menuData[index]['icon'],
          onTap: (
            index==0?fun1:
            index==1?fun2:
            index==2?fun3:
            index==3?fun4:
            index==4?fun5:
            fun6
            ),
          // (){
          //   if(index==0){
          //     fun1();
          //   }
          //   menuData[index]['view'];
          // },
          // onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => menuData[index]['view'])),
        ),
      );
    }


}

