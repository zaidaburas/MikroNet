import 'package:flutter/material.dart';
import '../../Controllers/cards_controller.dart';
import 'card_sessions.dart';
import 'card_info.dart';


import '../widgets/shared/layouts/sub_page_header.dart';
import '../widgets/widgetsCard/card_item_tile.dart';

class CardsListView extends StatefulWidget {
  const CardsListView({super.key});

  @override
  State<CardsListView> createState() => _CardsListViewState();
}

class _CardsListViewState extends State<CardsListView> {
  final controller = CardsController();
  String filter = "الكل";
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // 1. استخدام الهيدر الجاهز (بدلاً من _buildPremiumHeader)
            const PremiumHeader(
              title: "إدارة الكروت",
              subtitle: "عرض وتحرير كافة اشتراكات الشبكة",
              showBackButton: true, // سيعمل تلقائياً كـ Navigator.pop
            ),
            
            // 2. منطقة البحث والفلترة (بقيت هنا لأنها خاصة بالصفحة)
            _buildSearchAndFilterArea(),
            
            // 3. القائمة
            Expanded(child: _buildCardsList()),
            
            // 4. الفوتر البسيط
            _buildMinimalFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= SEARCH & FILTER AREA ================= */
  Widget _buildSearchAndFilterArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: const InputDecoration(
                      hintText: "بحث برقم الكرت أو الباقة...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF1E3A8A)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _addButton(),
            ],
          ),
          const SizedBox(height: 15),
          _buildFilterChips(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _addButton() {
    return InkWell(
      onTap: _addCardDialog,
      child: Container(
        height: 55, width: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildFilterChips() {
    final items = ["الكل", "نشطة", "منتهية"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((f) {
        final active = filter == f;
        return GestureDetector(
          onTap: () => setState(() => filter = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1E3A8A) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: active ? Colors.transparent : Colors.blueGrey.shade50),
            ),
            child: Text(
              f,
              style: TextStyle(color: active ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  /* ================= LIST OF CARDS ================= */
  Widget _buildCardsList() {
    return FutureBuilder(
      future: controller.getCards(filter: filter, search: search),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final cards = snapshot.data as List;
        if (cards.isEmpty) return _emptyState();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (_, i) => CardItemTile( // استخدام الويدجت الخارجي (بدلاً من _cardTile)
            username: cards[i].username,
            package: cards[i].package,
            status: cards[i].status,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CardDetailsView(card: cards[i]))),
            onAnalyticsTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CardSessionsView(code: cards[i].username))),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 60, color: Colors.blueGrey.shade100),
        const SizedBox(height: 10),
        const Text("لم يتم العثور على نتائج", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
      ],
    );
  }

  Widget _buildMinimalFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(
          "نظام إدارة مايكرونت الذكي",
          style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /* ================= ADD DIALOG ================= */
  void _addCardDialog() {
    final user = TextEditingController();
    final pass = TextEditingController();
    final pkg = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("إضافة كرت جديد", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(user, "اسم المستخدم", Icons.person_outline),
            _dialogField(pass, "كلمة المرور", Icons.lock_outline),
            _dialogField(pkg, "الباقة", Icons.inventory_2_outlined),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                // منطق الحفظ لم يتغير
                // await controller.updateCard(...); 
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(i, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
