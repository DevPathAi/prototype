import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_web_size.dart';

void main() {
  test('measures js, font, and total bytes', () {
    final dir = Directory.systemTemp.createTempSync('web-size-test');
    addTearDown(() => dir.deleteSync(recursive: true));

    File('${dir.path}/main.dart.js').writeAsStringSync('12345');
    final assets = Directory('${dir.path}/assets')..createSync();
    File('${assets.path}/font.woff2').writeAsStringSync('abc');

    final result = measureWebBuild(dir)!;

    expect(result.jsBytes, 5);
    expect(result.fontBytes, 3);
    expect(result.totalBytes, 8);
  });
}
