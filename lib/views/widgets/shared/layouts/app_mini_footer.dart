import 'package:flutter/material.dart';

class AppMiniFooter extends StatelessWidget {
  final Widget title;
  final Widget? subTitle; // جعلناها اختيارية وتقبل Null

  const AppMiniFooter({
    super.key, 
    required this.title, 
    this.subTitle,
  });

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
          mainAxisSize: MainAxisSize.min, // لضمان ألا يأخذ العمود مساحة أكبر من محتواه
          children: [
            title,
            // التحقق مما إذا كان subTitle موجوداً قبل عرضه
            if (subTitle != null) ...[
              const SizedBox(height: 2),
              subTitle!,
            ],
          ],
        ),
      ),
    );
  }
}