import 'package:flutter/material.dart';

class AppMiniFooter extends StatelessWidget {
  final String sectionName;

  const AppMiniFooter({super.key, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              "نظام مايكرونت • $sectionName",
              style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              "الإصدار 1.0.0",
              style: TextStyle(color: Colors.blueGrey.shade200, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
