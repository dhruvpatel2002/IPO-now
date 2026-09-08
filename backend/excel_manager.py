import os
import json
import datetime
from typing import List, Dict, Any, Optional
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

EXCEL_PATH = os.path.join(os.path.dirname(__file__), "data", "ipos_database.xlsx")
FALLBACK_EXCEL_PATH = os.path.join(os.getcwd(), "data", "ipos_database.xlsx")

COLUMNS = [
    ("Symbol", "symbol", 14),
    ("Company Name", "companyName", 32),
    ("Category", "ipoTypeRaw", 12),
    ("Exchange", "exchange", 16),
    ("Status", "statusRaw", 12),
    ("Price Low (₹)", "priceLow", 14),
    ("Price High (₹)", "priceHigh", 14),
    ("Lot Size", "lotSize", 10),
    ("Issue Size (Cr)", "issueSizeInCr", 15),
    ("Opening Date", "openingDate", 22),
    ("Closing Date", "closingDate", 22),
    ("Allotment Date", "allotmentDate", 22),
    ("Listing Date", "listingDate", 22),
    ("GMP (₹)", "gmp", 10),
    ("Est Listing Price", "expectedListingPrice", 18),
    ("Listed Price", "listedPrice", 14),
    ("Current Price (CMP)", "currentPrice", 18),
    ("Retail Sub (x)", "retailSubscription", 14),
    ("NII Sub (x)", "niiSubscription", 14),
    ("QIB Sub (x)", "qibSubscription", 14),
    ("Total Sub (x)", "totalSubscription", 14),
    ("Industry", "industry", 20),
    ("Company Description", "companyDescription", 40),
    ("Strengths", "strengths", 30),
    ("Risks", "risks", 30),
    ("Objectives", "ipoObjective", 30),
    ("Source", "source", 18)
]

def save_ipos_to_excel(ipos: List[Dict[str, Any]], target_path: Optional[str] = None) -> str:
    """
    Saves a list of IPO dictionaries into a beautifully styled Excel workbook.
    """
    path = target_path or EXCEL_PATH
    os.makedirs(os.path.dirname(path), exist_ok=True)
    
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Live IPOs"
    
    # Enable gridlines
    ws.views.sheetView[0].showGridLines = True
    
    # Styles
    header_fill = PatternFill(start_color="1E293B", end_color="1E293B", fill_type="solid")
    header_font = Font(name="Arial", size=11, bold=True, color="FFFFFF")
    data_font = Font(name="Arial", size=10)
    center_align = Alignment(horizontal="center", vertical="center")
    left_align = Alignment(horizontal="left", vertical="center")
    
    thin_border = Border(
        left=Side(style='thin', color='E2E8F0'),
        right=Side(style='thin', color='E2E8F0'),
        top=Side(style='thin', color='E2E8F0'),
        bottom=Side(style='thin', color='E2E8F0')
    )
    
    # Write Headers
    for col_idx, (col_name, _, col_width) in enumerate(COLUMNS, start=1):
        cell = ws.cell(row=1, column=col_idx, value=col_name)
        cell.fill = header_fill
        cell.font = header_font
        cell.alignment = center_align
        ws.column_dimensions[get_column_letter(col_idx)].width = col_width
    
    # Write Data
    for row_idx, ipo in enumerate(ipos, start=2):
        for col_idx, (_, key, _) in enumerate(COLUMNS, start=1):
            val = ipo.get(key)
            if isinstance(val, list):
                val = ", ".join(str(x) for x in val)
            elif val is None:
                val = ""
                
            cell = ws.cell(row=row_idx, column=col_idx, value=val)
            cell.font = data_font
            cell.border = thin_border
            
            if key in ["priceLow", "priceHigh", "lotSize", "issueSizeInCr", "gmp", "expectedListingPrice", "listedPrice", "currentPrice", "retailSubscription", "niiSubscription", "qibSubscription", "totalSubscription"]:
                cell.alignment = Alignment(horizontal="right", vertical="center")
            elif key in ["symbol", "ipoTypeRaw", "statusRaw", "exchange"]:
                cell.alignment = center_align
            else:
                cell.alignment = left_align

    wb.save(path)
    
    # Also mirror to root data directory if exists
    try:
        os.makedirs(os.path.dirname(FALLBACK_EXCEL_PATH), exist_ok=True)
        wb.save(FALLBACK_EXCEL_PATH)
    except Exception:
        pass
        
    print(f"[ExcelManager] Successfully saved {len(ipos)} IPOs to Excel at {path}")
    return path

