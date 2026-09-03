from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.background import BackgroundScheduler
from typing import Optional, List, Dict, Any
from contextlib import asynccontextmanager
from scraper import scraper
import datetime

scheduler = BackgroundScheduler()

def scheduled_refresh():
    print(f"[{datetime.datetime.now()}] [Scheduled Job] Triggering live scrape refresh...")
    scraper.fetch_all_ipos(force=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. Trigger initial live scrape on server boot
    print("[Startup] Triggering initial live scrape...")
    scheduler.add_job(scheduled_refresh, "cron", hour="9,18", minute="30") # 9:30 AM & 6:30 PM daily
    scheduler.start()
    
    # Run once in background on startup
    scraper.fetch_all_ipos(force=True)
    
    yield
    
    scheduler.shutdown()

app = FastAPI(
    title="IPOnow Live Scraper API",
    description="Automated Indian IPO live data, GMP, subscriptions, and financial metrics backend.",
    version="2.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def health_check():
    ipos = scraper.fetch_all_ipos()
    return {
        "status": "healthy",
        "service": "IPOnow Scraper API",
        "version": "2.0.0",
        "total_live_ipos": len(ipos),
        "schedule": "2x daily (09:30 & 18:30 IST)",
        "endpoints": [
            "/api/ipos",
            "/api/ipos/{id}",
            "/api/gmp",
            "/api/refresh"
        ]
    }

@app.get("/api/ipos")
def get_ipos(
    category: Optional[str] = Query(None, description="Category filter: live, upcoming, closed"),
    ipo_type: Optional[str] = Query(None, description="Type filter: mainboard, sme, sse"),
    force_refresh: bool = Query(False, description="Force fresh web scrape")
) -> List[Dict[str, Any]]:
    all_ipos = scraper.fetch_all_ipos(force=force_refresh)
    results = all_ipos

    if ipo_type:
        type_lower = ipo_type.lower()
        results = [i for i in results if type_lower in i.get("ipoTypeRaw", "").lower()]

    if category:
        cat_lower = category.lower()
        if cat_lower in ["live", "ongoing", "open"]:
            results = [i for i in results if "open" in i.get("statusRaw", "").lower()]
        elif cat_lower == "upcoming":
            results = [i for i in results if "upcoming" in i.get("statusRaw", "").lower()]
        elif cat_lower == "closed":
            results = [i for i in results if "closed" in i.get("statusRaw", "").lower() or "allotment" in i.get("statusRaw", "").lower()]

    return results

@app.get("/api/ipos/{ipo_id}")
def get_ipo_detail(ipo_id: str) -> Dict[str, Any]:
    all_ipos = scraper.fetch_all_ipos()
    for item in all_ipos:
        if item.get("id", "").lower() == ipo_id.lower() or item.get("symbol", "").lower() == ipo_id.lower():
            return item
    raise HTTPException(status_code=404, detail="IPO not found")

@app.get("/api/gmp")
def get_gmp_rankings() -> List[Dict[str, Any]]:
    all_ipos = scraper.fetch_all_ipos()
    gmp_items = [
        {
            "id": i.get("id"),
            "companyName": i.get("companyName"),
            "symbol": i.get("symbol"),
            "ipoType": i.get("ipoTypeRaw"),
            "priceHigh": i.get("priceHigh"),
            "gmp": i.get("gmp", 0),
            "expectedListingPrice": i.get("expectedListingPrice"),
            "gmpPercentage": round((i.get("gmp", 0) / (i.get("priceHigh") or 1)) * 100, 1)
        }
        for i in all_ipos if i.get("gmp", 0) > 0
    ]
    gmp_items.sort(key=lambda x: x["gmp"], reverse=True)
    return gmp_items

@app.post("/api/refresh")
def refresh_data():
    updated = scraper.fetch_all_ipos(force=True)
    return {
        "status": "success",
        "message": f"Successfully scraped {len(updated)} live IPOs",
        "count": len(updated)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
