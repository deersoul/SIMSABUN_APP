# 상단 AdMob 배너 (1.0.5+5)

스플래시 3초가 끝난 후 웹뷰 위에 고정 적응형 배너를 표시합니다. 웹뷰와 광고는 별도 영역이며, 광고 로드 실패 시 광고 영역을 숨깁니다.

- 운영 앱 ID: `ca-app-pub-4313861436734901~9349688979`
- 운영 배너 ID: `ca-app-pub-4313861436734901/4552482858`
- debug/profile: Google 테스트 앱 ID 및 테스트 배너 ID
- release: 위 운영 ID
- LottoRecommend의 UMP 동의 확인, 필요한 지역의 개인정보 설정 진입점, 테스트/운영 분리 방식을 참고했습니다.
- Flutter 3.32.5 / Dart 3.8.1과 호환되는 google_mobile_ads 6.0.0을 사용합니다.

## 빌드

프로젝트 최상단에서 `flutter build appbundle --release`를 실행합니다. 기존 `android/key.properties` 서명 설정을 사용합니다.

현재 PC의 Android Studio 2026 설치가 Java 25를 선택하면 기존 Gradle에서 빌드가 실패합니다. 이 경우 Flutter용 JDK를 설치된 Java 17로 지정한 후 빌드하세요:

```powershell
flutter config --jdk-dir="C:\Program Files\Java\jdk-17"
flutter build appbundle --release
```

위 config 명령은 이 PC의 Flutter 설정을 변경합니다. 이번 빌드는 전역 설정을 바꾸지 않고 해당 프로세스의 JAVA_HOME을 Java 17로 지정한 뒤 android 폴더에서 `gradlew.bat bundleRelease --no-daemon`으로 완료하도록 구성했습니다.

결과: `build/app/outputs/bundle/release/app-release.aab`.

## AdMob / Play Console

AdMob의 개인정보 보호 및 메시지에서 필요한 동의 메시지를 설정하세요. UMP가 광고 요청 가능 여부를 확인한 뒤에만 SDK를 초기화합니다. 실제 광고 송출은 AdMob 앱 승인, 광고 재고 및 동의 설정에 따라 달라집니다.
Play Console의 광고 포함 여부와 데이터 보안/개인정보처리방침을 광고 SDK 사용에 맞게 검토하세요. 개발자 웹사이트의 app-ads.txt도 해당 AdMob 계정 안내에 따라 설정하세요.

참고: https://developers.google.com/admob/flutter/privacy
