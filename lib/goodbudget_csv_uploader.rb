require "selenium-webdriver"

class GoodbudgetCSVUploader
  IMPORT_URL = "https://goodbudget.com/import/upload"
  FILE_UPLOAD_FIELD_ID = "import_upload_file"
  USERNAME_FIELD_ID = "username"
  PASSWORD_FIELD_ID = "password"
  IMPORT_FORM_ID = "import-form"
  ACCOUNT_SELECTOR_DROPDOWN_ID = "import_select_account"
  COLUMN_SELECTOR_ID_PREFIX = "import_choose_columns_columns_"
  CSV_COLUMN_VALUES = {
    0 => "date",
    1 => "amount",
    3 => "name"
  }

  def initialize(username:, password:, account_name:, file_path:)
    @username = username
    @password = password
    @account_name = account_name
    @file_path = file_path
  end

  def run
    driver = Selenium::WebDriver.for :chrome
    driver.navigate.to(IMPORT_URL)

    # Login.
    driver.find_element(:id, USERNAME_FIELD_ID).send_keys(@username)
    password_element = driver.find_element(:id, PASSWORD_FIELD_ID)
    password_element.send_keys(@password)
    password_element.submit

    # Upload the file.
    driver.find_element(:id, FILE_UPLOAD_FIELD_ID).send_keys(@file_path)
    driver.find_element(:id, IMPORT_FORM_ID).submit

    # Choose CSV columns
    CSV_COLUMN_VALUES.each do |column_index, column_mapping|
      column_mapping_dropdown = driver.find_element(:id, COLUMN_SELECTOR_ID_PREFIX + column_index.to_s)
      option_mapping = column_mapping_dropdown.find_elements(:tag_name, "option").detect do |option|
        option.attribute("value").eql?(column_mapping)
      end
      option_mapping.click
    end
    driver.find_element(:tag_name, "form").submit

    # Choose the account.
    account_selector_dropdown = driver.find_element(:id, ACCOUNT_SELECTOR_DROPDOWN_ID)
    desired_account = account_selector_dropdown.find_elements(:tag_name, "option").detect do |option|
      option.attribute("text").include?(@account_name)
    end
    desired_account.click
    driver.find_element(:tag_name, "form").submit
  end
end
