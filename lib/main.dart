import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const websiteUrl = 'https://deersoul6662.xyz';
const appTitle = '심령사진 분류 아르바이트';
const splashDuration = Duration(seconds: 3);
const backgroundColor = Color(0xFF111412);
const ivoryColor = Color(0xFFEDF0E7);
const sageColor = Color(0xFFAAB69D);
const _fullscreenChannel = MethodChannel('simsabun/fullscreen');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Nanum Myeongjo',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SimsabunApp());
}

class SimsabunApp extends StatelessWidget {
  const SimsabunApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: appTitle,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'NanumMyeongjo',
      colorScheme: const ColorScheme.dark(
        primary: sageColor,
        surface: backgroundColor,
        onSurface: ivoryColor,
      ),
    ),
    home: const LaunchScreen(child: WebsiteScreen()),
  );
}

/// Preloads the website behind an opaque splash for three seconds.
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key, required this.child});
  final Widget child;
  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  Timer? _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer(splashDuration, () {
        if (mounted) setState(() => _showSplash = false);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ExcludeSemantics(
        excluding: _showSplash,
        child: IgnorePointer(ignoring: _showSplash, child: widget.child),
      ),
      if (_showSplash) const SplashScreen(),
    ],
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Material(
    color: backgroundColor,
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 450;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/branding/logo.png',
                    width: compact ? 110 : 184,
                    height: compact ? 110 : 184,
                    semanticLabel: '오래된 학교 사진이 겹쳐진 심사분 로고',
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '심령사진\n분류 아르바이트',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ivoryColor,
                      fontSize: compact ? 23 : 29,
                      height: 1.6,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({super.key});
  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  Timer? _fullscreenTimer;
  bool _loading = true;
  bool _failed = false;
  bool _handlingBack = false;
  String _currentUrl = websiteUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = WebViewController();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller.setBackgroundColor(backgroundColor);
      await _controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _currentUrl = url;
            if (mounted) {
              setState(() {
                _loading = true;
                _failed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) _showError();
          },
          onHttpError: (error) {
            if (error.request?.uri.toString() == _currentUrl) _showError();
          },
          onNavigationRequest: (request) {
            final scheme = Uri.tryParse(request.url)?.scheme;
            return scheme == 'https' || scheme == 'http'
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      );
      await _controller.loadRequest(Uri.parse(websiteUrl));
    } catch (_) {
      _showError();
    }
  }

  void _showError() {
    if (mounted) {
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _failed = false;
      _loading = true;
    });
    await _initialize();
  }

  Future<void> _goBack() async {
    if (_handlingBack) return;
    _handlingBack = true;
    try {
      if (await _controller.canGoBack()) {
        await _controller.goBack();
      } else {
        await SystemNavigator.pop();
      }
    } finally {
      _handlingBack = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_restoreFullscreen());
  }

  @override
  void didChangeMetrics() {
    // Restore immersive mode after Android's keyboard visibility delay.
    _fullscreenTimer?.cancel();
    _fullscreenTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && View.of(context).viewInsets.bottom == 0) {
        unawaited(_restoreFullscreen());
      }
    });
  }

  Future<void> _restoreFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _fullscreenChannel.invokeMethod<void>('hideSystemBars');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fullscreenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) unawaited(_goBack());
    },
    child: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(controller: _controller),
          if (_loading && !_failed)
            const ColoredBox(
              color: backgroundColor,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (_failed)
            ColoredBox(
              color: backgroundColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: sageColor,
                        size: 36,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '페이지를 불러오지 못했습니다.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '인터넷 연결을 확인한 뒤 다시 시도해 주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sageColor,
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