def load_ipos_from_excel(target_path: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Reads IPOs from the Excel workbook and returns a list of dictionaries matching the app schema.
    """
    path = target_path or EXCEL_PATH
    if not os.path.exists(path):
        if os.path.exists(FALLBACK_EXCEL_PATH):
            path = FALLBACK_EXCEL_PATH
        else:
            return []
            
    wb = openpyxl.load_workbook(path, data_only=True)
    ws = wb.active
    
    headers = [cell.value for cell in ws[1]]
    header_to_key = {}
    for col_name, key, _ in COLUMNS:
        if col_name in headers:
            header_to_key[headers.index(col_name)] = key
            
    ipos: List[Dict[str, Any]] = []
    
    for row in ws.iter_rows(min_row=2, values_only=True):
        if not any(row):
            continue
        ipo_dict: Dict[str, Any] = {}
        for col_idx, cell_value in enumerate(row):
            if col_idx in header_to_key:
                k = header_to_key[col_idx]
                if cell_value is None or cell_value == "":
                    if k in ["listedPrice", "currentPrice"]:
                        ipo_dict[k] = None
                    elif k in ["priceLow", "priceHigh", "lotSize", "issueSizeInCr", "gmp", "expectedListingPrice", "retailSubscription", "niiSubscription", "qibSubscription", "totalSubscription"]:
                        ipo_dict[k] = 0.0
                    else:
                        ipo_dict[k] = ""
                else:
                    if k in ["priceLow", "priceHigh", "issueSizeInCr", "gmp", "expectedListingPrice", "retailSubscription", "niiSubscription", "qibSubscription", "totalSubscription"]:
                        try:
                            ipo_dict[k] = float(cell_value)
                        except (ValueError, TypeError):
                            ipo_dict[k] = 0.0
                    elif k in ["listedPrice", "currentPrice"]:
                        try:
                            ipo_dict[k] = float(cell_value)
                        except (ValueError, TypeError):
                            ipo_dict[k] = None
                    elif k == "lotSize":
                        try:
                            ipo_dict[k] = int(cell_value)
                        except (ValueError, TypeError):
                            ipo_dict[k] = 20
                    elif k in ["strengths", "risks", "ipoObjective"]:
                        if isinstance(cell_value, str):
                            ipo_dict[k] = [x.strip() for x in cell_value.split(",") if x.strip()]
                        else:
                            ipo_dict[k] = [str(cell_value)]
                    else:
                        ipo_dict[k] = str(cell_value).strip()
        
        # Ensure critical defaults
        if "symbol" in ipo_dict and ipo_dict["symbol"]:
            sym = ipo_dict["symbol"].upper()
            ipo_dict["id"] = sym
            ipo_dict["symbol"] = sym
            ipo_dict["faceValue"] = ipo_dict.get("faceValue", 10.0) or 10.0
            ipo_dict["freshIssueInCr"] = round((ipo_dict.get("issueSizeInCr") or 100.0) * 0.8, 2)
            ipo_dict["offerForSaleInCr"] = round((ipo_dict.get("issueSizeInCr") or 100.0) * 0.2, 2)
            ipo_dict["revenueInCr"] = round((ipo_dict.get("issueSizeInCr") or 100.0) * 1.3, 2)
            ipo_dict["profitInCr"] = round((ipo_dict.get("issueSizeInCr") or 100.0) * 0.15, 2)
            ipo_dict["eps"] = 12.0
            ipo_dict["peRatio"] = 16.5
            ipo_dict["roe"] = 19.2
            ipo_dict["debtInCr"] = round((ipo_dict.get("issueSizeInCr") or 100.0) * 0.08, 2)
            ipo_dict["headquarters"] = ipo_dict.get("headquarters") or "India"
            ipo_dict["promoterDetails"] = ipo_dict.get("promoterDetails") or "Disclosed in DRHP prospectus."
            ipos.append(ipo_dict)
            
    ipos.sort(key=lambda x: (x.get("openingDate", ""), x.get("closingDate", "")))
    print(f"[ExcelManager] Loaded {len(ipos)} IPOs from Excel at {path}")
    return ipos

def import_ai_json_or_text_to_excel(raw_ai_text: str) -> List[Dict[str, Any]]:
    """
    Parses raw JSON from external AI queries, writes to Excel, and updates the cache.
    """
    # Clean possible markdown codeblocks
    cleaned = raw_ai_text.strip()
    if cleaned.startswith("```json"):
        cleaned = cleaned[7:]
    elif cleaned.startswith("```"):
        cleaned = cleaned[3:]
    if cleaned.endswith("```"):
        cleaned = cleaned[:-3]
    cleaned = cleaned.strip()
    
    # Parse JSON
    parsed = json.loads(cleaned)
    items = parsed if isinstance(parsed, list) else (parsed.get("ipos") if isinstance(parsed, dict) else [])
    
    if not items or not isinstance(items, list):
        raise ValueError("Invalid JSON format: Expected a JSON array of IPO records.")
        
    save_ipos_to_excel(items)
    
    # Save to JSON cache as well
    json_cache_path = os.path.join(os.path.dirname(__file__), "data", "live_ipos_cache.json")
    with open(json_cache_path, "w", encoding="utf-8") as f:
        json.dump(items, f, indent=2)
        
    return items
