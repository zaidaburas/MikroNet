
class ProfilesModel {
  final String id;
  final String name;
  final String price;
  final String palance;
  final String validity;
  final String speed;
  final String customer;
  final String uptime;
  final String users;

  ProfilesModel({
    required this.id,
    required this.name,
    required this.price,
    required this.palance,
    required this.validity,
    required this.speed,
    required this.customer,
    required this.uptime,
    required this.users,
  });

  static ProfilesModel fromMap(Map profile){
    // finalResult.add({
    //     ".id":profile[".id"],
    //     "name":profile["name"],
    //     "price":profile["price"]??"??",
    //     "palance":profile["limitations"][0]["transfer-limit"]??"??",
    //     "validity":profile["validity"]??"??",
    //     "uptime":profile["limitations"][0]["uptime-limit"]??"??",
    //     "speed":profile["hotspot_settings"]["rate-limit"]??"??",
    //     "users":profile["hotspot_settings"]["shared-users"]??"??",
    //   });
    return ProfilesModel(
      id: profile[".id"],
      name: profile["name"], 
      price: profile["price"]??"??", 
      palance: profile["limitations"][0]["transfer-limit"]??"??",
      validity: profile["validity"]??"??", 
      speed: profile["hotspot_settings"]["rate-limit"]??"??",
      customer: profile["owner"], 
      uptime: profile["limitations"][0]["uptime-limit"]??"??",
      users: profile["hotspot_settings"]["shared-users"]??"??",
    );
  }

  Map toMap(){
    return {
      "id":id,
      "name":name,
      "price":price,
      "palance":palance,
      "validity":validity,
      "speed":speed,
      "customer":customer,
      "uptime":uptime,
      "users":users,
    };
  }
}




