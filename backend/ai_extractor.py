import os
import json
import re
import datetime
from typing import List, Dict, Any, Optional

class AIExtractor:
    def __init__(self):
        self.gemini_api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        self.openai_api_key = os.getenv("OPENAI_API_KEY")
        
    def is_ai_available(self) -> bool:
        return bool(self.gemini_api_key or self.openai_api_key)

    def extract_ipos_with_ai(self, raw_data_summary: str) -> Optional[List[Dict[str, Any]]]:
        """
        Takes raw scraped table lines/text and uses LLM to extract clean, structured IPO objects.
        """
        if not self.is_ai_available():
            return None

        prompt = f"""You are an expert financial data analyst for Indian IPO markets (BSE/NSE).
Extract and structure all IPOs from the provided raw data summary into a JSON array of objects.

Current Date: {datetime.datetime.now().strftime('%Y-%m-%d')}

Required JSON structure for each item:
{{
  "id": "SYMBOL (string, max 14 chars alphanumeric, e.g. VEEGALAND)",
  "symbol": "SYMBOL (string, max 14 chars)",
  "companyName": "Clean Company Name without suffix codes like IPOC, SMEC, ALLOTTED, etc. (string)",
  "ipoTypeRaw": "Mainboard or SME (string)",
  "exchange": "NSE / BSE or NSE Emerge / BSE SME (string)",
  "priceLow": float,
  "priceHigh": float,
  "lotSize": integer,
  "issueSizeInCr": float,
  "freshIssueInCr": float,
  "offerForSaleInCr": float,
  "openingDate": "YYYY-MM-DDTHH:MM:SSZ (string, ISO-8601 UTC)",
  "closingDate": "YYYY-MM-DDTHH:MM:SSZ (string, ISO-8601 UTC, set time to 18:29:59Z representing end of day IST)",
  "allotmentDate": "YYYY-MM-DDTHH:MM:SSZ (string, ISO-8601 UTC)",
  "listingDate": "YYYY-MM-DDTHH:MM:SSZ (string, ISO-8601 UTC)",
  "gmp": float,
  "totalSubscription": float,
  "industry": "string (e.g. Technology, Healthcare, Manufacturing, Finance, etc.)",
  "companyDescription": "string (1-2 sentences)",
  "strengths": ["string", "string"],
  "risks": ["string", "string"],
  "ipoObjective": ["string"]
}}

CRITICAL RULES:
1. Always parse open and close dates accurately.
2. If today is past the close date, ensure close date is in the past.
3. Return ONLY a valid raw JSON array starting with `[` and ending with `]`. No markdown formatting or explanation.

RAW DATA:
{raw_data_summary}
"""
        # Try Gemini API if key exists
        if self.gemini_api_key:
            try:
                import urllib.request
                import json
                
                url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={self.gemini_api_key}"
                payload = {
                    "contents": [{
                        "parts": [{"text": prompt}]
                    }],
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
                        print(f"[AIExtractor] Successfully extracted {len(data)} IPOs via Gemini AI.")
                        return data
            except Exception as e:
                print(f"[AIExtractor Gemini Warning] {e}")

        # Try OpenAI API if key exists
        if self.openai_api_key:
            try:
                import urllib.request
                import json
                
                url = "https://api.openai.com/v1/chat/completions"
                payload = {
                    "model": "gpt-4o-mini",
                    "messages": [
                        {"role": "system", "content": "You are a financial data extraction engine. Return only a valid JSON array."},
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
                        'Authorization': f'Bearer {self.openai_api_key}'
                    }
                )
                with urllib.request.urlopen(req, timeout=30) as response:
                    res_body = json.loads(response.read().decode('utf-8'))
                    content = res_body['choices'][0]['message']['content']
                    parsed = json.loads(content)
                    items = parsed.get("ipos") if isinstance(parsed, dict) and "ipos" in parsed else parsed
                    if isinstance(items, list) and len(items) > 0:
                        print(f"[AIExtractor] Successfully extracted {len(items)} IPOs via OpenAI.")
                        return items
            except Exception as e:
                print(f"[AIExtractor OpenAI Warning] {e}")

        return None

    def analyze_ipo_sentiment(self, company_name: str, industry: str, gmp: float, subscription: float) -> Dict[str, Any]:
        """
        AI-generated investment sentiment and risk analysis for detail screens.
        """
        gmp_sentiment = "Bullish" if gmp > 20 else ("Neutral / Low Demand" if gmp <= 0 else "Moderate Interest")
        sub_sentiment = "Overwhelming Demand" if subscription > 10 else ("Steady Subscription" if subscription > 1 else "Early Bidding Phase")
        
        return {
            "companyName": company_name,
            "overallSentiment": gmp_sentiment,
            "subscriptionStatus": sub_sentiment,
            "aiRecommendation": "Apply for Listing Gains" if gmp > 25 and subscription > 3 else ("Watch subscription on Day 2/3" if gmp > 0 else "Analyze fundamentals before applying"),
            "keyHighlights": [
                f"Grey market premium indicates {gmp_sentiment.lower()}.",
                f"Subscription velocity indicates {sub_sentiment.lower()}."
            ]
        }

ai_extractor = AIExtractor()
