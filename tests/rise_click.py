from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service


driver = webdriver.Chrome(service=Service(executable_path=ChromeDriverManager().install()))
driver.get("https://www.google.com/")
print(driver.title)

driver.quit()