"""
Dua Scraper - allahuakbarofficial.com
Install: pip install requests beautifulsoup4
Run:     python scrape_duas.py
Output:  duas.json
"""
import requests
from bs4 import BeautifulSoup
import json, time, re

CATEGORIES = [
    'angry','anxious','bored','confident','confused','content','depressed','doubtful',
    'grateful','greedy','guilty','happy','hurt','indecisive','hypocritical','jealous',
    'lazy','lonely','lost','nervous','overwhelmed','regret','sad','scared','suicidal',
    'tired','unloved','weak'
]
HEADERS = {'User-Agent': 'Mozilla/5.0'}

def is_arabic(t): return any('\u0600' <= c <= '\u06FF' for c in t)
def clean(t): return re.sub(r'\s+', ' ', t).strip()

def scrape(cat):
    soup = BeautifulSoup(requests.get(f"https://allahuakbarofficial.com/{cat}/", headers=HEADERS, timeout=15).text, 'html.parser')
    duas, cur, last = [], {}, None
    for el in soup.find_all(True):
        t = clean(el.get_text())
        if not t or 'When a person dies' in t or 'Sadaqah Jariyah' in t: continue
        if el.name == 'h5':
            if cur.get('arabic'): duas.append(cur)
            cur = {'title':t,'arabic':'','transliteration':'','translation':'','hadith':'','reference':''}; last=None
        elif el.name == 'p' and cur:
            if is_arabic(t) and not cur['arabic']: cur['arabic']=t; continue
            b = el.find('strong')
            if b:
                lbl = clean(b.get_text()).rstrip(':').lower()
                rest = t[len(b.get_text()):].strip().lstrip(':').strip()
                if 'transliteration' in lbl: cur['transliteration']=rest; last='transliteration'
                elif 'translation' in lbl: cur['translation']=rest; last='translation'
                elif 'hadith' in lbl or 'virtue' in lbl: cur['hadith']=rest; last='hadith'
                elif 'reference' in lbl: cur['reference']=rest; last='reference'
                else: last=None
            elif last and cur.get(last) is not None:
                cur[last] = (cur[last]+' '+t).strip() if cur[last] else t
    if cur.get('arabic'): duas.append(cur)
    return duas

all_data, total = {}, 0
for i, cat in enumerate(CATEGORIES):
    print(f"[{i+1:02d}/28] {cat}...", end=' ', flush=True)
    try:
        d = scrape(cat); all_data[cat]=d; total+=len(d); print(f"✓ {len(d)} duas")
    except Exception as e: print(f"✗ {e}"); all_data[cat]=[]
    time.sleep(1)

with open('duas.json','w',encoding='utf-8') as f: json.dump(all_data,f,ensure_ascii=False,indent=2)
print(f"\n✅ {total} duas saved to duas.json")
