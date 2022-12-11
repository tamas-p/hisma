const addOnClickHereMagic = 'MpX#SE';
const cPort = 4040;
const cord = '/cord';
const machinePage = '/machine/page/';

String getLinkPrefix(String hostname, String domain) {
  final encodedHostname = Uri.encodeComponent(hostname);
  final encodedDomain = Uri.encodeComponent(domain);
  return '$machinePage$encodedHostname/$encodedDomain/';
}
