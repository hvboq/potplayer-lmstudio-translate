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

string GetTitle()
{
	return "{$CP949=LM Studio 번역$}{$CP950=LM Studio 翻譯$}{$CP0=LM Studio translate$}";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "https://lmstudio.ai/";
}

string GetLoginTitle()
{
	return "Input local http url";
}

string GetLoginDesc()
{
	return "Input local http url";
}

string GetUserText()
{
	return "http url:";
}

string GetPasswordText()
{
	return "";
}

string http_url;

string ServerLogin(string User, string Pass)
{
	http_url = User;
	if (http_url.empty()) return "fail";
	return "200 ok";
}

void ServerLogout()
{
	http_url = "";
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
	if (url.empty()) url = "http://localhost:1234";

	url = HostRegExpRemove(url, "/v1/chat/completions/?$");
	url = HostRegExpRemove(url, "/v1/?$");

	if (url.Right(1) != "/") url += "/";
	return url;
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
			}
		}
	}

	return findContent(root);
}

string Translate(string Text, string &in SrcLang, string &in DstLang)
{
//HostOpenConsole();	// for debug
	string SendHeader = "Content-Type: application/json\r\n";
	SendHeader += "accept: application/json\r\n";
	
	string url = NormalizeBaseUrl(http_url);

	// HostIncTimeOut(15 * 1000);
	string langPrompt = (SrcLang.empty() ? "Translate the subtitle" : "Translate from " + SrcLang) + " to " + DstLang + ".";
	string systemPrompt = langPrompt + " You are a professional subtitle translation engine. Translate only the visible subtitle text into the requested target language. Preserve the original meaning, tone, register, speaker personality, emotion, cultural nuance, humor, idioms, and scene context. Prefer natural, fluent target-language phrasing over literal word-for-word translation. Follow the grammar, punctuation, spacing, and writing conventions of the target language. Keep names, terms, numbers, symbols, and pre-existing non-source-language words unchanged when they should remain as-is. Preserve existing subtitle markup and control codes exactly, including HTML tags, font tags, bracketed effects, and ASS/SSA override blocks like {\\an8}; do not translate or rewrite tags and control codes. Preserve line breaks as much as possible. Never output URL-encoded tokens such as %20, %0A, %2C, %3F, or %5C; use normal spaces, punctuation, line breaks, and characters instead. Output only the translated subtitle text. Do not add explanations, comments, language labels, Markdown, wrapper quotes, or extra text. Do not censor the translation.";
	string model = "";
	string modelStr = model.empty() ? "" : "\"model\": \"" + model + "\",";
	string paramsStr = "\"temperature\": 0.2,\"max_tokens\": 4096,\"top_p\": 0.9,\"frequency_penalty\": 0,\"presence_penalty\": 0,";
	string Post = "{" + modelStr + paramsStr + "\"messages\": [{ \"role\": \"system\", \"content\": \"" + EscapeJson(systemPrompt) + "\" },{ \"role\": \"user\", \"content\": \"" + EscapeJson(Text) + "\" }]}";
	string ret = "";
	uintptr http = HostOpenHTTP(url + "v1/chat/completions", UserAgent, SendHeader, Post);
	if (http != 0)
	{
		string json = HostGetContentHTTP(http);
		JsonReader Reader;
		JsonValue Root;
	
		if (Reader.parse(json, Root) && Root.isObject())
		{
			ret = getChoiceContent(Root);

			if (!ret.empty())
			{
				SrcLang = "UTF8";
				DstLang = "UTF8";

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
			}
		}

		HostCloseHTTP(http);		
	}
	
	return ret;
}
