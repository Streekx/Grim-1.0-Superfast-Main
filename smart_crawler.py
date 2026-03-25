# smart_crawler.py
import os
import time
import threading
from queue import Queue
from urllib.parse import urljoin
import requests
import trafilatura
from bs4 import BeautifulSoup

SEED_URLS = [
    "https://en.wikipedia.org/wiki/Special:Random",
    "https://gutenberg.org/browse/scores/top"
]
DATA_DIR = "crawler_data"
MAX_THREADS = 8
POLITENESS_DELAY = 0.5
MIN_TEXT_LENGTH = 500
MAX_VISITED_MEMORY = 100000

os.makedirs(DATA_DIR, exist_ok=True)
visited = set()
url_queue = Queue()

for url in SEED_URLS:
    url_queue.put(url)

def crawl():
    while True:
        if url_queue.empty():
            time.sleep(2)
            continue
            
        url = url_queue.get()
        if url in visited:
            url_queue.task_done()
            continue
            
        if len(visited) > MAX_VISITED_MEMORY:
            visited.clear()
            
        visited.add(url)
        try:
            time.sleep(POLITENESS_DELAY)
            response = requests.get(url, timeout=15)
            
            if response.status_code == 200:
                html_content = response.text
                clean_text = trafilatura.extract(html_content)
                
                if clean_text and len(clean_text) > MIN_TEXT_LENGTH:
                    filename = f"{DATA_DIR}/data_{int(time.time())}_{threading.get_ident()}.txt"
                    with open(filename, "w", encoding="utf-8") as f:
                        f.write(clean_text)
                    print(f"[+] Saved: {url}")
                
                soup = BeautifulSoup(html_content, 'html.parser')
                for link in soup.find_all('a', href=True):
                    next_url = urljoin(url, link['href'])
                    if next_url.startswith('http') and next_url not in visited:
                        url_queue.put(next_url)
                        
        except Exception:
            pass
        finally:
            url_queue.task_done()

if __name__ == "__main__":
    print(f"Starting UNLIMITED crawler with {MAX_THREADS} threads...")
    threads = []
    for _ in range(MAX_THREADS):
        t = threading.Thread(target=crawl, daemon=True)
        t.start()
        threads.append(t)

    try:
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        print("Crawler manually stopped.")
