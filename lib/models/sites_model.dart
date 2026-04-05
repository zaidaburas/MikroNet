class DNSCacheModel {
  final String id;
  final String name;
  final String type;
  final String data;
  final String ttl;
  
  
  DNSCacheModel({
    required this.id,
    required this.name,
    required this.type,
    required this.data,
    required this.ttl,

  });

  static DNSCacheModel fromMikrotik(Map dns){
    
    return DNSCacheModel(
      id: dns[".id"]??"",
      name: dns["name"]??"", 
      type: dns["type"]??"", 
      data: dns["data"]??"", 
      ttl: dns["ttl"]??"", 
      
    );
  }

  Map toMap(){
    return {
      "id":id,
      "name":name,
      "type":type,
      "data":data,
      "ttl":ttl,    
    };
  }
}

class BlockedSiteModel {
  final String id;
  final String name;
  final String blockType;  // نوع الحظر: 'IP', 'Domain', 'Content'
  final String blockValue; // القيمة: (مثلاً 192.168.1.5 أو google.com أو كلمة معينة)

  BlockedSiteModel({
    required this.id,
    required this.name,
    required this.blockType,
    required this.blockValue,
  });

  // دالة لتحويل بيانات المايكروتك إلى المودل
  // نمرر لها Map القادم من المايكروتك، بالإضافة لنوع الحظر لنعرف من أي حقل نسحب البيانات
  static BlockedSiteModel fromMikrotik(Map data, String type) {
    String extractedValue = "";
    // عادة في المايكروتك نستخدم الـ comment كاسم أو وصف للحظر
    String extractedName = data["comment"] ?? ""; 

    // تحديد مكان القيمة بناءً على نوع الحظر
    if (type == "IP") {
      extractedValue = data["address"] ?? "";
      // إذا لم يوجد تعليق، نضع اسم القائمة كاسم افتراضي
      if (extractedName.isEmpty) extractedName = data["list"] ?? "حظر IP"; 
      
    } else if (type == "Domain") {
      // في الـ DNS Static الدومين يكون في حقل name
      extractedValue = data["name"] ?? ""; 
      if (extractedName.isEmpty) extractedName = "حظر دومين";
      
    } else if (type == "Content") {
      // في الفايرول فلتر الكلمة تكون في حقل content
      extractedValue = data["content"] ?? ""; 
      if (extractedName.isEmpty) extractedName = "حظر محتوى";
      
    } else {
      extractedValue = data["address"] ?? data["name"] ?? data["content"] ?? "";
    }

    return BlockedSiteModel(
      id: data[".id"] ?? "",
      name: extractedName.isNotEmpty ? extractedName : "Unknown",
      blockType: type,
      blockValue: extractedValue,
    );
  }

  // دالة لتحويل المودل إلى Map 
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "blockType": blockType,
      "blockValue": blockValue,
    };
  }
}