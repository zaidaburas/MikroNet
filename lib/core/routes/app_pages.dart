import 'package:get/get.dart';
import 'package:mikronet/controllers/cards/profiles/add_profile_controller.dart';
import 'package:mikronet/controllers/cards/profiles/edit_profile_controller.dart';
import 'package:mikronet/controllers/more/more_settings_controller.dart';
import 'package:mikronet/controllers/reports/system_status_controller.dart';
import 'package:mikronet/controllers/sites/dns_settings_controller.dart';
import 'package:mikronet/views/cards/profiles/add_profile_page.dart';
import 'package:mikronet/views/cards/profiles/edit_profile_page.dart';
import 'package:mikronet/views/more/more_settings_view.dart';
import 'package:mikronet/views/reports/system_status_report_view.dart';
import 'package:mikronet/views/sites/dns_settings_page.dart';
//import 'package:mikronet/controllers/users/devices_controller.dart';

// ================= استيراد الواجهات (Views) =================
//import '../../views/users/devices_manager.dart';
import '/views/login_page.dart';
import '/views/home_page.dart';
import '/controllers/login_controller.dart';
import '/controllers/home_controller.dart';


import '../../views/cards/cards_unit.dart';

import '../../views/cards/cards_list_page.dart';
import '../../views/cards/add_single_card_page.dart';
import '../../views/cards/card_info_page.dart';
import '../../views/cards/card_sessions_page.dart';
import '../../views/cards/profiles_page.dart';



import '../../controllers/cards/cards_unit_controller.dart';
import '/controllers/cards/cards_list_controller.dart';
import '/controllers/cards/add_single_card_controller.dart';
import '../../controllers/cards/card_info_controller.dart';
import '/controllers/cards/card_sessions_controller.dart';
import '../../controllers/cards/profiles_controller.dart';


import '/views/users/users_page.dart';
import '/views/users/devices_manager.dart';
import '/views/users/hosts_view.dart';
import '/views/users/connected_users.dart';

import '/controllers/users/users_management_controller.dart';
import '/controllers/users/devices_controller.dart' as binding;
import '/controllers/users/active_users_controller.dart';
import '/controllers/users/hosts_controller.dart';

import '/views/sites/sites_page.dart';
import '/views/sites/dns_cache.dart';
import '/views/sites/blocked_sites.dart';


import '/controllers/sites/sites_controller.dart';
import '/controllers/sites/dns_cache_controller.dart';
import '/controllers/sites/blocked_sites_controller.dart';


import '/views/prints/print_page.dart';
import '/views/reports/reports_page.dart';

/*
import '/view/backups/backup_view.dart';

// ================= استيراد المتحكمات (Controllers) =================




import '/controller/reports/reports_controller.dart';
import '/controller/settings/backup_controller.dart';
*/
class AppRoutes {
  static const String login = '/';
  static const String home = '/home';

  static const String cards = '/cards';
  static const String cardsList = '/cards/cards_list';
  static const String addSingleCard = '/cards/add_single_card';
  static const String cardDetails = '/cards/card_details';
  static const String cardSessions = '/cards/card_sessions';
  static const String packages = '/cards/packages';
  static const String addProfile = '/cards/profiles/add_profile';
  static const String editProfile = '/cards/profiles/edit_profile';

  static const String users = '/users';
  static const String binding= '/users/binding';
  static const String activeUsers= '/users/active';
  static const String hostUsers= '/users/hosts';

  static const String sites = '/sites';
  static const String dnsCache = '/sites/dns_cache';
  static const String blockedSites = '/sites/blocked_sites';
  static const String dnsSettings = '/sites/dns_settings';
  
  static const String reports = '/reports';
  static const String systemState = '/reports/system_state';
  static const String backup = '/home/backup';
  

  static const String print = '/print';

  static const String more = '/more';
  // مسارات إدارة المواقع
}

class AppPages {
  static final routes = [
    // Login
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(), 
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    
    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(), 
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
    ),
    GetPage(
      name: AppRoutes.cards, 
      page: () => const CardsUnitPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CardsUnitController())),
    ),
    GetPage(
      name: AppRoutes.cardsList, 
      page: () => const CardsListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CardsListController())),
    ),
    GetPage(
      name: AppRoutes.addSingleCard, 
      page: () => const AddSingleCardPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddSingleCardController())),
    ),
    GetPage(
      name: AppRoutes.packages, 
      page: () => const ProfilesPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfilesController())),
    ),
    GetPage(
      name: AppRoutes.addProfile, 
      page: () => const AddProfilePage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AddProfileController())),
    ),
     GetPage(
      name: AppRoutes.editProfile, 
      page: () => const EditProfilePage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EditProfileController(profile: Get.arguments))),
    ),
    
    GetPage(
      name: AppRoutes.cardDetails,
      page: () => CardInfoPage(card: Get.arguments), 
      binding: BindingsBuilder(() => Get.lazyPut(() => CardInfoController(card: Get.arguments))),
    ),
    // ابحث عن مسار cardSessions وقم بتعديله كالتالي:
    GetPage(
      name: AppRoutes.cardSessions,
      page: () => CardSessionsPage(username: Get.arguments),
      binding: BindingsBuilder(() {
        // تمرير القيمة الممررة (Get.arguments) إلى مشيد المتحكم
        Get.lazyPut(() => CardSessionsController(cardCode: Get.arguments));
      }),
    ),
    // صفحات إدارة المواقع
    GetPage(
      name: AppRoutes.users, 
      page: () => const UsersManagementView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => UsersManagementController())),
    ),
    GetPage(
      name: AppRoutes.binding, 
      page: () => const DevicesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => binding.DevicesController())),
    ),
    GetPage(
      name: AppRoutes.activeUsers, 
      page: () => const ActiveSessionsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ActiveSessionsController())),
    ),
    GetPage(
      name: AppRoutes.hostUsers, 
      page: () => const HostsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HostsController())),
    ),
    GetPage(
      name: AppRoutes.sites, 
      page: () => const DataManagementView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SitesController())),
    ),
    GetPage(
      name: AppRoutes.dnsCache,
      page: () => const DnsCacheView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DnsCacheController())),
    ),
    GetPage(
      name: AppRoutes.blockedSites,
      page: () => const BlockedSitesView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => BlockedSitesController())),
    ),
     GetPage(
      name: AppRoutes.dnsSettings,
      page: () => const DnsSettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DnsController())),
    ),
    GetPage(
      name: AppRoutes.print, 
      page: () => const PrintOperationsView(),
      //binding: BindingsBuilder(() => Get.lazyPut(() => ReportsController())),
    ),
    GetPage(
      name: AppRoutes.reports, 
      page: () => const ReportsManagementView(),
      //binding: BindingsBuilder(() => Get.lazyPut(() => BackupController())),
    ),
    GetPage(
      name: AppRoutes.systemState, 
      page: () => const SystemStatusReportView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SystemStatusController())),
    ),
    GetPage(
      name: AppRoutes.more, 
      page: () => const MoreSettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => MoreSettingsController())),
    ),
  ];
}