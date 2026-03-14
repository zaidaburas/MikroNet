import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/api/cards_api.dart';
import 'package:mikronet/api/profiles_api.dart';
import 'package:mikronet/models/cards_model.dart';
import 'package:mikronet/models/connected_devices_model.dart';
import 'package:mikronet/models/mikrotik_model.dart';
import 'package:mikronet/models/profiles_model.dart';
import 'package:mikronet/services/mikrotik_client.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

import 'widgets/menu_item_card.dart';

class HomePage extends StatefulWidget {
  final MikrotikAdapter mikrotik;
  const HomePage({
    Key? key,
    required this.mikrotik
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
            List d=[];
            await MikrotikClient.login();
            ProfilesApi model=ProfilesApi();
            var r=await model.getProfiles();
            if(r.status){
              for (var i in r.data!) {
                d.add(
                  i.toMap()
                );
              }
            }
            else{
              d.add(r.message);
            }
            showErrorDialog(
              title: d.length.toString(),
              content: d.toString()
            );
          } catch (e) {
            showErrorDialog(content: e.toString());
          }
        },
        onLongPress : () async{
          try {
            List d=[];
            await MikrotikClient.login();
            ProfilesApi model=ProfilesApi();
            var r=await model.getProfiles(profileName: "3500");
            if(r.status){
              for (var i in r.data!) {
                d.add(
                  i.toMap()
                );
              }
            }
            else{
              d.add(r.message);
            }
            // List result=[
            //   r.status.toString(),
            //   r.message.toString()
            // ];
            showErrorDialog(
              title: d.length.toString(),
              content: d.toString()
            );
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
    try {
      List d=[];
      await MikrotikClient.login();
      ProfilesApi model=ProfilesApi();
      var r=await model.addOneProfile(
        {
          "name": "3500", 
          "price": "3500",
          "palance": "73400320", // 70m
          "validity": "21d",
          "customer": "admin",
          "uptime": "20h",
          "speed": "512k/1m",
          "users": "10"
        }
      );
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun2()async{
    try {
      List d=[];
      await MikrotikClient.login();
      ProfilesApi model=ProfilesApi();
      var r=await model.profileEdit(
        "3500",
        {
          "name": "4500",
          "price": "4500",
          "palance": "73401344", // 70m
          "validity": "22d",
          "uptime": "29h",
          "speed": "512k/1024k",
          "users": "20"
        }
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
      ProfilesApi model=ProfilesApi();
      var r=await model.deleteProfile("3500");
      if(r.status){
        d.add(r.message);
      }
      showErrorDialog(content: d.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun4()async{
    // try {
    //   ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
    //   var r=await model._getLimitationsLinks(/* whereProfile: "?profile=200" */);
    //   showErrorDialog(title: r.length.toString(),content: r.toString());
    // } catch (e) {
    //   showErrorDialog(content: e.toString());
    // }
  }

  Future<void> fun5()async{
    // try {
    //   ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
    //   var r=await model.getAllProfiles(profileName: "prof");
    //   showErrorDialog(title: r.length.toString(),content: r.toString());
    // } catch (e) {
    //   showErrorDialog(content: e.toString());
    // }
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
        {"title": "add", "icon": Icons.credit_card_rounded, "view": fun1 },
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

