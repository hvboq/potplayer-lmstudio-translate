/*
	Real time subtitle translate for PotPlayer using ChatGPT API
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 														-> get title for UI
// string GetVersion														-> get version for manage
// string GetDesc()															-> get detail information
// string GetLoginTitle()													-> get title for login dialog
// string GetLoginDesc()													-> get desc for login dialog
// string GetUserText()														-> get user text for login dialog
// string GetPasswordText()													-> get password text for login dialog
// string ServerLogin(string User, string Pass)								-> login
// string ServerLogout()													-> logout
//------------------------------------------------------------------------------------------------
// array<string> GetSrcLangs() 												-> get source language
// array<string> GetDstLangs() 												-> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang) 	-> do translate !!

array<string> LangTable = 
{
	"",
	"Albanian",
	"Arabic",
	"Armenian",
	"Awadhi",
	"Azerbaijani",
	"Bashkir",
	"Basque",
	"Belarusian",
	"Bengali",
	"Bhojpuri",
	"Bosnian",
	"Brazilian Portuguese",
	"Bulgarian",
	"Cantonese",
	"Catalan",
	"Chhattisgarhi",
	"Chinese",
	"Croatian",
	"Czech",
	"Danish",
	"Dogri",
	"Dutch",
	"English",
	"Estonian",
	"Faroese",
	"Finnish",
	"French",
	"Galician",
	"Georgian",
	"German",
	"Greek",
	"Gujarati",
	"Haryanvi",
	"Hebrew",
	"Hindi",
	"Hungarian",
	"Indonesian",
	"Irish",
	"Italian",
	"Japanese",
	"Javanese",
	"Kannada",
	"Kashmiri",
	"Kazakh",
	"Konkani",
	"Korean",
	"Kyrgyz",
	"Latvian",
	"Lithuanian",
	"Macedonian",
	"Maithili",
	"Malay",
	"Maltese",
	"Mandarin",
	"Mandarin Chinese",
	"Marathi",
	"Marwari",
	"Min Nan",
	"Moldovan",
	"Mongolian",
	"Montenegrin",
	"Nepali",
	"Norwegian",
	"Oriya",
	"Pashto",
	"Persian",
	"Polish",
	"Portuguese",
	"Punjabi",
	"Rajasthani",
	"Romanian",
	"Russian",
	"Sanskrit",
	"Santali",
	"Serbian",
	"Sindhi",
	"Sinhala",
	"Slovak",
	"Slovene",
	"Slovenian",
	"Spanish",
	"Swedish",
	"Turkish",
	"Ukrainian",
	"Urdu",
	"Uzbek",
	"Vietnamese",
	"Welsh"
};

string UserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";

// User-editable defaults.
// The login dialog can override DefaultBaseUrl, DefaultModel, and ApiKey at runtime.
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

array<string> ProtectionTokens =
{
	"__POT_TAG_A__",
	"__POT_TAG_B__",
	"__POT_TAG_C__",
	"__POT_TAG_D__",
	"__POT_TAG_E__",
	"__POT_TAG_F__",
	"__POT_TAG_G__",
	"__POT_TAG_H__",
	"__POT_TAG_I__",
	"__POT_TAG_J__",
	"__POT_TAG_K__",
	"__POT_TAG_L__",
	"__POT_TAG_M__",
	"__POT_TAG_N__",
	"__POT_TAG_O__",
	"__POT_TAG_P__",
	"__POT_TAG_Q__",
	"__POT_TAG_R__",
	"__POT_TAG_S__",
	"__POT_TAG_T__",
	"__POT_TAG_U__",
	"__POT_TAG_V__",
	"__POT_TAG_W__",
	"__POT_TAG_X__",
	"__POT_TAG_Y__",
	"__POT_TAG_Z__"
};

string GetTitle()
{
	return "{$CP949=LM Studio 번역$}{$CP950=LM Studio 翻譯$}{$CP0=LM Studio translate$}";
}

string GetVersion()
{
	return "2";
}

string GetDesc()
{
	return "https://lmstudio.ai/";
}

string GetLoginTitle()
{
	return "LM Studio server";
}

string GetLoginDesc()
{
	return "Input OpenAI-compatible server URL. Optional password field: model=name;key=api-key";
}

string GetUserText()
{
	return "http url:";
}

string GetPasswordText()
{
	return "options:";
}

string http_url;
string runtime_model;
string api_key;
string last_error;
array<string> CacheKeys;
array<string> CacheValues;

string GetOptionValue(string options, string name)
{
	string key = name + "=";
	int start = options.find(key);
	if (start < 0) return "";

	start += key.length();
	int end = options.find(";", start);
	if (end < 0) end = options.length();

	string value = options.substr(start, end - start);
	value.Trim();
	return value;
}

string DebugReturn(string message)
{
	if (DebugMode) return "[LM Studio translator] " + message;
	return "";
}

string BuildCacheKey(string url, string text, string SrcLang, string DstLang)
{
	return url + "\n" + runtime_model + "\n" + SrcLang + "\n" + DstLang + "\n" + text;
}

string GetCachedTranslation(string key)
{
	if (!EnableSubtitleCache) return "";

	for (int i = 0, len = CacheKeys.size(); i < len; i++)
	{
		if (CacheKeys[i] == key) return CacheValues[i];
	}

	return "";
}

void PutCachedTranslation(string key, string value)
{
	if (!EnableSubtitleCache || key.empty() || value.empty()) return;

	for (int i = 0, len = CacheKeys.size(); i < len; i++)
	{
		if (CacheKeys[i] == key)
		{
			CacheValues[i] = value;
			return;
		}
	}

	while (CacheKeys.size() >= MaxCacheItems && CacheKeys.size() > 0)
	{
		CacheKeys.removeAt(0);
		CacheValues.removeAt(0);
	}

	CacheKeys.insertLast(key);
	CacheValues.insertLast(value);
}

string ProtectMarkup(string text, array<string> &inout protectedParts)
{
	if (!ProtectSubtitleMarkup) return text;

	string ret = "";
	int pos = 0;

	while (pos < text.length())
	{
		int htmlStart = text.find("<", pos);
		int assStart = text.find("{\\", pos);
		int start = -1;
		string closeMark = "";

		if (htmlStart >= 0 && (assStart < 0 || htmlStart < assStart))
		{
			start = htmlStart;
			closeMark = ">";
		}
		else if (assStart >= 0)
		{
			start = assStart;
			closeMark = "}";
		}

		if (start < 0)
		{
			ret += text.substr(pos);
			break;
		}

		if (protectedParts.size() >= ProtectionTokens.size())
		{
			ret += text.substr(pos);
			break;
		}

		int end = text.find(closeMark, start);
		if (end < 0)
		{
			ret += text.substr(pos);
			break;
		}

		ret += text.substr(pos, start - pos);
		string token = ProtectionTokens[protectedParts.size()];
		protectedParts.insertLast(text.substr(start, end - start + 1));
		ret += token;
		pos = end + 1;
	}

	return ret;
}

string RestoreMarkup(string text, array<string> &in protectedParts)
{
	if (!ProtectSubtitleMarkup) return text;

	for (int i = 0, len = protectedParts.size(); i < len; i++)
	{
		text.replace(ProtectionTokens[i], protectedParts[i]);
	}

	return text;
}

bool MissingProtectedToken(string text, array<string> &in protectedParts)
{
	if (!ProtectSubtitleMarkup) return false;

	for (int i = 0, len = protectedParts.size(); i < len; i++)
	{
		if (text.find(ProtectionTokens[i]) < 0) return true;
	}

	return false;
}

string ServerLogin(string User, string Pass)
{
	http_url = User;
	http_url.Trim();
	runtime_model = DefaultModel;
	api_key = "";
	while (CacheKeys.size() > 0) CacheKeys.removeAt(0);
	while (CacheValues.size() > 0) CacheValues.removeAt(0);

	string options = Pass;
	options.Trim();
	if (!options.empty())
	{
		string model = GetOptionValue(options, "model");
		string key = GetOptionValue(options, "key");
		if (key.empty()) key = GetOptionValue(options, "apiKey");
		if (key.empty()) key = GetOptionValue(options, "api_key");

		if (model.empty() && key.empty())
		{
			api_key = options;
		}
		else
		{
			if (!model.empty()) runtime_model = model;
			if (!key.empty()) api_key = key;
		}
	}

	return "200 ok";
}

void ServerLogout()
{
	http_url = "";
	runtime_model = "";
	api_key = "";
	while (CacheKeys.size() > 0) CacheKeys.removeAt(0);
	while (CacheValues.size() > 0) CacheValues.removeAt(0);
}

array<string> GetSrcLangs()
{
	array<string> ret = LangTable;
	
	return ret;
}

array<string> GetDstLangs()
{
	array<string> ret = LangTable;
	
	ret.erase(0);
	return ret;
}

string findContent(JsonValue node)
{
	if (node.isObject())
	{
		JsonValue content = node["content"];
	        if (content.isString()) return content.asString();

		array<string> keys = node.getKeys();
		for(int i = 0, len = keys.size(); i < len; i++)
		{
			string ret = findContent(node[keys[i]]);
		
			if (!ret.empty()) return ret;
		}

	}
	else if (node.isArray())
	{
		for (int i = 0; i < node.size(); i++)
		{
			string ret = findContent(node[i]);
		
			if (!ret.empty()) return ret;
        }
	}
	return "";
}

string EscapeJson(string text)
{
	text.replace("\\", "\\\\");
	text.replace("\"", "\\\"");
	text.replace("\r", "\\r");
	text.replace("\n", "\\n");
	text.replace("\t", "\\t");
	return text;
}

string DecodeCommonUrlEscapes(string text)
{
	text.replace("%25", "%");
	text.replace("%09", "\t");
	text.replace("%0A", "\n");
	text.replace("%0a", "\n");
	text.replace("%0D", "\r");
	text.replace("%0d", "\r");
	text.replace("%20", " ");
	text.replace("%21", "!");
	text.replace("%22", "\"");
	text.replace("%23", "#");
	text.replace("%24", "$");
	text.replace("%26", "&");
	text.replace("%27", "'");
	text.replace("%28", "(");
	text.replace("%29", ")");
	text.replace("%2A", "*");
	text.replace("%2a", "*");
	text.replace("%2B", "+");
	text.replace("%2b", "+");
	text.replace("%2C", ",");
	text.replace("%2c", ",");
	text.replace("%2D", "-");
	text.replace("%2d", "-");
	text.replace("%2E", ".");
	text.replace("%2e", ".");
	text.replace("%2F", "/");
	text.replace("%2f", "/");
	text.replace("%3A", ":");
	text.replace("%3a", ":");
	text.replace("%3B", ";");
	text.replace("%3b", ";");
	text.replace("%3D", "=");
	text.replace("%3d", "=");
	text.replace("%3F", "?");
	text.replace("%3f", "?");
	text.replace("%40", "@");
	text.replace("%5B", "[");
	text.replace("%5b", "[");
	text.replace("%5C", "\\");
	text.replace("%5c", "\\");
	text.replace("%5D", "]");
	text.replace("%5d", "]");
	text.replace("%7B", "{");
	text.replace("%7b", "{");
	text.replace("%7D", "}");
	text.replace("%7d", "}");
	return text;
}

string NormalizeBaseUrl(string url)
{
	url.Trim();
	if (url.empty()) url = DefaultBaseUrl;

	url = HostRegExpRemove(url, "/v1/chat/completions/?$");
	url = HostRegExpRemove(url, "/v1/?$");

	if (url.Right(1) != "/") url += "/";
	return url;
}

string BuildSendHeader()
{
	string header = "Content-Type: application/json\r\n";
	header += "accept: application/json\r\n";
	if (!api_key.empty()) header += "Authorization: Bearer " + api_key + "\r\n";
	return header;
}

string getChoiceContent(JsonValue root)
{
	if (root.isObject())
	{
		JsonValue choices = root["choices"];
		if (choices.isArray() && choices.size() > 0)
		{
			JsonValue choice = choices[0];
			if (choice.isObject())
			{
				JsonValue message = choice["message"];
				if (message.isObject())
				{
					JsonValue content = message["content"];
					if (content.isString()) return content.asString();
				}

				JsonValue text = choice["text"];
				if (text.isString()) return text.asString();

				JsonValue delta = choice["delta"];
				if (delta.isObject())
				{
					JsonValue deltaContent = delta["content"];
					if (deltaContent.isString()) return deltaContent.asString();
				}
			}
		}
	}

	return findContent(root);
}

string getErrorMessage(JsonValue root)
{
	if (root.isObject())
	{
		JsonValue error = root["error"];
		if (error.isObject())
		{
			JsonValue message = error["message"];
			if (message.isString()) return message.asString();
		}
		else if (error.isString())
		{
			return error.asString();
		}
	}
	return "";
}

string BuildSystemPrompt(string langPrompt, bool retryMode)
{
	string prompt = langPrompt + " You are a professional subtitle translation engine. Translate only the visible subtitle text into the requested target language. Preserve the original meaning, tone, register, speaker personality, emotion, cultural nuance, humor, idioms, and scene context. Prefer natural, fluent target-language phrasing over literal word-for-word translation. Follow the grammar, punctuation, spacing, and writing conventions of the target language. Keep names, terms, numbers, symbols, and pre-existing non-source-language words unchanged when they should remain as-is. Preserve existing subtitle markup and control codes exactly, including HTML tags, font tags, bracketed effects, and ASS/SSA override blocks like {\\an8}; do not translate or rewrite tags and control codes. Preserve line breaks as much as possible. Never output URL-encoded tokens such as %20, %0A, %2C, %3F, or %5C; use normal spaces, punctuation, line breaks, and characters instead. Output only the translated subtitle text. Do not add explanations, comments, language labels, Markdown, wrapper quotes, or extra text. Do not censor the translation.";

	if (ProtectSubtitleMarkup)
	{
		prompt += " The source may contain placeholder tokens such as __POT_TAG_A__; copy every placeholder token exactly and do not translate, remove, split, or reorder it.";
	}

	if (retryMode)
	{
		prompt += " Retry with stricter formatting: return only the corrected translated subtitle text, preserve all placeholders exactly, and remove any explanatory prefix, Markdown, wrapper quote, or URL-encoded token.";
	}

	return prompt;
}

string BuildPostBody(string systemPrompt, string userText)
{
	string model = runtime_model;
	string modelStr = model.empty() ? "" : "\"model\": \"" + model + "\",";
	string paramsStr = "\"temperature\": " + RequestTemperature + ",\"max_tokens\": " + RequestMaxTokens + ",\"top_p\": " + RequestTopP + ",\"frequency_penalty\": " + RequestFrequencyPenalty + ",\"presence_penalty\": " + RequestPresencePenalty + ",";
	return "{" + modelStr + paramsStr + "\"messages\": [{ \"role\": \"system\", \"content\": \"" + EscapeJson(systemPrompt) + "\" },{ \"role\": \"user\", \"content\": \"" + EscapeJson(userText) + "\" }]}";
}

string SendTranslationRequest(string url, string SendHeader, string systemPrompt, string userText)
{
	last_error = "";

	string Post = BuildPostBody(systemPrompt, userText);
	uintptr http = HostOpenHTTP(url + "v1/chat/completions", UserAgent, SendHeader, Post);
	if (http == 0)
	{
		last_error = "HTTP request failed: " + url + "v1/chat/completions";
		return "";
	}

	string json = HostGetContentHTTP(http);
	JsonReader Reader;
	JsonValue Root;
	string ret = "";

	if (Reader.parse(json, Root) && Root.isObject())
	{
		ret = getChoiceContent(Root);
		if (ret.empty())
		{
			string error = getErrorMessage(Root);
			if (!error.empty()) last_error = "API error: " + error;
			else last_error = "No translation content in response.";
		}
	}
	else
	{
		last_error = "Could not parse JSON response.";
	}

	HostCloseHTTP(http);
	return ret;
}

string CleanTranslatedText(string ret)
{
	ret.replace("<br/>", "\n");
	ret.replace("<br />", "\n");
	ret.replace("<br  />", "\n");
	ret = DecodeCommonUrlEscapes(ret);
	ret.replace("\r\n", "\n");
	ret.replace("\r", "\n");
	ret.replace("\n\n", "\n");
	ret.replace("\n\n", "\n");
	ret.Trim();

	ret = HostRegExpRemove(ret, "^(Here is|Here's) [a-zA-Z ,]+:");
	return ret;
}

bool ContainsUrlEncodedToken(string text)
{
	if (text.find("%20") >= 0 || text.find("%0A") >= 0 || text.find("%0a") >= 0) return true;
	if (text.find("%0D") >= 0 || text.find("%0d") >= 0 || text.find("%2C") >= 0 || text.find("%2c") >= 0) return true;
	if (text.find("%3F") >= 0 || text.find("%3f") >= 0 || text.find("%5C") >= 0 || text.find("%5c") >= 0) return true;
	return false;
}

bool HasInstructionalWrapper(string text)
{
	string probe = text;
	probe.Trim();
	string lower = probe;
	lower.MakeLower();

	if (lower.find("here is") == 0 || lower.find("here's") == 0) return true;
	if (lower.find("translation:") == 0 || lower.find("translated text:") == 0) return true;
	if (lower.find("translated subtitle:") == 0 || lower.find("output:") == 0) return true;
	if (probe.find("```") >= 0) return true;
	return false;
}

bool NeedsQualityRetry(string raw, string cleaned, array<string> &in protectedParts)
{
	if (!EnableQualityRetry) return false;
	if (raw.empty() || cleaned.empty()) return false;

	if (ContainsUrlEncodedToken(raw)) return true;
	if (HasInstructionalWrapper(raw)) return true;
	if (MissingProtectedToken(raw, protectedParts)) return true;

	return false;
}

string Translate(string Text, string &in SrcLang, string &in DstLang)
{
	if (DebugMode) HostOpenConsole();
	string SendHeader = BuildSendHeader();
	
	string url = NormalizeBaseUrl(http_url);

	if (EnableRequestTimeout) HostIncTimeOut(RequestTimeoutMs);

	string cacheKey = BuildCacheKey(url, Text, SrcLang, DstLang);
	string cached = GetCachedTranslation(cacheKey);
	if (!cached.empty())
	{
		SrcLang = "UTF8";
		DstLang = "UTF8";
		return cached;
	}

	array<string> protectedParts;
	string requestText = ProtectMarkup(Text, protectedParts);
	string langPrompt = (SrcLang.empty() ? "Translate the subtitle" : "Translate from " + SrcLang) + " to " + DstLang + ".";
	string raw = SendTranslationRequest(url, SendHeader, BuildSystemPrompt(langPrompt, false), requestText);
	string ret = raw.empty() ? "" : CleanTranslatedText(raw);

	if (NeedsQualityRetry(raw, ret, protectedParts))
	{
		for (int i = 0; i < MaxQualityRetries; i++)
		{
			string retryRaw = SendTranslationRequest(url, SendHeader, BuildSystemPrompt(langPrompt, true), requestText);
			string retryRet = retryRaw.empty() ? "" : CleanTranslatedText(retryRaw);

			if (!retryRet.empty())
			{
				raw = retryRaw;
				ret = retryRet;
				if (!NeedsQualityRetry(raw, ret, protectedParts)) break;
			}
		}
	}

	if (ret.empty()) ret = DebugReturn(last_error);
	else
	{
		ret = RestoreMarkup(ret, protectedParts);
		SrcLang = "UTF8";
		DstLang = "UTF8";
		PutCachedTranslation(cacheKey, ret);
	}
	
	return ret;
}
