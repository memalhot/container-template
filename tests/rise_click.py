from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chromium.service import ChromiumService


driver = webdriver.Chrome(service=ChromiumService(executable_path=ChromeDriverManager().install()))
driver.get("https://www.google.com/")
print(driver.title)

driver.quit()