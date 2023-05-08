from selenium import webdriver
import chromedriver_autoinstaller

chromedriver_autoinstaller.install()
driver = webdriver.Chrome()
driver.get('http://github.com')
print(driver.title)