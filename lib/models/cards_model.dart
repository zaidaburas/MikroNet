import 'mikrotik_model.dart';


class CardsModel {
  MikrotikAdapter mikrotik;
  int version;
  CardsModel({required this.mikrotik,required this.version});
  Map commands={
    6:
    {
      'user_profiles':'/tool/user-manager/profile/print',
      'user_customers':'/tool/user-manager/customer/print',
      'user_adduser':'/tool/user-manager/user/add',
      'user_addprofile':'/tool/user-manager/user/create-and-activate-profile',
    },
    7:
    {
      'user_profiles':'/user-manager/profile/print',
      'user_customers':'/user-manager/user/group/print',
      'user_adduser':'/user-manager/user/add',
      'user_addprofile':'/user-manager/user-profile/add',
    },
    // 'hotspot_profiles':'',
    // 'hotspot_servers':'',
  };

  // Future<List> getAllCards()async{
  //   String props="""username,password,actual-profile,uptime-used,download-used,upload-used,last-seen""";
  //   return await mikrotik.getProperties(
  //     command: "/tool/user-manager/user/print",
  //     props: props
  //   );
  // }

  // Future<List> getCardsWith(List conditions,{List command=const["/tool/user-manager/user/print"]})async{
  //   int 
  //   conditions.insert(0, command);
  //   conditions[1]="?${conditions[1]}";
  //   return await mikrotik.getAllProperties(
  //     command: conditions
  //     );
  // }
  // Future<List> getExpiredCards()async{
  //   List cond=[
  //     '!actual-profile',
  //     '&&uptime-used>0'
  //   ];
  //   return await getCardsWith(cond);
  // }
  // Future<List> getCustomers()async{}
  // Future<List> getCustomers()async{}
  // Future<List> getCustomers()async{}
  // Future<List> getCustomers()async{}
  // Future<List> getCustomers()async{}

  // Future<List> getCustomers()async{
  //   return await mikrotik.getAllProperties(command: commands[version]['user_customers']);
  // }

  Future<String> addOnerCard({
    required Map<String, String> data,
    required Map<String, String> profile,
  }) async {
    // String tool=version==7?"":"/tool";

    try {
      await mikrotik.addData(command: commands[version]['user_adduser'], data: data);
      await mikrotik.addData(command: commands[version]['user_addprofile'], data: profile);
    } catch (e) {
      return 'Failed to execute command: $e';
    }

    return "Done";
  }
}





// import 'dart:async';

// import 'commands.dart';
// import 'helperfunctions.dart';
// // import 'package:router_os_client/router_os_client.dart';

// import 'service/router_os_client.dart';

// class MikrotikAdapter {
//   // MikrotikAdapter({required super.address, required super.user, required super.password,required super.port});

//   final RouterOSClient client;
//   const MikrotikAdapter({required this.client});
//   Future<List> command(String command) async {
//     List result = await client.talk(command);
//     return result;
//   }

  

//   Future<String> addUsermanagerCardNew(
//       String username, String profile,
//       {String password = ''}) async {
//     Map<String, String> data = {
//       'name': username,
//       'password': password,
//     };
//     try {
//       await client.talk(commands[7]['user_adduser'], data);

//       await client.talk(commands[7]['user_addprofile'],
//           {'user': username, 'profile': profile});
//     } catch (e) {
//       return 'Failed to execute command: $e';
//     }

//     return "Done";
//   }

//   Future<String> addUsermanagerCards(
//       List usernames, String customer, String profile,
//       {List? passwords, bool pass = false}) async {
//     String r = "";
//     profile = Uri.encodeComponent(profile);
//     if (!pass) {
//       for (var i in usernames) {
//         r = await addUsermanagerCard(i, customer, profile);
//       }
//     } else /* if (type=="different") */ {
//       for (var i = 0; i < usernames.length; i++) {
//         r = await addUsermanagerCard(usernames[i], customer, profile,
//             password: passwords![i]);
//       }
//     }
//     return r;
//   }

//   Future<String> reAddUsermanagerCard(
//     String username,
//     String customer,
//     String profile,
//     {String tool="/tool"}
//   ) async {
//     String r = "";
//     try {
//       await client.talk('$tool/user-manager/user/create-and-activate-profile',
//           {'customer': customer, 'numbers': username, 'profile': profile});
//     } catch (e) {
//       return 'Failed to execute command: $e';
//     }
//     return r;
//   }
  
//   Future<String> reAddUsermanagerCardNew(
//     String username,
//     String profile,
//   ) async {
//     String r = "";
//     try {
//       await client.talk(commands[7]['user_addprofile'],
//           {'user': username, 'profile': profile});
//     } catch (e) {
//       return 'Failed to execute command: $e';
//     }
//     return r;
//   }

//   Future<String> addHotspotCard(String username, String server, String profile,
//       {String password = ''}) async {
//     Map<String, String>
//         data = /* password==null?{
//         'server': server,
//         'username': username,
//         'profile':profile
//       }: */
//         {
//       'server': server,
//       'name': username,
//       'password': password,
//       'profile': profile
//     };
//     try {
//       await client.talk('/ip/hotspot/user/add', data);
//     } catch (e) {
//       return 'Failed to execute command: $e';
//     }

