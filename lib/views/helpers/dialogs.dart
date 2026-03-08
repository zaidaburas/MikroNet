
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showErrorDialog({String title="Error",Color titleColor=Colors.black,String content="...",String action="Done"}){
  Get.dialog(
    AlertDialog(
      title: Text(title,style: TextStyle(color: titleColor)),
      content: Text(content),
      actions: [
        TextButton(onPressed: ()=>Get.back(), child: Text(action,))
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

