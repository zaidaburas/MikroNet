import 'dart:math';

extension ByteFormatter on String {
  
  String formatBytes() {
    double bytes = double.tryParse(this) ?? 0;
    if (bytes <= 0) return "0 بايت";
    const suffixes = ["بايت", "كيلوبايت", "ميجابايت", "جيجابايت", "تيرابايت"];
    int i = (log(bytes) / log(1024)).floor();
    double result = bytes / pow(1024, i);
    return "${result.toStringAsFixed(2)} ${suffixes[i]}";
  }
}