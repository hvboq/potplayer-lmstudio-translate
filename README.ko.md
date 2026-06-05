# PotPlayer LM Studio 자막 번역 확장

LM Studio의 OpenAI 호환 로컬 서버를 사용하는 PotPlayer 자막 번역 확장입니다.

## 주요 기능

- 로컬 LM Studio 서버의 `POST /v1/chat/completions` 사용
- `http://localhost:1234`, `/v1`, `/v1/chat/completions` 형태의 URL 자동 정규화
- 자막 원문을 URL 인코딩하지 않고 JSON escape만 적용
- `%20`, `%0A`, `%2C`, `%3F`, `%5C` 같은 URL 인코딩 흔적 후처리
- HTML 태그와 ASS/SSA 제어코드 보호
- 이상 출력 감지 시 선택적 자동 재시도
- 반복 자막 캐시로 중복 요청 감소
- 선택적 모델명과 Bearer API key 지원
- 설치 스크립트와 릴리즈 zip 생성 스크립트 포함

## 요구 사항

- Windows용 PotPlayer
- 로컬 서버가 켜진 LM Studio
- LM Studio에 로드된 chat/instruct 모델

## 설치

저장소 폴더에서 PowerShell을 관리자 권한으로 실행한 뒤:

```powershell
.\install_lmstudio_translator.ps1
```

설치 스크립트는 기존 PotPlayer 확장 파일을 자동 백업합니다.

```text
C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate\SubtitleTranslate - LM Studio.as.bak-codex-yyyyMMdd-HHmmss
```

설치 후 PotPlayer를 재시작하세요.

## LM Studio 설정

1. LM Studio를 엽니다.
2. 사용할 chat/instruct 모델을 로드합니다.
3. Local Server를 시작합니다.
4. PotPlayer에서 `LM Studio translate` 자막 번역 확장을 선택합니다.
5. 로그인 창의 URL 칸에 서버 주소를 입력합니다.

자주 쓰는 URL:

```text
http://localhost:1234
http://localhost:1234/v1
http://localhost:1234/v1/chat/completions
```

## 로그인 옵션

첫 번째 입력 칸은 서버 URL입니다.

두 번째 입력 칸은 선택 사항이며 세미콜론으로 구분한 옵션을 받을 수 있습니다.

```text
model=your-model-name
key=your-api-key
model=your-model-name;key=your-api-key
```

`model=` 또는 `key=` 없이 텍스트만 입력하면 API key로 처리합니다.

LM Studio는 보통 API key가 필요 없습니다. `key=` 옵션은 다른 OpenAI 호환 서버를 사용할 때 유용합니다.

## 주요 설정

`SubtitleTranslate - LM Studio.as` 상단에서 기본값을 수정할 수 있습니다.

```angelscript
string DefaultBaseUrl = "http://localhost:1234";
string DefaultModel = "";
string RequestTemperature = "0.2";
string RequestMaxTokens = "4096";
string RequestTopP = "0.9";
bool EnableRequestTimeout = true;
int RequestTimeoutMs = 30000;
bool DebugMode = false;
bool ProtectSubtitleMarkup = true;
bool EnableQualityRetry = true;
int MaxQualityRetries = 1;
bool EnableSubtitleCache = true;
int MaxCacheItems = 256;
```

설정 메모:

- `DefaultModel`을 비워두면 LM Studio에서 현재 로드된 모델을 사용합니다.
- `ProtectSubtitleMarkup`은 `<i>`, `</font>`, `{\\an8}` 같은 자막 태그를 임시 토큰으로 보호합니다.
- `EnableQualityRetry`는 `%20`, 설명문, Markdown, 보호 토큰 누락 같은 이상 출력이 감지될 때 한 번 더 요청합니다.
- `EnableSubtitleCache`는 같은 자막이 반복될 때 이전 번역을 재사용합니다.
- `DebugMode`는 문제를 찾을 때만 켜세요. 실패 메시지가 자막으로 보일 수 있습니다.

## 릴리즈 zip 만들기

```powershell
.\build_release.ps1
```

출력:

```text
dist\potplayer-lmstudio-translate.zip
```

## 문제 해결

### 번역이 나오지 않을 때

- LM Studio Local Server가 켜져 있는지 확인하세요.
- 모델이 로드되어 있는지 확인하세요.
- URL은 우선 `http://localhost:1234`로 시도하세요.
- 확장 파일 교체 후 PotPlayer를 재시작하세요.
- 필요하면 `DebugMode = true`로 바꿔 원인을 확인하세요.

### 다른 OpenAI 호환 서버를 사용할 때 실패하는 경우

- 두 번째 입력 칸에 `key=...`를 입력하세요.
- 서버가 모델명을 요구하면 `model=...`을 입력하세요.
- 서버가 `/v1/chat/completions`를 지원하는지 확인하세요.

### `%20` 같은 문자가 계속 보일 때

이 확장은 원문 URL 인코딩을 하지 않고, 흔한 URL escape를 후처리합니다. 그래도 모델이 인코딩된 출력을 계속 만들면 더 낮은 temperature나 다른 모델을 사용해 보세요.
