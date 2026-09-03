import urllib.request
import re
import json

def fetch_investorgain_ipos():
    url = "https://www.investorgain.com/report/ipo-gmp-live/331/"
    req = urllib.request.Request(url, headers={
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    })
    
    try:
        with urllib.request.urlopen(req, timeout=12) as response:
            html = response.read().decode("utf-8", errors="ignore")
            
            # Find the JSON data rows in Next.js stream
            matches = re.findall(r'\\\"company_name\\\":\\\"([^\\\"]+)\\\"', html)
            gmps = re.findall(r'\\\"gmp\\\":\\\"([^\\\"]+)\\\"', html)
            prices = re.findall(r'\\\"price\\\":\\\"([^\\\"]+)\\\"', html)
            types = re.findall(r'\\\"ipo_type\\\":\\\"([^\\\"]+)\\\"', html)
            
            print(f"Extracted {len(matches)} live IPOs with GMP and pricing!")
            for i in range(min(len(matches), 8)):
                name = matches[i]
                gmp = gmps[i] if i < len(gmps) else "N/A"
                price = prices[i] if i < len(prices) else "N/A"
                itype = types[i] if i < len(types) else "Mainboard"
                print(f"- {name} [{itype}] | Price: ₹{price} | GMP: ₹{gmp}")
    except Exception as e:
        print("Scraping error:", e)

if __name__ == "__main__":
    fetch_investorgain_ipos()
