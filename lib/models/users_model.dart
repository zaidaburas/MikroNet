class DeviceType{
  bool isBlocked;
  bool isFree;
  bool isNormal;
  DeviceType({
    this.isBlocked=false,
    this.isFree=false,
    this.isNormal=true,
  });

  static DeviceType fromMikrotik(String type){
    // bool blo
    return DeviceType(
      isBlocked: type=="blocked",
      isFree: type=="bypassed",
      isNormal: (type!="blocked" && type!="bypassed")
    );
  }

  String toMikrotik(){
    return (isBlocked?"blocked":isFree?"bypassed":"regular");
  }
}
class DevicesModel {
  String id;
  String clientIp;
  String address;
  String macAddress;
  String server;
  DeviceType type;
  String label;

  DevicesModel({
    required this.id,
    this.clientIp="0.0.0.0",
    this.address="0.0.0.0",
    required this.macAddress,
    this.server="all",
    required this.type,
    required this.label,
  });

  static DevicesModel fromMikrotik(Map data){
    return DevicesModel(
      id: data[".id"]??"Unknown", 
      clientIp: data["address"]??"any ip", 
      address: data["to-address"]??"any ip", 
      macAddress: data["mac-address"]??"any mac", 
      server: data["server"]??"all",
      type: DeviceType.fromMikrotik(data["type"]??"normal"), 
      label: data["comment"]??"Unknown",
    );
  }

  Map toMikrotik(){
    return {
      // ".id":id,
      "address":clientIp,
      "to-address":address,
      "mac-address":macAddress,
      "server":server,
      "type":type.toMikrotik(),
      "comment":label,
    };
  }


}





class HostUserModel {
  String id;
  String clientIp;
  String address;
  String macAddress;
  String uptime;
  String server;
  String download;
  String upload;
  String type;
  String label;
  
  HostUserModel({
    required this.id,
    required this.clientIp,
    required this.address,
    required this.macAddress,
    required this.uptime,
    required this.server,
    required this.download,
    required this.upload,
    required this.type,
    required this.label,
  });

  static HostUserModel fromMikrotik(Map user){
    bool isAuth=user.keys.contains("authorized");
    bool isBypass=user.keys.contains("bypassed");
    if( isAuth && user["authorized"]=="true" ){
      user["type"]="auth";
    }
    else if( isBypass && user["bypassed"]=="true" ){
      user["type"]="bypass";
    }
    else{
      user["type"]="unauth";
    }
    return HostUserModel(
      id: user[".id"]??"Unknown",
      clientIp: user["address"]??"Unknown", 
      address: user["to-address"]??"Unknown", 
      macAddress: user["mac-address"]??"Unknown", 
      uptime: user["uptime"]??0, 
      server: user["server"]??"Unknown", 
      download: user["bytes-out"]??0,
      upload: user["bytes-in"]??0,
      type: user["type"]??"Unknown",
      label: user["comment"]??"Unknown",
    );
  }

  Map toMikrotik(){
    return {
      "id":id,
      "address":clientIp,
      "to-address":address,
      "mac-address":macAddress,
      "uptime":uptime,
      "server":server,
      "bytes-out":download,
      "bytes-in":upload,
      // "type":type,
      "comment":label,
    };
  }
}







class ActiveUserModel {
  String id;
  String address;
  String macAddress;
  String uptime;
  String server;
  String download;
  String upload;
  String label;
  String username;
  String timeLeft;
  String totalPalance;
  
  ActiveUserModel({
    required this.id,
    required this.address,
    required this.macAddress,
    required this.uptime,
    required this.server,
    required this.download,
    required this.upload,
    required this.label,
    required this.username,
    required this.totalPalance ,
    required this.timeLeft
  });

  static ActiveUserModel fromMikrotik(Map user){
    return ActiveUserModel(
      id: user[".id"]??"Unknown",
      address: user["address"]??"Unknown", 
      macAddress: user["mac-address"]??"Unknown", 
      uptime: user["uptime"]??0, 
      server: user["server"]??"Unknown", 
      download: user["bytes-out"]??0,
      upload: user["bytes-in"]??0,
      label: user["comment"]??"Unknown",
      username: user["user"]??"Unknown",
      totalPalance: user["limit-bytes-total"]??"Unknown", 
      timeLeft: user["session-time-left"]??"Unknown", 
    );
  }

  Map toMikrotik(){
    return {
      // ".id":id,
      "address":address,
      "mac-address":macAddress,
      "uptime":uptime,
      "server":server,
      "bytes-out":download,
      "bytes-in":upload,
      "comment":label,
      "user":username,
      "limit-bytes-total":totalPalance,
      "session-time-left":timeLeft,
    };
  }
}