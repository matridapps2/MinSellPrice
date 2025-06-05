class CommonMethods {
  CommonMethods._();

  static String removeLastSlash(String value) {
    return value.replaceRange(value.length - 1, null, '');
  }
}
