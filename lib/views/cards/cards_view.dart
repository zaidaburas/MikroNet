import 'package:flutter/material.dart';
import '../widgets/shared/layouts/main_gate_header.dart';
import '../widgets/shared/layouts/app_mini_footer.dart';
import '../widgets/shared/cards/main_action_card.dart';
import '../widgets/shared/typography/section_title.dart';

// استيراد الصفحات الفرعية
import 'cards_list_view.dart';
import '../cards/packages_view.dart';
import 'add_single_card_view.dart';

class CardsManagementView extends StatelessWidget {
  const CardsManagementView({super.key});

  // ميثود مساعدة للتنقل لتقليل تكرار الكود
  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            //  استخدام الهيدر المطور المشترك
            const MainGateHeader(
              title: "إدارة الكروت",
              subtitle: "تحكم كامل في الكروت، الخدمات، والأسعار",
              icon: Icons.credit_card_rounded,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  //  استخدام ويدجت عنوان القسم المشترك
                  const SectionTitle(title: "إدارة الكروت والخدمات"),
                  
                  //  استخدام ويدجت بطاقة الأوامر المشتركة
                  MainActionCard(
                    title: "الكروت والخدمات",
                    subtitle: "إضافة • تعديل • حذف الكروت",
                    icon: Icons.style_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () => _go(context, const CardsListView()),
                  ),

                  MainActionCard(
                    title: "إضافة كرت واحد",
                    subtitle: "إنشاء كرت اشتراك يدوي سريع",
                    icon: Icons.add_moderator_rounded,
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _go(context, const AddSingleCardView()),
                  ),

                  const SizedBox(height: 15),

                  const SectionTitle(title: "الاشتراكات والأسعار"),

                  MainActionCard(
                    title: "الباقات والسرعات",
                    subtitle: "الأسعار • المدد • تحديد السرعات",
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () => _go(context, const PackagesView()),
                  ),
                ],
              ),
            ),

            // استخدام ويدجت الفوتر المشترك
            const AppMiniFooter(sectionName: "إدارة الكروت الذكية"),
          ],
        ),
      ),
    );
  }
}
