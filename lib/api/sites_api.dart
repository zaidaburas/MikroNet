import '/services/mikrotik_client.dart';
import '/models/response.dart';
import '/models/sites_model.dart'; // تأكد من وضع مسار الاستيراد الصحيح لملف المودل هنا

class SitesApi {

  static Future<AppResponse<List<dynamic>>> getDnsData() async {
    try {
      List result = await MikrotikClient.printData(
        commands: ["/ip/dns/print"]
      );
      return AppResponse<List<dynamic>>(status: true, message: "done", data: result);
    } catch (e) {
      return AppResponse<List<dynamic>>(status: false, message: e.toString());
    }
  }

  // تم تغيير نوع الإرجاع ليصبح List<DNSCacheModel>
  static Future<AppResponse<List<DNSCacheModel>>> getDnsCache() async {
    try {
      List result = await MikrotikClient.printData(
        commands: ["/ip/dns/cache/print"]
      );
      
      // تحويل النتيجة من List<dynamic> إلى List<DNSCacheModel>
      List<DNSCacheModel> dnsCacheList = result.map((item) {
        return DNSCacheModel.fromMikrotik(item as Map);
      }).toList();

      // إرجاع البيانات محولة وجاهزة
      return AppResponse<List<DNSCacheModel>>(status: true, message: "done", data: dnsCacheList);
    } catch (e) {
      // إرجاع نفس النوع في حال حدوث خطأ
      return AppResponse<List<DNSCacheModel>>(status: false, message: e.toString());
    }
  }
  
  static Future<AppResponse<List<BlockedSiteModel>>> getAllBlockedByIps() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تحميل
    List<BlockedSiteModel> dummyData = [
      BlockedSiteModel(id: "*1A", name: "جهاز مزعج", blockType: "IP", blockValue: "192.168.88.50"),
      BlockedSiteModel(id: "*1B", name: "محاولة اختراق", blockType: "IP", blockValue: "10.0.0.99"),
    ];
    return AppResponse<List<BlockedSiteModel>>(status: true, message: "تم الجلب بنجاح", data: dummyData);
  }

  static Future<AppResponse<List<BlockedSiteModel>>> getAllBlockedByDomains() async {
    await Future.delayed(const Duration(seconds: 1));
    List<BlockedSiteModel> dummyData = [
      BlockedSiteModel(id: "*2A", name: "حظر تيك توك", blockType: "Domain", blockValue: "tiktok.com"),
      BlockedSiteModel(id: "*2B", name: "حظر إعلانات", blockType: "Domain", blockValue: "ads.google.com"),
    ];
    return AppResponse<List<BlockedSiteModel>>(status: true, message: "تم الجلب بنجاح", data: dummyData);
  }

  static Future<AppResponse<List<BlockedSiteModel>>> getAllBlockedByContent() async {
    await Future.delayed(const Duration(seconds: 1));
    List<BlockedSiteModel> dummyData = [
      BlockedSiteModel(id: "*3A", name: "حظر مواقع الأفلام", blockType: "Content", blockValue: "movies"),
      BlockedSiteModel(id: "*3B", name: "حظر كلمات مسيئة", blockType: "Content", blockValue: "badword"),
    ];
    return AppResponse<List<BlockedSiteModel>>(status: true, message: "تم الجلب بنجاح", data: dummyData);
  }

  // =========================================================================
  // 2. دوال الحظر (Block By)
  // =========================================================================

  static Future<AppResponse<bool>> blockByIp(String ip, String comment) async {
    await Future.delayed(const Duration(seconds: 1));
    // هنا سيكون كود الإرسال للمايكروتك مستقبلاً
    return AppResponse<bool>(status: true, message: "تم حظر الـ IP بنجاح", data: true);
  }

  static Future<AppResponse<bool>> blockByDomain(String domain, String comment) async {
    await Future.delayed(const Duration(seconds: 1));
    // هنا سيكون كود الإرسال للمايكروتك مستقبلاً
    return AppResponse<bool>(status: true, message: "تم حظر الدومين بنجاح", data: true);
  }

  static Future<AppResponse<bool>> blockByContent(String content, String comment) async {
    await Future.delayed(const Duration(seconds: 1));
    // هنا سيكون كود الإرسال للمايكروتك مستقبلاً
    return AppResponse<bool>(status: true, message: "تم حظر المحتوى بنجاح", data: true);
  }

  // =========================================================================
  // 3. دوال فك الحظر (Unblock By / Delete)
  // =========================================================================

  static Future<AppResponse<bool>> unblockByIp(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // هنا سيكون كود حذف الـ Item من المايكروتك بناءً على الـ ID
    return AppResponse<bool>(status: true, message: "تم إزالة حظر الـ IP بنجاح", data: true);
  }

  static Future<AppResponse<bool>> unblockByDomain(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return AppResponse<bool>(status: true, message: "تم إزالة حظر الدومين بنجاح", data: true);
  }

  static Future<AppResponse<bool>> unblockByContent(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return AppResponse<bool>(status: true, message: "تم إزالة حظر المحتوى بنجاح", data: true);
  }

}