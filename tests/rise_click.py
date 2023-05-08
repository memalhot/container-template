from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.core.utils import ChromeType

driver_path = ChromeDriverManager().install()
driver = webdriver.Chrome(driver_path)
driver.get("https://www.google.com/")
print(driver.title)

driver.quit()