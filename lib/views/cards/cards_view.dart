import 'package:flutter/material.dart';
import 'cards_list_view.dart';
import '../packages/packages_view.dart';
import 'add_single_card_view.dart';

class CardsManagementView extends StatelessWidget {
  const CardsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // خلفية ناعمة جداً
        body: Column(
          children: [
            _buildPremiumHeader(context),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionHeader("إدارة الكروت والخدمات"),
                  const SizedBox(height: 12),
                  _buildActionRow(
                    context,
                    icon: Icons.style_rounded,
                    title: "الكروت والخدمات",
                    subtitle: "إضافة • تعديل • حذف الكروت",
                    color: const Color(0xFF6366F1),
                    onTap: () => _go(context, const CardsListView()),
                  ),
                  _buildActionRow(
                    context,
                    icon: Icons.add_moderator_rounded,
                    title: "إضافة كرت واحد",
                    subtitle: "إنشاء كرت اشتراك يدوي سريع",
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _go(context, const AddSingleCardView()),
                  ),

                  const SizedBox(height: 25),

                  _buildSectionHeader("الاشتراكات والأسعار"),
                  const SizedBox(height: 12),
                  _buildActionRow(
                    context,
                    icon: Icons.inventory_2_rounded,
                    title: "الباقات والسرعات",
                    subtitle: "الأسعار • المدد • تحديد السرعات",
                    color: const Color(0xFFF59E0B),
                    onTap: () => _go(context, const PackagesView()),
                  ),

                  const SizedBox(height: 25),

                 
                  
                ],
              ),
            ),
            _buildMiniFooter(),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext c, Widget page) {
    Navigator.push(c, MaterialPageRoute(builder: (_) => page));
  }

  /* ================= MODERN HEADER ================= */
  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x441E3A8A), blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Icon(Icons.credit_card_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "إدارة الكروت",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 15,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= SECTION HEADER ================= */
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  /* ================= INTERACTIVE ROW ================= */
  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.blueGrey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: Colors.blueGrey.shade200),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ================= MINI FOOTER ================= */
  Widget _buildMiniFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.blueGrey.shade50)),
      ),
      child: Center(
        child: Text(
          "نظام مايكرونت • إدارة الكروت الذكية",
          style: TextStyle(
            color: Colors.blueGrey.shade300,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
