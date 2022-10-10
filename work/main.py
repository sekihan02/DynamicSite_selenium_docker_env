from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome import service as fs
import csv
from bs4 import BeautifulSoup
import collections
collections.Callable = collections.abc.Callable

CHROMEDRIVER = '/opt/chrome/chromedriver'
URL = 'https://deps.dev/cargo/cargo/0.65.0/dependencies'

options = Options()
options.add_argument('--headless')  
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

chrome_service = fs.Service(executable_path=CHROMEDRIVER) 
driver = webdriver.Chrome(service=chrome_service, options=options)
driver.get(URL)
# html = driver.page_source
# print(html)
html = driver.page_source.encode('utf-8')
# soup = BeautifulSoup(html, "lxml")
soup = BeautifulSoup(html, "html.parser")

# テーブルを指定
table = soup.findAll("table", {"class":"OVWfFur2wqvjaKnJrxBi"})[0]
rows = table.findAll("tr")

with open("dependencies.csv", "w", encoding='utf-8') as file:
    writer = csv.writer(file)
    for row in rows:
        csv_row = []
        # for cell in row.findAll(['td', 'th']):
        for cell in row.findAll('td'):
            csv_row.append(cell.get_text())
        writer.writerow(csv_row)