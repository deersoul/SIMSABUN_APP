# Google Play 등록 이미지

제작일: 2026-09-16

| Play Console 항목 | 파일 | 규격 |
|---|---|---|
| 앱 아이콘 | app-icon-512.png | 512×512, 32bit PNG, 326KB |
| 그래픽 이미지 | feature-graphic-1024x500.png | 1024×500, 24bit PNG, 1.18MB |
| 휴대전화 스크린샷 | phone-screenshots/*.png (9장 중 선택) | 각각 1080×1920, 24bit PNG, 2.1MB 이하 |

각 항목의 '애셋 추가'에서 해당 PNG 파일을 선택하세요. ZIP 파일 자체를 업로드하지 마세요.

추가 촬영분: 05-splash.png(스플래시), 06-tennis.png(테니스장), 07-apartment.png(아파트 복도), 08-market.png(시장), 09-living-room.png(거실). 휴대전화 스크린샷 항목에는 최대 8장까지 올릴 수 있으므로 전체 9장 중 선택하세요.

스크린샷은 com.ymshin.simsabun 릴리스 APK를 Android 15 에뮬레이터에서 실행하여 직접 촬영했습니다. 메인 메뉴, 사진 분류, 돋보기, 다음 사진 화면입니다. 화면 합성이나 AI 생성 화면이 아닙니다. 촬영 후 에뮬레이터 해상도를 원래대로 복원했습니다.

아이콘은 프로젝트의 assets/branding/logo.png를 사용했습니다. 그래픽 이미지는 사용자가 소유한 교실 사진을 참고하여 OpenAI imagegen으로 생성한 홍보용 아트워크입니다. 생성 후 1024×500 크기 및 불투명 RGB 형식으로 변환했습니다.

공식 규격 참고: https://support.google.com/googleplay/android-developer/answer/9866151

## 그래픽 이미지 생성 프롬프트

Create a polished Google Play feature graphic for a Korean atmospheric horror photo-classification game. Wide landscape composition, EXACT aspect ratio 1024:500 (2.048:1), preferably 2048x1000 canvas. Use the attached user-owned classroom photo as the main visual reference: an empty Korean classroom with desks, windows, chalkboard. Right half features one large aged photographic print of this classroom, softly lit desaturated sage and warm ivory, subtle archive scratches. Left half deep forest-green #111412 to olive #263126 background, restrained and elegant Korean literary horror design. Set the exact Korean title prominently in large elegant Korean Myeongjo serif type, in two lines: '심령사진' then '분류 아르바이트'. Below title in smaller type exact tagline: '평범한 사진 속, 이상현상을 찾아내세요.' Warm ivory title, muted sage tagline. Keep title within x=90..1000 at 2048px scale and all key elements within central 85% canvas. No English SIMSABUN, no developer name, no store badges, no phone frame, no ranking claims, no additional words, no eye motif, no gore. Editorial balanced horizontal composition, professionally typeset, legible at 1024x500. This is marketing artwork, not an app screenshot.
