import os
import time
from fastapi import FastAPI, Query, HTTPException, UploadFile, File, Body
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from apscheduler.schedulers.background import BackgroundScheduler
from typing import Optional, List, Dict, Any
from contextlib import asynccontextmanager
import asyncio
import datetime

try:
    from scraper import scraper
except ImportError:
    from backend.scraper import scraper

try:
    from excel_manager import save_ipos_to_excel, load_ipos_from_excel, import_ai_json_or_text_to_excel, EXCEL_PATH
except ImportError:
    from backend.excel_manager import save_ipos_to_excel, load_ipos_from_excel, import_ai_json_or_text_to_excel, EXCEL_PATH

scheduler = BackgroundScheduler()

def scheduled_refresh():
    print(f"[{datetime.datetime.now()}] [Scheduled Job] Triggering live scrape refresh...")
    scraper.fetch_all_ipos(force=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start scheduler for 9:30 AM & 6:30 PM IST daily
    scheduler.add_job(scheduled_refresh, "cron", hour="4,13", minute="0", timezone="UTC") # 09:30 & 18:30 IST
    scheduler.start()
    
    # Check if disk cache or Excel is already fresh (< 12 hours old)
    cache_status = scraper.get_cache_status()
    if not cache_status.get("is_fresh", False):
        print("[Lifespan] Cache is missing or stale (>12h). Launching background scrape...")
        asyncio.create_task(asyncio.to_thread(scraper.fetch_all_ipos, False))
    else:
        print(f"[Lifespan] Cache is fresh ({cache_status.get('total_ipos')} IPOs, updated {cache_status.get('last_updated')}). Serving instantly without scraping.")
    
    yield
    
    scheduler.shutdown()

app = FastAPI(
    title="IPOnow Live Scraper API",
    description="Automated Indian IPO live data, GMP, subscriptions, Excel spreadsheet sync, and financial metrics backend.",
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

@app.get("/dashboard", response_class=HTMLResponse)
@app.get("/admin", response_class=HTMLResponse)
async def serve_dashboard():
    candidate_paths = [
        os.path.join(os.path.dirname(__file__), "templates", "dashboard.html"),
        os.path.join(os.getcwd(), "backend", "templates", "dashboard.html"),
        os.path.join(os.getcwd(), "templates", "dashboard.html"),
        "backend/templates/dashboard.html",
        "templates/dashboard.html"
    ]
    for p in candidate_paths:
        if os.path.exists(p):
            with open(p, "r", encoding="utf-8") as f:
                return HTMLResponse(content=f.read())
    return HTMLResponse(content="<h1>Dashboard template missing</h1>", status_code=404)

@app.get("/api/excel/download")
async def download_excel():
    # Ensure latest Excel file exists
    all_ipos = await asyncio.to_thread(scraper.fetch_all_ipos, False)
    excel_file = save_ipos_to_excel(all_ipos)
    if os.path.exists(excel_file):
        return FileResponse(
            excel_file,
            media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            filename="ipos_database.xlsx"
        )
    raise HTTPException(status_code=404, detail="Excel database not found")

@app.post("/api/excel/import-ai")
async def import_ai_data(payload: Dict[str, Any] = Body(...)):
    raw_text = payload.get("rawText") or payload.get("jsonText") or json.dumps(payload)
    try:
        updated_ipos = import_ai_json_or_text_to_excel(raw_text)
        scraper._cached_ipos = updated_ipos
        scraper._last_fetched = time.time()
        return {
            "status": "success",
            "message": f"Successfully imported {len(updated_ipos)} IPOs into Excel and updated cache.",
            "count": len(updated_ipos)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse AI output: {str(e)}")

@app.post("/api/excel/upload")
async def upload_excel_file(file: UploadFile = File(...)):
    temp_path = os.path.join(os.path.dirname(__file__), "data", "uploaded_ipos.xlsx")
    os.makedirs(os.path.dirname(temp_path), exist_ok=True)
    with open(temp_path, "wb") as f:
        f.write(await file.read())
    
    try:
        ipos = load_ipos_from_excel(temp_path)
        if not ipos:
            raise ValueError("No valid IPO rows found in uploaded Excel.")
        save_ipos_to_excel(ipos, EXCEL_PATH)
        scraper._cached_ipos = ipos
        scraper._last_fetched = time.time()
        scraper._save_disk_cache(ipos)
        return {
            "status": "success",
            "message": f"Successfully updated database with {len(ipos)} IPOs from Excel file.",
            "count": len(ipos)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to process Excel file: {str(e)}")


@app.get("/")
async def health_check():
    cache_meta = scraper.get_cache_status()
    return {
        "status": "healthy",
        "service": "IPOnow Scraper API",
        "version": "2.0.0",
        "dashboardUrl": "/dashboard",
        "cache": cache_meta,
        "tokenOptimization": "Data cached persistently and refreshed twice daily (09:30 & 18:30 IST)",
        "endpoints": [
            "/dashboard",
            "/api/ipos",
            "/api/ipos/{id}",
            "/api/gmp",
            "/api/status",
            "/api/ai/analyze/{id}",
            "/api/refresh"
        ]
    }

@app.get("/api/status")
async def get_cache_status():
    return scraper.get_cache_status()

@app.get("/api/ipos")
async def get_ipos(
    category: Optional[str] = Query(None, description="Category filter: live, upcoming, closed"),
    ipo_type: Optional[str] = Query(None, description="Type filter: mainboard, sme, sse"),
    force_refresh: bool = Query(False, description="Force fresh web scrape")
) -> List[Dict[str, Any]]:
    force_val = bool(force_refresh is True)
    all_ipos = await asyncio.to_thread(scraper.fetch_all_ipos, force_val)
    results = list(all_ipos)

    if isinstance(ipo_type, str) and ipo_type:
        type_lower = ipo_type.lower()
        results = [i for i in results if type_lower in i.get("ipoTypeRaw", "").lower()]

    if isinstance(category, str) and category:
        cat_lower = category.lower()
        if cat_lower in ["live", "ongoing", "open"]:
            results = [i for i in results if "open" in i.get("statusRaw", "").lower()]
        elif cat_lower == "upcoming":
            results = [i for i in results if "upcoming" in i.get("statusRaw", "").lower()]
        elif cat_lower == "closed":
            results = [i for i in results if "closed" in i.get("statusRaw", "").lower() or "allotment" in i.get("statusRaw", "").lower()]

    results.sort(key=lambda x: (x.get("openingDate", ""), x.get("closingDate", "")))
    return results

@app.get("/api/ipos/{ipo_id}")
async def get_ipo_detail(ipo_id: str) -> Dict[str, Any]:
    all_ipos = await asyncio.to_thread(scraper.fetch_all_ipos, False)
    for item in all_ipos:
        if item.get("id", "").lower() == ipo_id.lower() or item.get("symbol", "").lower() == ipo_id.lower():
            return item
    raise HTTPException(status_code=404, detail="IPO not found")

@app.get("/api/gmp")
async def get_gmp_rankings() -> List[Dict[str, Any]]:
    all_ipos = await asyncio.to_thread(scraper.fetch_all_ipos, False)
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

@app.get("/api/ai/analyze/{ipo_id}")
async def analyze_ipo_ai(ipo_id: str) -> Dict[str, Any]:
    try:
        from ai_extractor import free_ai
    except ImportError:
        from backend.ai_extractor import free_ai

    all_ipos = await asyncio.to_thread(scraper.fetch_all_ipos, False)
    target_ipo = None
    for item in all_ipos:
        if item.get("id", "").lower() == ipo_id.lower() or item.get("symbol", "").lower() == ipo_id.lower():
            target_ipo = item
            break
    if not target_ipo:
        raise HTTPException(status_code=404, detail="IPO not found")

    analysis = free_ai.analyze_ipo(
        name=target_ipo.get("companyName", ""),
        industry=target_ipo.get("industry", ""),
        gmp=target_ipo.get("gmp", 0.0),
        sub=target_ipo.get("totalSubscription", 0.0),
        price=target_ipo.get("priceHigh", 0.0),
        listed_price=target_ipo.get("listedPrice"),
        ipo_id=target_ipo.get("id")
    )
    return {
        "ipo": target_ipo,
        "aiAnalysis": analysis,
        "isAiPowered": free_ai.is_ai_available()
    }


@app.post("/api/refresh")
async def refresh_data():
    updated = await asyncio.to_thread(scraper.fetch_all_ipos, True)
    return {
        "status": "success",
        "message": f"Successfully scraped {len(updated)} live IPOs",
        "count": len(updated)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
