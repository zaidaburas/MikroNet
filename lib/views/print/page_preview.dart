import 'package:flutter/material.dart';
import '../../Controllers/print_controller.dart';
import '../../view/widgets/app_scaffold_layout.dart';

class TemplatePreviewPage extends StatelessWidget {
  final PrintTemplatesController controller;
  final int templateIndex;
  // أضفنا هذا المتغير لاستقبال بيانات الدفعة من شاشة الإضافة
  final Map<String, dynamic> batchData;

  const TemplatePreviewPage({
    super.key,
    required this.controller,
    required this.templateIndex,
    required this.batchData,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.savedTemplates.isEmpty ||
        templateIndex >= controller.savedTemplates.length) {
      return const Scaffold(
        body: Center(child: Text("لا توجد بيانات للعرض")),
      );
    }

    final template = controller.savedTemplates[templateIndex];

    final rows = template['rows'] ?? 8;
    final cols = template['cols'] ?? 3;
    final background = template['background'];
    final userFont = template['userFont'] ?? 14.0;
    final passFont = template['passFont'] ?? 12.0;
    final Offset userPos = template['userPos'] ?? const Offset(20, 30);
    final Offset passPos = template['passPos'] ?? const Offset(20, 60);
    final showPass = template['showPass'] ?? true;

    // جلب البيانات المرسلة من شاشة الإضافة
    final int totalCards = batchData['total'] ?? (rows * cols);
    final String prefix = batchData['prefix'] ?? "";
    final String suffix = batchData['suffix'] ?? "";

    return AppScaffoldLayout(
      title: "معاينة قبل الطباعة",
      footerText: "Micronet • Cards Management System",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double availableWidth = constraints.maxWidth;
                      final double cardWidth = (availableWidth / cols) - 8;
                      final double cardHeight = cardWidth * 0.60; // نسبة الكرت
                      const double designHeight = 210;
                      final double ratio = cardHeight / designHeight;

                      return SingleChildScrollView(
                        child: Column(
                          children: List.generate(rows, (rowIndex) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(cols, (colIndex) {
                                final index = rowIndex * cols + colIndex;

                                // نتوقف عن الرسم إذا تجاوزنا العدد المطلوب
                                if (index >= totalCards) {
                                  return SizedBox(width: cardWidth + 8);
                                }

                                // توليد بيانات وهمية للمعاينة تحاكي الواقع
                                final mockUser = "$prefix${1000 + index}$suffix";
                                final mockPass = "123456";

                                return Container(
                                  width: cardWidth,
                                  height: cardHeight,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                    image: background != null
                                        ? DecorationImage(image: background, fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      /// USERNAME
                                      Positioned(
                                        left: userPos.dx * ratio,
                                        top: userPos.dy * ratio,
                                        child: Text(
                                          mockUser,
                                          style: TextStyle(
                                            fontSize: userFont * ratio,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),

                                      /// PASSWORD
                                      if (showPass)
                                        Positioned(
                                          left: passPos.dx * ratio,
                                          top: passPos.dy * ratio,
                                          child: Text(
                                            mockPass,
                                            style: TextStyle(
                                              fontSize: passFont * ratio,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "هذه المعاينة توضح كيف ستظهر الكروت ببياناتها الحقيقية بعد الإنشاء.",
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
