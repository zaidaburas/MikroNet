import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  List r=await widget.mikrotik.printData(
    commands: ["/tool/user-manager/user/print"],
    conditions: ["username=zz7354"],
    fields: "username,actual-profile",
    timeout: 30
    );
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
