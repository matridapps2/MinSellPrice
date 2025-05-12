class AppInfo {
  AppInfo._();

  static const bool kIsStaging = false;

  static const String kLiveBaseUrl = 'https://growth.matridtech.net/';

  static Map<int, String> stagingMapping() {
    return {
      0: 'http://phplaravel-882494-3089139.cloudwaysapps.com/',
      1: 'https://phplaravel-882494-3459554.cloudwaysapps.com/',
      2: 'https://phplaravel-882494-3233043.cloudwaysapps.com/',
    };
  }

  static String kBaseUrl({required int stagingSelector}) {
    return kIsStaging ? stagingMapping()[stagingSelector] ?? '' : kLiveBaseUrl;
  }

  static int kVendorId = vendorIdMapping()[1] ?? 0;

  static Map<int, int> vendorIdMapping() => {0: 10021, 1: 87343};
}
