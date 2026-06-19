import 'dart:io';

void main(List<String> args) {
  final buildDir = Directory(args.isEmpty ? 'build/web' : args.first);
  final baselineJs = args.length >= 2 ? int.parse(args[1]) : null;
  final baselineAssets = args.length >= 3 ? int.parse(args[2]) : null;
  final fontCap = args.length >= 4 ? int.parse(args[3]) : null;

  final result = measureWebBuild(buildDir);
  if (result == null) {
    stderr.writeln('Web build directory not found: ${buildDir.path}');
    exitCode = 1;
    return;
  }

  stdout.writeln('main.dart.js bytes: ${result.jsBytes}');
  stdout.writeln('total web asset bytes: ${result.totalBytes}');
  stdout.writeln('font bytes: ${result.fontBytes}');

  var failed = false;
  failed |= _checkBudget('main.dart.js', result.jsBytes, baselineJs);
  failed |= _checkBudget('total assets', result.totalBytes, baselineAssets);
  if (fontCap != null && result.fontBytes > fontCap) {
    stderr.writeln('font bytes ${result.fontBytes} exceed cap $fontCap');
    failed = true;
  }

  if (failed) {
    exitCode = 1;
  }
}

class WebBuildSize {
  const WebBuildSize({
    required this.jsBytes,
    required this.totalBytes,
    required this.fontBytes,
  });

  final int jsBytes;
  final int totalBytes;
  final int fontBytes;
}

WebBuildSize? measureWebBuild(Directory buildDir) {
  if (!buildDir.existsSync()) {
    return null;
  }
  var total = 0;
  var fonts = 0;
  final jsFile = File('${buildDir.path}/main.dart.js');
  final jsBytes = jsFile.existsSync() ? jsFile.lengthSync() : 0;

  for (final entity in buildDir.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final bytes = entity.lengthSync();
    total += bytes;
    final lower = entity.path.toLowerCase();
    if (lower.endsWith('.ttf') ||
        lower.endsWith('.otf') ||
        lower.endsWith('.woff') ||
        lower.endsWith('.woff2')) {
      fonts += bytes;
    }
  }

  return WebBuildSize(jsBytes: jsBytes, totalBytes: total, fontBytes: fonts);
}

bool _checkBudget(String label, int actual, int? baseline) {
  if (baseline == null || baseline == 0) {
    return false;
  }
  final ratio = actual / baseline;
  if (ratio > 1.10) {
    stderr.writeln('$label grew more than 10%: $actual vs $baseline');
    return true;
  }
  if (ratio > 1.05) {
    stdout.writeln('$label grew more than 5%: $actual vs $baseline');
  }
  return false;
}
