class SellesReportModel {
  final String card;
  final String profile;
  final double price;
  final String date;
  
  
  
  SellesReportModel({
    required this.card,
    required this.profile,
    required this.price,
    required this.date,

  });

  static SellesReportModel fromMikrotik(Map session){
    
    return SellesReportModel(
      card: session["user"]??"", 
      profile: session["profie"]??"", 
      price: session["price"]??"", 
      date: session["tras-start"]??"", 
    );
  }
}
class SystemStateModel {
  final String uptime;
  final String totalMemory;
  final String freeMemory;
  final String cpu;
  final String version;
  
  
  SystemStateModel({
    required this.uptime,
    required this.totalMemory,
    required this.freeMemory,
    required this.cpu,
    required this.version,

  });

  static SystemStateModel fromMikrotik(Map system){
    
    return SystemStateModel(
      uptime: system["uptime"]??"", 
      totalMemory: system["total-memory"]??"", 
      freeMemory: system["free-memory"]??"", 
      cpu: system["cpu-load"]??"", 
      version: system["version"]??"", 
      
    );
  }

}
