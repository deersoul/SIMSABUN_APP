import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Native anchored banner, separate from the website's touch targets.
class TopBanner extends StatefulWidget {
  const TopBanner({super.key});

  @override
  State<TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<TopBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _ready = false;
  bool _privacyRequired = false;
  int _width = 0;
  int _generation = 0;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_supported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ConsentInformation.instance.requestConsentInfoUpdate(
          ConsentRequestParameters(),
          () => ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) debugPrint('Ad consent: ${error.errorCode}');
            unawaited(_updateConsent());
          }),
          (error) {
            debugPrint('Ad consent update: ${error.errorCode}');
            unawaited(_updateConsent());
          },
        );
      });
    }
  }

  Future<void> _updateConsent() async {
    try {
      final privacy = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      final allowed = await ConsentInformation.instance.canRequestAds();
      if (!mounted) return;
      setState(() {
        _privacyRequired = privacy == PrivacyOptionsRequirementStatus.required;
      });
      if (!allowed || _ready) return;
      await MobileAds.instance.initialize();
      if (!mounted) return;
      _ready = true;
      await _load();
    } catch (error) {
      debugPrint('Ads unavailable: $error');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final width = (media.size.width - media.padding.horizontal).floor();
    if (width == _width) return;
    _width = width;
    if (_ready) unawaited(_load());
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final previous = _ad;
    setState(() {
      _ad = null;
      _loaded = false;
    });
    // Remove the platform view before disposing its native ad.
    WidgetsBinding.instance.addPostFrameCallback((_) => previous?.dispose());
    if (_width <= 0) return;
    try {
      final size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            _width,
          );
      if (!mounted || generation != _generation || size == null) return;
      final ad = BannerAd(
        adUnitId: kReleaseMode
            ? 'ca-app-pub-4313861436734901/4552482858'
            : 'ca-app-pub-3940256099942544/9214589741',
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted || generation != _generation) return;
            setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted || generation != _generation) return;
            setState(() {
              _ad = null;
              _loaded = false;
            });
            debugPrint('Banner unavailable: ${error.code}');
          },
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (error) {
      debugPrint('Banner unavailable: $error');
    }
  }

  void _showPrivacyOptions() {
    ConsentForm.showPrivacyOptionsForm((error) {
      if (!mounted) return;
      final previous = _ad;
      _generation++;
      setState(() {
        _ad = null;
        _loaded = false;
        _ready = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => previous?.dispose());
      if (error != null) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('광고 개인정보 설정을 열지 못했습니다. 다시 시도해 주세요.')),
        );
      }
      unawaited(_updateConsent());
    });
  }

  @override
  void dispose() {
    _generation++;
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return const SizedBox.shrink();
    return Material(
      color: const Color(0xFF111412),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loaded && _ad != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: SizedBox(
                    width: _ad!.size.width.toDouble(),
                    height: _ad!.size.height.toDouble(),
                    child: AdWidget(key: ObjectKey(_ad), ad: _ad!),
                  ),
                ),
              ),
            if (_privacyRequired)
              TextButton(
                onPressed: _showPrivacyOptions,
                child: const Text('광고 개인정보 설정'),
              ),
          ],
        ),
      ),
    );
  }
}
