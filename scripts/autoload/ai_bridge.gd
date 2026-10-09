extends Node
# AIBridge - chiamate IA esterne (Gemini/Groq/Cerebras) via HTTPRequest
# Routing per token size come Hegemonia 1700
# Dark Corporation / Stev

signal ai_response_received(faction_name: String, response: String)
signal ai_error(faction_name: String, error: String)

var _config: Dictionary = {}
var _config_loaded := false
var _pending_requests: Dictionary = {}  # request_id -> {faction, provider}

# Limiti prompt per routing (modello Hegemonia 1700)
const TOKEN_THRESHOLD_LOW := 7000      # sotto -> Cerebras
const TOKEN_THRESHOLD_HIGH := 28000    # sopra -> Gemini
const CHAR_LIMIT_GROQ := 28000         # Groq skip sopra questo limite di caratteri
const MAX_OUTPUT_TOKENS := 500
const MAX_PENDING := 10                # max richieste asincrone contemporanee

# Contatori richieste per provider (rispetta limiti free tier)
var _request_counts: Dictionary = {
	"gemini": 0,
	"groq": 0,
	"cerebras": 0,
	"cohere": 0,
	"openrouter": 0
}
# Limiti giornalieri stimati (free tier)
var _daily_limits: Dictionary = {
	"gemini": 20,        # gemini-3.1-flash-lite: 500, altri flash: 20
	"groq": 1000,
	"cerebras": 14400,
	"cohere": 33,
	"openrouter": 100
}


func _ready() -> void:
	_load_config()


func _load_config() -> void:
	var path = "res://config_api.json"
	if not FileAccess.file_exists(path):
		push_warning("AIBridge: config_api.json non trovato, uso fallback deterministico")
		_config_loaded = false
		return
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_warning("AIBridge: impossibile aprire config_api.json")
		_config_loaded = false
		return
	var text = f.get_as_text()
	f.close()
	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		push_warning("AIBridge: errore parse config_api.json: " + json.get_error_message())
		_config_loaded = false
		return
	_config = json.data
	_config_loaded = true
	print("AIBridge: configurazione caricata (modello: %s)" % str(_config.get("api_model", "n/d")))


# Stima token approssimativa: ~4 caratteri per token
func _estimate_tokens(text: String) -> int:
	return int(text.length() / 4)


# Routing per dimensione prompt (modello Hegemonia 1700)
func _select_provider(prompt: String) -> String:
	var tokens = _estimate_tokens(prompt)
	if tokens < TOKEN_THRESHOLD_LOW and _has_key("cerebras"):
		return "cerebras"
	if prompt.length() <= CHAR_LIMIT_GROQ and _has_key("groq"):
		return "groq"
	if _has_key("gemini"):
		return "gemini"
	if _has_key("groq"):
		return "groq"
	if _has_key("cerebras"):
		return "cerebras"
	if _has_key("openrouter"):
		return "openrouter"
	if _has_key("cohere"):
		return "cohere"
	return ""


func _has_key(provider: String) -> bool:
	if not _config_loaded:
		return false
	match provider:
		"gemini":
			return _config.get("api_key_gemini_1", "") != "" or _config.get("api_key_gemini_2", "") != ""
		"groq":
			return _config.get("api_key_groq", "") != ""
		"cerebras":
			return _config.get("api_key_cerebras", "") != ""
		"cohere":
			return _config.get("api_key_cohere", "") != ""
		"openrouter":
			return _config.get("api_key_openrouter", "") != ""
	return false


func _get_key(provider: String) -> String:
	match provider:
		"gemini":
			var k1 = _config.get("api_key_gemini_1", "")
			var k2 = _config.get("api_key_gemini_2", "")
			# Rotazione chiavi per bilanciare carico
			if k1 != "" and k2 != "":
				return k1 if (_request_counts["gemini"] % 2 == 0) else k2
			return k1 if k1 != "" else k2
		"groq":
			return _config.get("api_key_groq", "")
		"cerebras":
			return _config.get("api_key_cerebras", "")
		"cohere":
			return _config.get("api_key_cohere", "")
		"openrouter":
			return _config.get("api_key_openrouter", "")
	return ""


func _get_model(provider: String) -> String:
	match provider:
		"gemini":
			return _config.get("api_model_gemini", "gemini-3.1-flash-lite")
		"groq":
			return _config.get("api_model_groq", "openai/gpt-oss-120b")
		"cerebras":
			return _config.get("api_model_cerebras", "gpt-oss-120b")
		"cohere":
			return _config.get("api_model_cohere", "command-r")
		"openrouter":
			return _config.get("api_model_openrouter", "meta-llama/llama-3.3-70b-instruct")
	return ""


# Verifica se il provider ha ancora richieste disponibili
func _provider_available(provider: String) -> bool:
	if not _has_key(provider):
		return false
	var count = _request_counts.get(provider, 0)
	var limit = _daily_limits.get(provider, 0)
	if limit > 0 and count >= limit:
		return false
	return true


