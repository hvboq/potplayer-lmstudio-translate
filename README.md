# PotPlayer LM Studio Subtitle Translator

PotPlayer subtitle translation extension for LM Studio's OpenAI-compatible local server.

## Features

- Uses `POST /v1/chat/completions` on a local LM Studio server.
- Accepts base URLs such as `http://localhost:1234`, `/v1`, or `/v1/chat/completions`.
- Sends subtitle text without URL-encoding it first.
- Escapes JSON safely before sending requests.
- Preserves subtitle markup and control codes such as HTML tags and ASS/SSA override blocks.
- Strongly discourages URL-encoded output tokens such as `%20`, `%0A`, `%2C`, `%3F`, and `%5C`.
- Keeps the prompt language-agnostic so it can be used for many source and target languages.

## Install

Run PowerShell as administrator:

```powershell
.\install_lmstudio_translator.ps1
```

The script backs up the existing PotPlayer extension before installing:

```text
C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate\SubtitleTranslate - LM Studio.as.bak-codex-yyyyMMdd-HHmmss
```

Restart PotPlayer after installation.

## LM Studio

Start LM Studio's local server and enter the server URL in the PotPlayer extension login dialog.

Common values:

```text
http://localhost:1234
http://localhost:1234/v1
http://localhost:1234/v1/chat/completions
```

The extension normalizes these values internally.

## Model

The script leaves the `model` field empty by default so LM Studio can use the currently loaded model. If your server requires an explicit model name, edit this line in `SubtitleTranslate - LM Studio.as`:

```angelscript
string model = "";
```
