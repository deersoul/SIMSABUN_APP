import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simsabun/main.dart';

void main() {
  testWidgets('splash covers the website for three seconds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LaunchScreen(child: Text('website'))),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('심령사진\n분류 아르바이트'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2999));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('website'), findsOneWidget);
  });

  testWidgets('splash timer is cancelled when removed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LaunchScreen(child: SizedBox())),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash fits a small landscape screen', (tester) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
