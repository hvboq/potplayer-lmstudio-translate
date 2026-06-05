# PotPlayer LM Studio Subtitle Translator

PotPlayer subtitle translation extension for LM Studio's OpenAI-compatible local server.

Korean documentation: [README.ko.md](README.ko.md)

## Features

- Uses `POST /v1/chat/completions` on a local LM Studio server.
- Accepts base URLs such as `http://localhost:1234`, `/v1`, or `/v1/chat/completions`.
- Sends subtitle text without URL-encoding it first.
- Escapes JSON safely before sending requests.
- Preserves subtitle markup and control codes such as HTML tags and ASS/SSA override blocks.
- Strongly discourages URL-encoded output tokens such as `%20`, `%0A`, `%2C`, `%3F`, and `%5C`.
- Keeps the prompt language-agnostic so it can be used for many source and target languages.
- Supports optional model selection and Bearer API keys.
- Protects subtitle tags/control codes with temporary placeholders before translation.
- Can retry once when the model returns wrappers, Markdown, URL-encoded tokens, or damaged placeholders.
- Caches repeated subtitles to reduce duplicate local model requests.
- Includes installer and release zip helper scripts.

## Requirements

- PotPlayer on Windows.
- LM Studio with the local server enabled.
- A loaded chat model in LM Studio, unless your server accepts an explicit model name.

## Install

Run PowerShell as administrator from this repository folder:

```powershell
.\install_lmstudio_translator.ps1
```

The installer backs up the existing PotPlayer extension before installing:

```text
C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate\SubtitleTranslate - LM Studio.as.bak-codex-yyyyMMdd-HHmmss
```

Restart PotPlayer after installation.

## LM Studio Setup

1. Open LM Studio.
2. Load a chat/instruct model.
3. Start the local server.
4. In PotPlayer, select the `LM Studio translate` subtitle translation extension.
5. Enter your server URL in the login dialog.

Common URL values:

```text
http://localhost:1234
http://localhost:1234/v1
http://localhost:1234/v1/chat/completions
```

The extension normalizes these values internally.

## Login Options

The first login field is the server URL.

The second login field is optional. It supports semicolon-separated options:

```text
model=your-model-name
key=your-api-key
model=your-model-name;key=your-api-key
```

If the second field has text without `model=` or `key=`, the extension treats it as an API key.

LM Studio usually does not require an API key. The `key=` option is mainly useful for other OpenAI-compatible local or private servers.

## Configuration

User-editable defaults live near the top of `SubtitleTranslate - LM Studio.as`:

```angelscript
string DefaultBaseUrl = "http://localhost:1234";
string DefaultModel = "";
string RequestTemperature = "0.2";
string RequestMaxTokens = "4096";
string RequestTopP = "0.9";
string RequestFrequencyPenalty = "0";
string RequestPresencePenalty = "0";
bool EnableRequestTimeout = true;
int RequestTimeoutMs = 30000;
bool DebugMode = false;
bool ProtectSubtitleMarkup = true;
bool EnableQualityRetry = true;
int MaxQualityRetries = 1;
bool EnableSubtitleCache = true;
int MaxCacheItems = 256;
```

Notes:

- Leave `DefaultModel` empty to use the currently loaded LM Studio model.
- Set `DefaultModel` or use `model=...` in the login options when your server requires a model name.
- `ProtectSubtitleMarkup` replaces tags such as `<i>`, `</font>`, and `{\\an8}` with temporary placeholders before translation, then restores them afterward.
- `EnableQualityRetry` retries when output appears to include explanation wrappers, Markdown fences, URL-encoded tokens, or missing protected placeholders.
- `EnableSubtitleCache` reuses translations for repeated subtitle lines with the same URL, model, source language, and target language.
- Enable `DebugMode` only when troubleshooting. In debug mode, failures can be returned as visible diagnostic subtitle text.
- Increase `RequestTimeoutMs` if your model is slow.

## Build Release Zip

Create a small distributable zip:

```powershell
.\build_release.ps1
```

Output:

```text
dist\potplayer-lmstudio-translate.zip
```

The zip includes:

- `SubtitleTranslate - LM Studio.as`
- `install_lmstudio_translator.ps1`
- `README.md`
- `README.ko.md`
- `LICENSE`

## Troubleshooting

### Nothing is translated

- Confirm LM Studio's local server is running.
- Confirm a model is loaded.
- Try `http://localhost:1234` as the URL.
- Restart PotPlayer after replacing the extension file.
- Temporarily set `DebugMode = true` near the top of the script.

### The request fails when using another OpenAI-compatible server

- Add an API key in the second login field with `key=...`.
- Add a required model name with `model=...`.
- Confirm the server supports `/v1/chat/completions`.

### Output contains `%20` or other URL-encoded tokens

The extension already avoids URL-encoding subtitle input and post-processes common URL escape sequences. If a model still produces encoded text, try a different model or lower the temperature.

### Subtitle tags are changed or removed

Keep `ProtectSubtitleMarkup = true`. This protects HTML tags and ASS/SSA override blocks with placeholders before sending text to the model.

### Translation is too slow

- Use a smaller/faster model.
- Reduce `RequestMaxTokens`.
- Keep `EnableSubtitleCache = true` for repeated subtitle lines.
- Increase `RequestTimeoutMs` if the model eventually responds but needs more time.