//     return "Done";
//   }

//   Future<String> addHotspotCards(List usernames, String server, String profile,
//       {List? passwords, bool pass = false}) async {
//     String r = "";
//     if (!pass) {
//       for (var i in usernames) {
//         r = await addHotspotCard(i, server, profile);
//       }
//     } else /* if (type=="different") */ {
//       for (var i = 0; i < usernames.length; i++) {
//         r = await addHotspotCard(usernames[i], server, profile,
//             password: passwords![i]);
//       }
//     }
//     return r;
//   }

//   Future<Map> addUsermanagerCards2(
//     String customer,
//     String profile, {
//     int passLength = 3,
//     String cardType = "username",
//     String userType = "numbers",
//     String passType = "numbers",
//     int count = 10,
//     int length = 7,
//     String prefix = "",
//     String suffix = "",
//     bool isTest = false,
//     bool isSeven=false,
//     required StreamController<int> progressController, // ????? StreamController
//   }) async {
//     Map result = {};
//     List cards = [];
//     List passwordsList = [];

//     if (cardType == "username") {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);

//         for (var i in usernames) {
//           if (!isTest) {
//             String response = isSeven?
//              await addUsermanagerCardNew(i, profile)
//             :await addUsermanagerCard(i, customer, profile);
//             if (!response.contains("username already exists")) {
//               cards.add(i);
//             }
//           } else {
//             cards.add(i);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     } else if (cardType == "same") {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);

//         for (var i in usernames) {
//           if (!isTest) {
//             String response =isSeven?
//              await addUsermanagerCardNew(i, profile,password: i)
//             :await addUsermanagerCard(i, customer, profile, password: i,);
//             if (!response.contains("username already exists")) {
//               cards.add(i);
//               passwordsList.add(i);
//             }
//           } else {
//             cards.add(i);
//             passwordsList.add(i);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     } else {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);
//         List tempPasswords = generateUniqueRandomStrings(
//             count: numOfCards, length: passLength, type: passType);

//         for (var i = 0; i < usernames.length; i++) {
//           if (!isTest) {
//             String response = isSeven?
//               await addUsermanagerCardNew(usernames[i], profile,password: tempPasswords[i])
//              :await addUsermanagerCard(
//                 usernames[i], customer, profile,
//                 password: tempPasswords[i]);
//             if (!response.contains("username already exists")) {
//               cards.add(usernames[i]);
//               passwordsList.add(tempPasswords[i]);
//             }
//           } else {
//             cards.add(usernames[i]);
//             passwordsList.add(tempPasswords[i]);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     }

//     return result;
//   }

//   Future<Map> addMoreHotspotCards(
//     String server,
//     String profile, {
//     int passLength = 3,
//     String cardType = "username",
//     String userType = "numbers",
//     String passType = "numbers",
//     int count = 10,
//     int length = 7,
//     String prefix = "",
//     String suffix = "",
//     bool isTest = false,
//     required StreamController<int> progressController, // ????? StreamController
//   }) async {
//     Map result = {};
//     List cards = [];
//     List passwordsList = [];

//     if (cardType == "username") {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);

//         for (var i in usernames) {
//           if (!isTest) {
//             String response = await addHotspotCard(i, server, profile);
//             if (!response.contains("username already exists")) {
//               cards.add(i);
//             }
//           } else {
//             cards.add(i);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     } else if (cardType == "same") {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);

//         for (var i in usernames) {
//           if (!isTest) {
//             String response =
//                 await addHotspotCard(i, server, profile, password: i);
//             if (!response.contains("already exists")) {
//               cards.add(i);
//               passwordsList.add(i);
//             }
//           } else {
//             cards.add(i);
//             passwordsList.add(i);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     } else {
//       while (cards.length < count) {
//         int numOfCards = count - cards.length;
//         List usernames = generateUniqueRandomStrings2(
//             count: numOfCards,
//             length: length,
//             prefix: prefix,
//             suffix: suffix,
//             type: userType,
//             data: cards);
//         List tempPasswords = generateUniqueRandomStrings(
//             count: numOfCards, length: passLength, type: passType);

//         for (var i = 0; i < usernames.length; i++) {
//           if (!isTest) {
//             String response = await addHotspotCard(
//                 usernames[i], server, profile,
//                 password: tempPasswords[i]);
//             if (!response.contains("already")) {
//               cards.add(usernames[i]);
//               passwordsList.add(tempPasswords[i]);
//             }
//           } else {
//             cards.add(usernames[i]);
//             passwordsList.add(tempPasswords[i]);
//           }

//           // ????? ???? ??????
//           progressController.add(((cards.length / count) * 100).toInt());
//           await Future.delayed(const Duration(milliseconds: 100)); // ??? ???????
//         }
//       }
//       result = {'usernames': cards, 'passwords': passwordsList};
//     }

//     return result;
//   }
// }




