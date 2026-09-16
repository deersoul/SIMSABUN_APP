# 심령사진 분류 아르바이트 · SIMSABUN

Android 전용 Flutter 웹뷰 앱입니다.

## 동작

- 앱 로고와 제목을 Flutter 첫 화면부터 3초 동안 표시합니다.
- 스플래시 뒤에서 https://deersoul6662.xyz 를 미리 로딩합니다.
- 상단 상태바와 하단 시스템 탐색바를 숨기는 전체 화면입니다. Android 시스템 제스처로 일시적으로 표시될 수 있습니다.
- 앱 툴바 없이 웹뷰가 화면을 채웁니다.
- 뒤로 가기는 웹뷰 방문 기록으로 이동하고, 기록이 없으면 앱을 닫습니다.
- 네트워크 오류 화면에서 다시 시도할 수 있습니다.
- Android 12 이상에서 OS 시작 화면은 같은 녹색 배경만 잠깐 표시합니다. OS의 원형 아이콘 마스킹을 피하고 Flutter 스플래시에서 로고 전체와 제목을 표시합니다. 3초는 Flutter 스플래시가 표시된 시점부터 계산합니다.

## 실행 및 AAB 생성

### Android Studio에서 실행

1. Android Studio의 Plugins에서 Flutter 플러그인을 설치합니다(Dart도 함께 설치).
2. Open으로 `C:\Users\ymshin\FlutterProjects\SIMSABUN` 폴더를 엽니다. `android` 하위 폴더가 아닌 프로젝트 루트를 선택합니다.
3. Flutter SDK 경로를 요구하면 `C:\flutter`를 지정합니다.
4. 내장 터미널에서 `flutter pub get`을 실행합니다.
5. Device Manager에서 Android 에뮬레이터를 생성하고 시작하거나, USB 디버깅을 켠 실제 Android 폰을 연결합니다.
6. 실행 장치를 선택하고 `lib/main.dart`를 연 뒤 Run(초록색 삼각형)을 누릅니다.

Android SDK 관련 오류는 SDK Manager → SDK Tools에서 Android SDK Command-line Tools (latest), Platform-Tools를 확인합니다.
라이선스 요청이 있으면 터미널에서 `flutter doctor --android-licenses`를 실행하여 내용을 검토하고 동의합니다.

### 릴리스 번들

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
flutter build appbundle --release
```

결과: `build/app/outputs/bundle/release/app-release.aab`

- 패키지 ID: `xyz.deersoul6662.simsabun`
- 최소 Android 7.0(API 24), 대상 Android 16(API 36)
- 버전: `pubspec.yaml`의 `1.0.0+1`. 후속 업로드 시 `+` 뒤 빌드 번호를 증가시킵니다.
- AAB는 Google Play 업로드용입니다. 기기에 직접 설치하려면 APK 또는 bundletool을 사용합니다.

## 업로드 키

이 프로젝트용 업로드 키는 `android/upload-keystore.jks`, 서명 설정은
`android/key.properties`에 있습니다. 두 파일을 안전한 별도 위치에 함께 백업하세요.
암호는 설정 파일에만 저장되며, 두 파일은 Git에서 제외되어 있습니다.
릴리스 빌드는 이 키를 사용하고 디버그 키로 대체하지 않습니다.
다른 PC에서는 두 파일을 같은 위치에 복원하면 됩니다.

## 디자인과 폰트

- 로고: 웹사이트 메인의 교실 사진을 참조한 빈티지 사진 디자인.
- 앱 색상: 짙은 녹색 `#111412`, 세이지 `#AAB69D`, 아이보리 `#EDF0E7`.
- 스플래시/앱 안내 폰트: 나눔명조 Regular. 원본 폰트 파일을 변형 없이 포함합니다.
- 나눔명조는 SIL Open Font License 1.1로 상업적 이용과 소프트웨어 동봉이 허용됩니다.
- 라이선스/저작권 전문은 `assets/fonts/OFL.txt`이며 앱에도 함께 포함됩니다.
- 웹뷰 내부는 호스팅된 사이트 자체 폰트(Noto Serif KR)를 사용합니다.

폰트 출처: https://github.com/google/fonts/tree/main/ofl/nanummyeongjo
폰트 라이선스: https://raw.githubusercontent.com/google/fonts/main/ofl/nanummyeongjo/OFL.txt

## 수정 위치

- URL, 제목, 스플래시 시간/화면: `lib/main.dart`
- 로고: `assets/branding/logo.png`
- Android 전체 화면 복원: `android/app/src/main/kotlin/xyz/deersoul6662/simsabun/MainActivity.kt`
- 릴리스 서명/SDK: `android/app/build.gradle.kts`
- 로고 제작 기록: `assets/branding/README.md`

스플래시 미리보기 생성: `flutter test tools/render_splash_test.dart`
결과: `build/previews/splash.png`
