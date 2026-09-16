// Run: flutter test tools/render_splash_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simsabun/main.dart';

void main() {
  testWidgets('render splash preview', (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('NanumMyeongjo')
      ..addFont(rootBundle.load('assets/fonts/NanumMyeongjo-Regular.ttf'));
    await tester.runAsync(font.load);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'NanumMyeongjo'),
        home: RepaintBoundary(key: boundaryKey, child: const SplashScreen()),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/branding/logo.png'),
        tester.element(find.byType(SplashScreen)),
      );
    });
    await tester.pump();
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('build/previews').create(recursive: true);
      await File(
        'build/previews/splash.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
