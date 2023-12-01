// ignore_for_file: file_names

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

bool? _isMobileBrowser;

bool isMobileBrowser() {
  if (_isMobileBrowser == null) {
    var ua = window.navigator.userAgent.toString();
    var isAndroid = ua.contains('Android');
    var isIos = ua.contains('iPhone') || ua.contains('iPad');

    _isMobileBrowser = isAndroid || isIos;
  }
  return _isMobileBrowser!;
}
