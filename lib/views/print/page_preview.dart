import 'package:flutter/material.dart';
import '../../Controllers/print_controller.dart';

// استيراد الويجيت الموحدة
import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/typography/section_title.dart';

class TemplatePreviewPage extends StatelessWidget {
  final PrintTemplatesController controller;
  final int templateIndex;
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
      return const Scaffold(body: Center(child: Text("لا توجد بيانات للعرض")));
    }

    final template = controller.savedTemplates[templateIndex];
    final int rows = template['rows'] ?? 8;
    final int cols = template['cols'] ?? 3;
    final dynamic background = template['background'];

    final int totalCards = batchData['total'] ?? (rows * cols);
    final String prefix = batchData['prefix'] ?? "";
    final String suffix = batchData['suffix'] ?? "";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            // 1. الهيدر الموحد v4.5
            PremiumHeader(
              title: "معاينة قبل الطباعة",
              subtitle: "مراجعة شكل الكروت النهائي: ${template['name']}",
              icon: Icons.pageview_rounded,
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    const SectionTitle(title: "تخطيط الورقة الذكي"),
                    _buildInfoBanner(),
                    const SizedBox(height: 15),

                    // استخدام Container مع عرض محدد لتجنب أخطاء الرسم
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15)
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // حسابات ثابتة لمنع خطأ الـ DrawFrame
                          final double availableWidth = constraints.maxWidth;
                          final double childAspectRatio =
                              1 / 0.65; // نسبة ثابتة وآمنة
                          final double cardHeight =
                              (availableWidth / cols) * 0.65;
                          final double ratio = cardHeight / 210;

                          return GridView.builder(
                            shrinkWrap:
                                true, // مهم جداً داخل SingleChildScrollView
                            physics:
                                const NeverScrollableScrollPhysics(), // منع التمرير المتداخل
                            itemCount: rows * cols,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemBuilder: (context, index) {
                              if (index >= totalCards)
                                return const SizedBox.shrink();

                              return _buildSingleMockCard(
                                index: index,
                                ratio: ratio > 0 ? ratio : 1.0,
                                template: template,
                                prefix: prefix,
                                suffix: suffix,
                                background: background,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 2. الفوتر الموحد
            const AppMiniFooter(sectionName: "Preview System Stable"),
          ],
        ),
      ),
    );
  }

  // ميثود بناء الكرت الفردي (المعدل لحل مشكلة RangeError)
  Widget _buildSingleMockCard({
    required int index,
    required double ratio,
    required Map template,
    required String prefix,
    required String suffix,
    dynamic background,
  }) {
    final double userFont = (template['userFont'] ?? 14.0).toDouble();
    final double passFont = (template['passFont'] ?? 12.0).toDouble();
    final Offset userPos = template['userPos'] ?? const Offset(20, 30);
    final Offset passPos = template['passPos'] ?? const Offset(20, 60);
    final bool showPass = template['showPass'] ?? true;

    // توليد بيانات وهمية آمنة
    final String mockUser = "$prefix${1240 + index}$suffix";

    // حل مشكلة substring: نضمن أن النص لا يقل عن طول معين أو نأخذه كاملاً
    String rawPass = "${(index + 1) * 8421}";
    final String mockPass = rawPass.length >= 5
        ? rawPass.substring(0, 5)
        : rawPass; // إذا كان النص أصغر من 5، خذه كما هو ولا تكسر الكود

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * ratio),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
        image: background != null
            ? DecorationImage(image: background, fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          // اسم المستخدم
          Positioned(
            left: userPos.dx * ratio,
            top: userPos.dy * ratio,
            child: Text(
              mockUser,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: userFont * ratio,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          // كلمة المرور
          if (showPass)
            Positioned(
              left: passPos.dx * ratio,
              top: passPos.dy * ratio,
              child: Text(
                mockPass,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: passFont * ratio,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "ملاحظة: المعاينة تعتمد على دقة الشاشة، الطباعة الحقيقية ستكون بجودة PDF الأصلية.",
              style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
