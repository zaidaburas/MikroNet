
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorDialog({String title="Error",Color titleColor=Colors.black,String content="...",String action="Done"}){
  // if(action.isEmpty) {
  //   action=dictionary['done'];
  // }
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: ()=>Get.back(), child: Text(action,style: TextStyle(color: titleColor),))
      ],
      scrollable: true,
    )
  );
}





void showLoadingDialog({String text="processing..."}) {
  Get.dialog(
    AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(text),
        ],
      ),
    )
  );
}

