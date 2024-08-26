require 'sinatra'
require 'csv'
require 'json'

# Leer datos desde el archivo CSV
def read_csv_game(file_path)
  data = []
  CSV.foreach(file_path, headers: true) do |row|
    data << {
      "Title" => row["Title"],
      "Platform" => row["Platform"],
      "Release_Date" => row["Release_Date"],
      "Metascore" => row["Metascore"].to_i,
      "Genre" => row["Genre"]
    }
  end
  data
end

DATA = read_csv_game('metacritic_games.csv')

def read_csv_game_with_price(file_path)
  data = []
  CSV.foreach(file_path, headers: true) do |row|
    price = row["Price"].strip

    # Eliminar el signo de dólar si está presente
    price = price.sub(/\$/, '')

    if price.downcase == "free to play"
      price_value = 0.0
    else
      # Asegúrate de manejar casos donde el valor pueda no ser un número válido
      price_value = price.match(/\d+(\.\d+)?/) ? price.to_f : nil
    end


    current_players = row["Current Players"].strip.gsub(/[\n,]/, '')
    current_players_value = current_players.match(/\d+/) ? current_players.to_i : 0
    data << {
      "Name" => row["Name"],
      "Price" => price_value.to_f,
      "Current Players" => current_players_value
    }
  end
  data
end

def calculate_players_by_price_range(data)
  ranges = {
    "0.0" => 0,
    "0.01 - 9.99" => 0,
    "10.00 - 19.99" => 0,
    "20.00 - 29.99" => 0,
    "30.00 - 39.99" => 0,
    "40.00 - 49.99" => 0,
    "50.00 - 59.99" => 0,
    "60.00 - 69.99" => 0
  }

  data.each do |game|
    price = game["Price"]
    players = game["Current Players"]
    if price == 0
      ranges["0.0"] += players
    elsif price.between?(0.01, 9.99)
      ranges["0.01 - 9.99"] += players
    elsif price.between?(10.00, 19.99)
      ranges["10.00 - 19.99"] += players
    elsif price.between?(20.00, 29.99)
      ranges["20.00 - 29.99"] += players
    elsif price.between?(30.00, 39.99)
      ranges["30.00 - 39.99"] += players
    elsif price.between?(40.00, 49.99)
      ranges["40.00 - 49.99"] += players
    elsif price.between?(50.00, 59.99)
      ranges["50.00 - 59.99"] += players
    elsif price.between?(60.00, 69.99)
      ranges["60.00 - 69.99"] += players
    end
  end

  ranges
end
DATA2 = read_csv_game_with_price('steam_charts_games.csv')

# Calcular los datos para la suma de jugadores por rango de precio
PLAYERS_BY_PRICE_RANGE = calculate_players_by_price_range(DATA2)

get '/price_ranges' do
  content_type :json
  PLAYERS_BY_PRICE_RANGE.to_json
end


get '/data' do
  content_type :json
  DATA.to_json
end

get '/' do
  erb :index
end

