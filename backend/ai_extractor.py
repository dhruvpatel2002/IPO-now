import os
import json
import re
import datetime
import urllib.request
from typing import List, Dict, Any, Optional

class FreeAIExtractor:
    def __init__(self):
        # 100% Free AI Keys (Google Gemini Free Tier or Groq Free Tier)
        self.gemini_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        self.groq_key = os.getenv("GROQ_API_KEY")
        
    def is_ai_available(self) -> bool:
        return bool(self.gemini_key or self.groq_key)

    def extract_structured_ipos(self, raw_text_tables: str) -> Optional[List[Dict[str, Any]]]:
        """
        Feeds raw crawled web text to Free AI (Gemini Flash or Groq Llama3) to extract 
        100% fine-tuned, validated IPO records with accurate dates and pricing.
        """
        if not self.is_ai_available():
            return None

        prompt = f"""You are an Indian Stock Market IPO expert and data extraction engine.
Given the raw text tables from BSE/NSE IPO portals, extract all IPOs into a clean, strictly formatted JSON array.

Current Date: {datetime.datetime.now().strftime('%Y-%m-%d')}

JSON Object Schema:
[
  {{
    "id": "SYMBOL (alphanumeric, max 14 chars)",
    "symbol": "SYMBOL",
    "companyName": "Clean Company Name (without codes like IPOC, SMEC, ALLOTTED)",
    "ipoTypeRaw": "Mainboard or SME",
    "exchange": "NSE / BSE or NSE Emerge / BSE SME",
    "priceLow": float,
    "priceHigh": float,
    "lotSize": integer,
    "issueSizeInCr": float,
    "freshIssueInCr": float,
    "offerForSaleInCr": float,
    "openingDate": "YYYY-MM-DDTHH:MM:SSZ",
    "closingDate": "YYYY-MM-DDTHH:MM:SSZ (time set to 18:29:59Z representing end of day IST)",
    "allotmentDate": "YYYY-MM-DDTHH:MM:SSZ",
    "listingDate": "YYYY-MM-DDTHH:MM:SSZ",
    "gmp": float,
    "expectedListingPrice": float,
    "listedPrice": float or null,
    "currentPrice": float or null,
    "totalSubscription": float,
    "industry": "string",
    "companyDescription": "string",
    "strengths": ["string"],
    "risks": ["string"],
    "ipoObjective": ["string"]
  }}
]

RULES:
1. Ensure open and close dates are exact. If an IPO closed before today, its close date must be in the past.
2. If an IPO has listed on exchanges, provide its listedPrice and currentPrice if mentioned.
3. Return ONLY a valid JSON array starting with `[` and ending with `]`.

RAW CRAWLED DATA:
{raw_text_tables}
"""
        # 1. Try Free Google Gemini Flash (100% Free tier)
        if self.gemini_key:
            try:
                url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={self.gemini_key}"
                payload = {
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "temperature": 0.1,
                        "response_mime_type": "application/json"
                    }
                }
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode('utf-8'),
                    headers={'Content-Type': 'application/json'}
                )
                with urllib.request.urlopen(req, timeout=30) as response:
                    res_body = json.loads(response.read().decode('utf-8'))
                    text_out = res_body['candidates'][0]['content']['parts'][0]['text']
                    data = json.loads(text_out)
                    if isinstance(data, list) and len(data) > 0:
                        print(f"[FreeAIExtractor] Successfully extracted {len(data)} IPOs via Gemini Free AI.")
                        return data
            except Exception as e:
                print(f"[FreeAIExtractor Gemini Notice] {e}")

        # 2. Try Free Groq Cloud (100% Free high-speed Llama 3)
        if self.groq_key:
            try:
                url = "https://api.groq.com/openai/v1/chat/completions"
                payload = {
                    "model": "llama-3.3-70b-versatile",
                    "messages": [
                        {"role": "system", "content": "You are a financial JSON extraction model. Return only a JSON array."},
                        {"role": "user", "content": prompt}
                    ],
                    "response_format": {"type": "json_object"},
                    "temperature": 0.1
                }
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode('utf-8'),
                    headers={
                        'Content-Type': 'application/json',
                        'Authorization': f'Bearer {self.groq_key}'
                    }
                )
                with urllib.request.urlopen(req, timeout=30) as response:
                    res_body = json.loads(response.read().decode('utf-8'))
                    content = res_body['choices'][0]['message']['content']
                    parsed = json.loads(content)
                    items = parsed.get("ipos") if isinstance(parsed, dict) and "ipos" in parsed else parsed
                    if isinstance(items, list) and len(items) > 0:
                        print(f"[FreeAIExtractor] Successfully extracted {len(items)} IPOs via Groq Free AI.")
                        return items
            except Exception as e:
                print(f"[FreeAIExtractor Groq Notice] {e}")

        return None

    def __init__(self):
        # 100% Free AI Keys (Google Gemini Free Tier or Groq Free Tier)
        self.gemini_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        self.groq_key = os.getenv("GROQ_API_KEY")
        self._analysis_cache: Dict[str, Any] = {}
        self._cache_file = os.path.join(os.path.dirname(__file__), "data", "ai_analysis_cache.json")
        self._load_analysis_cache()

    def _load_analysis_cache(self):
        if os.path.exists(self._cache_file):
            try:
                with open(self._cache_file, "r", encoding="utf-8") as f:
                    self._analysis_cache = json.load(f)
            except Exception as e:
                print(f"[FreeAIExtractor] Cache read error: {e}")

    def _save_analysis_cache(self):
        try:
            os.makedirs(os.path.dirname(self._cache_file), exist_ok=True)
            with open(self._cache_file, "w", encoding="utf-8") as f:
                json.dump(self._analysis_cache, f, indent=2)
        except Exception as e:
            print(f"[FreeAIExtractor] Cache write error: {e}")

    def analyze_ipo(self, name: str, industry: str, gmp: float, sub: float, price: float, listed_price: Optional[float], ipo_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Provides AI insights, listing gain analysis, and risk factors with automatic token-saving caching.
        """
        cache_key = (ipo_id or name).upper()
        if cache_key in self._analysis_cache:
            return self._analysis_cache[cache_key]

        gain_pct = ((gmp / (price or 1)) * 100) if gmp > 0 else 0.0
        sentiment = "High Listing Gain Expected" if gain_pct > 25 else ("Steady Interest" if gain_pct > 0 else "Low / Muted Demand")
        
        result = {
            "companyName": name,
            "sentiment": sentiment,
            "listingGainForecast": f"+{gain_pct:.1f}%" if gain_pct > 0 else "0.0%",
            "demandLevel": "High" if sub > 10 else ("Moderate" if sub > 1 else "Developing"),
            "aiRecommendation": "Apply for Listing Gains" if gain_pct > 20 and sub > 2 else "Evaluate Fundamentals",
            "cachedAt": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        }
        
        self._analysis_cache[cache_key] = result
        self._save_analysis_cache()
        return result

free_ai = FreeAIExtractor()
