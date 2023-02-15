import 'dart:io';

getCurrentIP() async {
  final interfaces = await NetworkInterface.list();
  for (final interface in interfaces) {
    if (interface.name.toLowerCase().contains('eth') ||
        interface.name.toLowerCase().contains('en') ||
        interface.name.toLowerCase().contains('wi-fi')) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return (addr.address.toString());
        }
      }
    }
    return false;
  }
}

Future<List<String>> getKitsuDeckIP() async {
  final ipList = <String>[];
  final currentIP = await getCurrentIP();
  if (currentIP == null) {
    return ipList;
  }
  final baseIP = currentIP.substring(0, currentIP.lastIndexOf('.') + 1);
  final futures = <Future>[];
  for (int i = 1; i <= 255; i++) {
    final ip = baseIP + i.toString();
    final address = InternetAddress(ip);
    final lookup = address.reverse();
    futures.add(lookup.then((result) {
      if (result != null && result.host.startsWith('kitsudeck-')) {
        ipList.add(result.host);
      }
    }).catchError((error) {
      print('Error occurred while looking up the host for IP $ip: $error');
    }));
  }
  await Future.wait(futures);
  return ipList;
}