# Costruisce un prompt compatto per una fazione (rispetta limiti token)
func build_faction_prompt(faction_name: String, context: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("Sei l'IA della nazione %s nell'anno 1000." % faction_name)
	lines.append("Obiettivo: %s" % str(context.get("obiettivo", "sopravvivenza e espansione")))
	lines.append("Comportamento: %s" % str(context.get("comportamento", "bilanciato")))
	lines.append("Risorse: oro=%d cibo=%d armi=%d" % [
		int(context.get("oro", 0)),
		int(context.get("cibo", 0)),
		int(context.get("armi", 0))
	])
	lines.append("Esercito: fanteria=%d cavalleria=%d arcieri=%d navi=%d" % [
		int(context.get("fanteria", 0)),
		int(context.get("cavalleria", 0)),
		int(context.get("arcieri", 0)),
		int(context.get("navi", 0))
	])
	lines.append("Province: %d | Settlements: %d" % [
		int(context.get("province", 0)),
		int(context.get("settlements", 0))
	])
	lines.append("Minacce vicine: %s" % str(context.get("minacce", "nessuna")))
	lines.append("")
	lines.append("Decidi UNA azione strategica tra:")
	lines.append("- costruisci <edificio>")
	lines.append("- recluta <tipo_unita>")
	lines.append("- attacca <provincia>")
	lines.append("- difendi <provincia>")
	lines.append("- alleanza <nazione>")
	lines.append("- commercio <nazione>")
	lines.append("Rispondi con una sola riga nel formato: AZIONE: <comando>")
	return "\n".join(lines)


# Invia prompt asincrono (non bloccante)
func request_ai_decision(faction_name: String, prompt: String) -> void:
	if not _config_loaded:
		emit_signal("ai_error", faction_name, "config non caricato, fallback deterministico")
		return
	if _pending_requests.size() >= MAX_PENDING:
		emit_signal("ai_error", faction_name, "trope richieste pending, fallback deterministico")
		return
	var provider = _select_provider(prompt)
	if provider == "" or not _provider_available(provider):
		emit_signal("ai_error", faction_name, "nessun provider disponibile, fallback deterministico")
		return
	_send_request(faction_name, provider, prompt)


func _send_request(faction_name: String, provider: String, prompt: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	var req_id = str(http.get_instance_id())
	_pending_requests[req_id] = {"faction": faction_name, "provider": provider}
	http.request_completed.connect(_on_request_completed.bind(req_id, http))

	var key = _get_key(provider)
	var model = _get_model(provider)
	var headers: PackedStringArray = []
	var url = ""
	var body = ""

	match provider:
		"gemini":
			url = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s" % [model, key]
			headers = PackedStringArray(["Content-Type: application/json"])
			body = JSON.stringify({
				"contents": [{"parts": [{"text": prompt}]}],
				"generationConfig": {"maxOutputTokens": MAX_OUTPUT_TOKENS}
			})
		"groq":
			url = "https://api.groq.com/openai/v1/chat/completions"
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer %s" % key
			])
			body = JSON.stringify({
				"model": model,
				"messages": [{"role": "user", "content": prompt}],
				"max_tokens": MAX_OUTPUT_TOKENS
			})
		"cerebras":
			url = "https://api.cerebras.ai/v1/chat/completions"
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer %s" % key
			])
			body = JSON.stringify({
				"model": model,
				"messages": [{"role": "user", "content": prompt}],
				"max_tokens": MAX_OUTPUT_TOKENS
			})
		"openrouter":
			url = "https://openrouter.ai/api/v1/chat/completions"
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer %s" % key
			])
			body = JSON.stringify({
				"model": model,
				"messages": [{"role": "user", "content": prompt}],
				"max_tokens": MAX_OUTPUT_TOKENS
			})
		"cohere":
			url = "https://api.cohere.ai/v1/chat"
			headers = PackedStringArray([
				"Content-Type: application/json",
				"Authorization: Bearer %s" % key
			])
			body = JSON.stringify({
				"model": model,
				"message": prompt,
				"max_tokens": MAX_OUTPUT_TOKENS
			})

	var err = http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		emit_signal("ai_error", faction_name, "errore HTTPRequest: %d" % err)
		_pending_requests.erase(req_id)
		http.queue_free()
		return
	_request_counts[provider] += 1


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, req_id: String, http: HTTPRequest) -> void:
	var meta = _pending_requests.get(req_id, {})
	var faction_name = meta.get("faction", "")
	_pending_requests.erase(req_id)
	http.queue_free()

	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("ai_error", faction_name, "errore rete: %d" % result)
		return
	if response_code < 200 or response_code >= 300:
		emit_signal("ai_error", faction_name, "HTTP %d" % response_code)
		return

	var text = body.get_string_from_utf8()
	var json = JSON.new()
	if json.parse(text) != OK:
		emit_signal("ai_error", faction_name, "errore parse risposta")
		return

	var response_text = _extract_response_text(json.data, meta.get("provider", ""))
	if response_text == "":
		emit_signal("ai_error", faction_name, "risposta vuota")
		return
	emit_signal("ai_response_received", faction_name, response_text)


func _extract_response_text(data: Variant, provider: String) -> String:
	match provider:
		"gemini":
			var candidates = data.get("candidates", []) if data is Dictionary else []
			if candidates.size() > 0:
				var parts = candidates[0].get("content", {}).get("parts", []) if candidates[0] is Dictionary else []
				if parts.size() > 0:
					return parts[0].get("text", "") if parts[0] is Dictionary else ""
		"groq", "cerebras", "openrouter":
			var choices = data.get("choices", []) if data is Dictionary else []
			if choices.size() > 0:
				return choices[0].get("message", {}).get("content", "") if choices[0] is Dictionary else ""
		"cohere":
			return data.get("text", "") if data is Dictionary else ""
	return ""


# Reset contatori giornalieri (chiamare all'inizio di un nuovo giorno di gioco)
func reset_daily_counts() -> void:
	for key in _request_counts.keys():
		_request_counts[key] = 0


# Stato per debug
func get_status() -> Dictionary:
	return {
		"config_loaded": _config_loaded,
		"pending": _pending_requests.size(),
		"request_counts": _request_counts.duplicate(),
		"daily_limits": _daily_limits.duplicate()
	}
