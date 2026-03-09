import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mikronet/models/cards_model.dart';
import 'package:mikronet/models/mikrotik_model.dart';
import 'package:mikronet/views/helpers/dialogs.dart';

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
      body: const Center(child: Text("data"),),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          try {
            CardsModel cardsModel=CardsModel(mikrotik: widget.mikrotik);
            var r=await cardsModel.cardRenew(
              username: "zaid",
              profile: "500",
              customer: "admin"
            );
  // List r=await widget.mikrotik.deleteData(
  //   command: "/tool/user-manager/user/remove", 
  //   condition: "username=myUser"
  //   );

  // .editData(
  //   command: "/tool/user-manager/user/set", 
  //   data: {
  //     "username":"myUser",
  //     "password":"",
  //   },
  //   condition: 'username=userMy'
  //   );

  // .addData(
  //   command: "/tool/user-manager/user/add", 
  //   data: {
  //     "customer":"admin",
  //     "username":"myUser",
  //   }
  //   );

// :foreach i in=[/tool user-manager user find where !actual-profile] do={\n:local arrayDeleted [/tool user-manager user remove $i];\n"

  // List r=await widget.mikrotik.printData(
  //   commands: ["/tool/user-manager/user/print","?-actual-profile","?>uptime-used=0"],
  //   // conditions: ['actual-profile=2500','=&&=uptime-used>0'],//,'&& uptime-used>0'],
  //   // fields: "username",
  //   timeout: 30
  //   );
    showErrorDialog(title: r.length.toString(),content: r.toString());
  // Get.dialog(
  //   AlertDialog(title: Text(r.length.toString()) ,content: Text(r.toString()),)
  // );
} catch (e) {
  showErrorDialog(content: e.toString());
}
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
    //throw UnimplementedError();
  }
}
