require 'selenium-webdriver'
require 'nokogiri'
require 'csv'

class SteamScraper
  BASE_URL = 'https://store.steampowered.com/charts/mostplayed'

  def initialize

    @driver = Selenium::WebDriver.for :chrome
    @driver.navigate.to(BASE_URL)
  end

  def scrape_games
    games = []
    doc = Nokogiri::HTML(@driver.page_source)

    doc.css('tr._2-RN6nWOY56sNmcDHu069P').each do |row|
      game_data = {
        name: row.css('td._18kGHKeOavDDdJVs9FVhpo a div._1n_4-zvf0n4aqGEksbgW9N').text.strip,
        price: row.css('td._3IyfUchPbsYMEaGjJU3GOP div._3j4dI1yA7cRfCvK8h406OB').text.strip,
        current_players: row.css('td._3L0CDDIUaOKTGfqdpqmjcy').text.strip,
      }
      games << game_data
    end

    @driver.quit
    save_to_csv(games)
  end

  private

  def save_to_csv(games)
    CSV.open("steam_charts_games.csv", "wb") do |csv|
      csv << [ "Name", "Price", "Current Players"]

      games.each do |game|
        csv << [game[:name], game[:price], game[:current_players]]
      end
    end
    puts "Datos guardados en steam_charts_games.csv"
  end
end

# Uso de ejemplo:
scraper = SteamScraper.new
scraper.scrape_games
