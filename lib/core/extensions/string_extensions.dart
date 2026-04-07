import 'dart:math';

extension ByteFormatter on String {
  
  String get formatBytes {
    double bytes = double.tryParse(this) ?? 0;
    if (bytes <= 0) return "0 بايت";
    const suffixes = ["بايت", "كيلوبايت", "ميجابايت", "جيجابايت", "تيرابايت"];
    int i = (log(bytes) / log(1024)).floor();
    double result = bytes / pow(1024, i);
    return "${result.toStringAsFixed(2)} ${suffixes[i]}";
  }
}
extension DateFormatExt on String {
  String get formatDate {
    // إذا كان النص فارغاً نرجعه كما هو
    if (trim().isEmpty) return this;

    try {
      // النص المتوقع: "jul/13/2025 13:28:46"
      var parts = trim().split(' ');
      if (parts.isEmpty) return this;

      // 1. التعامل مع جزء التاريخ: "jul/13/2025"
      var dateParts = parts[0].split('/');
      
      // إذا لم يكن التاريخ بالصيغة المتوقعة (3 أجزاء مفصولة بـ /)، نرجع النص الأصلي
      if (dateParts.length != 3) return this;

      // خريطة لتحويل اختصارات الأشهر الإنجليزية إلى أرقام
      const months = {
        'jan': '1', 'feb': '2', 'mar': '3', 'apr': '4', 'may': '5', 'jun': '6',
        'jul': '7', 'aug': '8', 'sep': '9', 'oct': '10', 'nov': '11', 'dec': '12'
      };

      String monthStr = dateParts[0].toLowerCase();
      String month = months[monthStr] ?? monthStr; // إذا لم يتعرف على الشهر، يتركه كما هو
      String day = dateParts[1];
      String year = dateParts[2];

      // 2. التعامل مع جزء الوقت (إن وجد)
      String time = parts.length > 1 ? parts[1] : '';

      // 3. دمج النتيجة بالشكل المطلوب (يوم/شهر/سنة وقت)
      return "$time  $day/$month/$year ".trim();
      
    } catch (e) {
      // في حال حدوث أي خطأ غير متوقع في التحويل، يتم عرض النص الأصلي لتجنب الكراش
      return this;
    }
  }
}