import '/services/mikrotik_client.dart';

class SitesApi {

  Future<List> getDnsData()async{
    return MikrotikClient.printData(
      commands: ["/ip/dns/print"]
    );
  }

  Future<List> getDnsCache()async{
    return MikrotikClient.printData(
      commands: ["/ip/dns/cache/print"]
    );
  }
}