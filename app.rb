require 'sinatra'
require 'csv'
require 'json'

# Leer datos desde el archivo CSV
def read_csv(file_path)
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

DATA = read_csv('metacritic_games.csv')

get '/data' do
  content_type :json
  DATA.to_json
end

get '/' do
  erb :index
end

