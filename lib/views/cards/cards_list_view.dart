import 'package:flutter/material.dart';
import '../../Controllers/cards_controller.dart';
import 'card_sessions.dart';
import 'card_info.dart';

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
        backgroundColor: const Color(0xFFF8FAFC), // خلفية رمادية فاتحة جداً
        body: Column(
          children: [
            _buildPremiumHeader(),
            _buildSearchAndFilterArea(),
            Expanded(child: _buildCardsList()),
            _buildMinimalFooter(),
          ],
        ),
      ),
    );
  }

  /* ================= MODERN HEADER (No Overlap) ================= */
  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _backButton(),
                  const Text(
                    "إدارة الكروت",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 20, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 45), // للموازنة مع زر الرجوع
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "عرض وتحرير كافة اشتراكات الشبكة",
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
      ),
    );
  }

  /* ================= SEARCH & FILTER AREA ================= */
  Widget _buildSearchAndFilterArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20), // مسافة كافية أسفل الهيدر
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
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
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0EA5E9).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
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
              boxShadow: active 
                ? [BoxShadow(color: const Color(0xFF1E3A8A).withOpacity(0.3), blurRadius: 8)] 
                : [],
              border: Border.all(color: active ? Colors.transparent : Colors.blueGrey.shade50),
            ),
            child: Text(
              f,
              style: TextStyle(
                color: active ? Colors.white : Colors.blueGrey,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
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
        final cards = snapshot.data as List<CardItem>;
        if (cards.isEmpty) return _emptyState();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: cards.length,
          itemBuilder: (_, i) => _cardTile(cards[i]),
        );
      },
    );
  }

  Widget _cardTile(CardItem card) {
    bool isActive = card.status == "نشطة";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CardDetailsView(card: card))),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.username,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      "باقة: ${card.package}",
                      style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined, color: Color(0xFF1E3A8A), size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CardSessionsView(code: card.username))),
              ),
            ],
          ),
        ),
      ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () async {
              await controller.updateCard(CardItem(username: user.text, password: pass.text, package: pkg.text, status: "نشطة"));
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("حفظ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
