import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/models/cards_model.dart';
import 'package:mikronet/models/connected_devices_model.dart';
import 'package:mikronet/models/mikrotik_model.dart';
import 'package:mikronet/models/profiles_model.dart';
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
            ConnectedDevicesModel model=ConnectedDevicesModel(mikrotik: widget.mikrotik);
            var r=await model.getAllConnectedDevices();
            showErrorDialog(title: r.length.toString(),content: r.toString());
          } catch (e) {
            showErrorDialog(content: e.toString());
          }
        },
        onLongPress : () async{
          try {
            ProfilesModel profilesModel=ProfilesModel(mikrotik: widget.mikrotik);
            var r=await await widget.mikrotik.editData(
        command: "/tool/user-manager/profile/set",
        data: {
          "name": "3500" ,
          "owner": "admin" ,
          "name-for-users": "3500" ,
          "validity": "70d" ,
          "price": "3500" ,
          // "starts-at": "logon"
        },
        condition: "?name=proz"
      );
            showErrorDialog(title: r.length.toString(),content: r.toString());
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
      ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
      // var r=await model._getHotspotProfiles(/* whereName: "?name=1" */);
      var r=await widget.mikrotik.printData(
        commands: ["/tool/user-manager/profile/print"],
        conditions: ["?name=proz"]
      );
      showErrorDialog(title: r.length.toString(),content: r.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }

  Future<void> fun2()async{
    // try {
    //   ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
    //   var r=await model._getLimitations(/* whereNane: "?name=200" */);
    //   showErrorDialog(title: r.length.toString(),content: r.toString());
    // } catch (e) {
    //   showErrorDialog(content: e.toString());
    // }
  }

  Future<void> fun3()async{
    try {
      ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
      var r=await model.getProfilesNames(/* whereName: "?name=200" */);
      showErrorDialog(title: r.length.toString(),content: r.toString());
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
    try {
      ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
      var r=await model.getAllProfiles(profileName: "prof");
      showErrorDialog(title: r.length.toString(),content: r.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }
  
  Future<void> fun6()async{
    try {
      ProfilesModel model=ProfilesModel(mikrotik: widget.mikrotik);
      var r=await model.getAllProfiles();
      showErrorDialog(title: r.length.toString(),content: r.toString());
    } catch (e) {
      showErrorDialog(content: e.toString());
    }
  }


  Widget _buildGridMenu(BuildContext context) {
      final List<Map<String, dynamic>> menuData = [
        {"title": "getHotspotProfiles", "icon": Icons.credit_card_rounded, "view": fun1 },
        {"title": "getLimitations", "icon": Icons.people_alt_rounded, "view": fun2 },
        {"title": "getProfilesNames", "icon": Icons.print_rounded, "view": fun3 },
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

