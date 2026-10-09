# API IA Esterna (AIBridge) — Hegemonia 1000

Documentazione del sistema di chiamate IA esterne.
Dark Corporation / Stev

## Panoramica

AIBridge e' un autoload che invia richieste a provider IA esterni
(Gemini, Groq, Cerebras, Cohere, OpenRouter) per ottenere decisioni
strategiche per le fazioni AI. Se nessun provider e' disponibile,
usa fallback deterministico.

## File coinvolti

- `scripts/autoload/ai_bridge.gd` (330 righe) - autoload principale
- `config_api.json` - chiavi API e modelli (copiato da Hegemonia 1700)
- `project.godot` - registra AIBridge come autoload

## Configurazione

Il file `config_api.json` contiene:
- `api_key_gemini_1`, `api_key_gemini_2` - chiavi Gemini (rotazione)
- `api_key_groq` - chiave Groq
- `api_key_cerebras` - chiave Cerebras
- `api_key_cohere` - chiave Cohere
- `api_key_openrouter` - chiave OpenRouter
- `api_model_*` - modelli per ogni provider

**NON modificare le chiavi API** senza permesso esplicito.

## Routing per dimensione prompt

Il provider viene scelto in base alla stima dei token del prompt
(~4 caratteri per token):

| Dimensione prompt | Provider | Modello |
|-------------------|----------|---------|
| sotto 7.000 token | Cerebras | gpt-oss-120b |
| 7.000-28.000 token | Groq | openai/gpt-oss-120b |
| sopra 28.000 token | Gemini | gemini-3.1-flash-lite |

Fallback se il provider preferito non e' disponibile:
Gemini -> Groq -> Cerebras -> OpenRouter -> Cohere

## Limiti free tier

| Provider | Limite giornaliero |
|----------|-------------------|
| Gemini | 20 (flash-lite: 500) |
| Groq | 1000 |
| Cerebras | 14400 |
| Cohere | 33 |
| OpenRouter | 100 |

## Limite richieste contemporanee

Massimo 10 richieste pending. Se si supera, viene emesso segnale
`ai_error` e si usa fallback deterministico.

## Formato prompt

Il prompt viene costruito da `build_faction_prompt()`:

```
Sei l'IA della nazione <nome> nell'anno 1000.
Obiettivo: <obiettivo>
Comportamento: <comportamento>
Risorse: oro=<n> cibo=<n> armi=<n>
Esercito: fanteria=<n> cavalleria=<n> arcieri=<n> navi=<n>
Province: <n> | Settlements: <n>
Minacce vicine: <lista>

Decidi UNA azione strategica tra:
- costruisci <edificio>
- recluta <tipo_unita>
- attacca <provincia>
- difendi <provincia>
- alleanza <nazione>
- commercio <nazione>
Rispondi con una sola riga nel formato: AZIONE: <comando>
```

## Formato risposta atteso

L'IA deve rispondere con una singola riga:
```
AZIONE: costruisci mercato
AZIONE: recluta fanteria
AZIONE: attacca Nicea
AZIONE: difendi Costantinopoli
AZIONE: alleanza Sacro Romano Impero
AZIONE: commercio Impero Fatimide
```

## Endpoint API

### Gemini
```
POST https://generativelanguage.googleapis.com/v1beta/models/<model>:generateContent?key=<key>
Body: {"contents": [{"parts": [{"text": prompt}]}], "generationConfig": {"maxOutputTokens": 500}}
```

### Groq
```
POST https://api.groq.com/openai/v1/chat/completions
Headers: Authorization: Bearer <key>
Body: {"model": "<model>", "messages": [{"role": "user", "content": prompt}], "max_tokens": 500}
```

### Cerebras
```
POST https://api.cerebras.ai/v1/chat/completions
Headers: Authorization: Bearer <key>
Body: {"model": "<model>", "messages": [{"role": "user", "content": prompt}], "max_tokens": 500}
```

## Segnali

- `ai_response_received(faction_name, response)` - risposta ricevuta
- `ai_error(faction_name, error)` - errore, usa fallback

## Integrazione con AIController

`AIController._request_external_strategy()` chiama
`AIBridge.request_ai_decision()` con il prompt costruito da
`AIBridge.build_faction_prompt()`. La risposta viene elaborata
da `_handle_ai_response()` che estrae il comando e lo esegue.

Se la risposta non e' valida o non arriva, AIController continua
con logica deterministica (costruzione, reclutamento, attacco).

## Problemi noti

- In simulazione headless senza rete, le richieste falliscono con
  errori DNS. Il fallback deterministico garantisce che il gioco
  continui.
- I limiti free tier possono esaurirsi in partite lunghe con molte
  fazioni AI.
- La rotazione chiavi Gemini bilancia il carico tra due chiavi.
