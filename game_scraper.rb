require 'nokogiri'
require 'httparty'
require 'csv'

class GameScraper
  BASE_URL = "https://www.metacritic.com"
  USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:115.0) Gecko/20100101 Firefox/115.0"
  ]

  def initialize(output_file)
    @page = 1
    @output_file = output_file
  end

  def scrape_all_pages
    CSV.open(@output_file, 'wb', write_headers: true, headers: %w[Title Platform Release_Date Metascore]) do |csv|
      loop do
        url = "#{BASE_URL}/browse/game/pc/all/current-year/metascore/?platform=pc&page=#{@page}"
        games = scrape_page(url)
        break if games.empty?
        games.each do |game|
          genre = scrape_game_genre(game[:link])
          csv << [game[:title], game[:release_date], game[:metascore], genre]
          sleep(1)
        end
        @page += 1
        sleep(2)
      end
    end
    puts "Scraping completed! Data saved to #{@output_file}."
  end
  def scrape_new
    CSV.open(@output_file, 'wb', write_headers: true, headers: %w[Title Platform Release_Date Genre]) do |csv|
      loop do
        url = "#{BASE_URL}/browse/game/pc/all/current-year/new/?platform=pc&page=#{@page}"
        games = scrape_page(url)
        break if games.empty? || @page > 10

        games.each do |game|
          genre = scrape_game_genre(game[:link])
          csv << [game[:title], "PC", game[:release_date], genre]
          sleep(1)
        end
        @page += 1
        sleep(2)
      end
    end
    puts "Scraping completed! Data saved to #{@output_file}."
  end

  private

  def scrape_page(url)
    response = HTTParty.get(url, headers: { "User-Agent" => USER_AGENTS.sample })
    if response.code != 200
      puts "Failed to retrieve page: #{url}"
      return []
    end

    parsed_page = Nokogiri::HTML(response.body)
    games = []

    parsed_page.css('.c-finderProductCard').each do |game|
      title = game.css('.c-finderProductCard_titleHeading span').last.text.strip
      release_date = game.css('.c-finderProductCard_meta .u-text-uppercase').text.strip
      metascore = game.css('.c-siteReviewScore span').text.strip
      link = BASE_URL + game.css('a').attr('href').value

      games << { title: title, release_date: release_date, metascore: metascore, link: link }
    end

    games
  end
  def scrape_game_genre(game_url)
    response = HTTParty.get(game_url, headers: { "User-Agent" => USER_AGENTS.sample })
    if response.code != 200
      puts "Failed to retrieve game page: #{game_url}"
      return "N/A"
    end

    parsed_page = Nokogiri::HTML(response.body)
    genre = parsed_page.css('.c-genreList_item span').text.strip

    genre.empty? ? "N/A" : genre
  end
end


scraper = GameScraper.new('metacritic_games.csv')
scraper.scrape_all_pages
scraper2 = GameScraper.new('new_games.csv')
scraper2.scrape_new