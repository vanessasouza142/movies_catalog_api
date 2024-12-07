require 'rails_helper'

RSpec.describe 'Movie API', type: :request do
  context 'POST/api/v1/movies/import_movies' do
    it 'faz a leitura de um arquivo CSV e cria filmes' do
      # Arrange
      csv_content = <<~CSV
        title,genre,year,country,published_at,description,director,cast,rating,duration,listed_in
        Movie 1,Action,2020,USA,2020-06-05,"Description for Test Movie 1",Director 1,"Actor A, Actor B",PG-13,120 min,"Action & Adventure"
        Movie 2,Comedy,2010,UK,2010-04-03,"Description for Test Movie 2",Director 2,"Actor C, Actor D",R,90 min,"Comedy Movies"
      CSV
      file_path = Rails.root.join('tmp', 'movies.csv')
      File.write(file_path, csv_content)

      # Act
      post '/api/v1/movies/import_movies', params: { file: fixture_file_upload(file_path, 'text/csv') }

      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "message" => "Filmes importados e criados com sucesso!" })
      expect(Movie.count).to eq 2
      expect(Movie.first.title).to eq 'Movie 1'
      expect(Movie.last.title).to eq 'Movie 2'
    end

    it 'retorna mensagem de erro quando nenhum arquivo é enviado' do
      # Arrange

      # Act
      post '/api/v1/movies/import_movies', params: {}

      # Assert
      expect(response.status).to eq 422
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "error" => "Nenhum arquivo enviado" })
    end

    it 'retorna mensagem de erro ao criar filme sem título' do
      # Arrange
      csv_content = <<~CSV
        genre,year,country,published_at,description,director,cast,rating,duration,listed_in
        Action,2020,USA,2020-06-05,"Description for Test Movie 1",Director 1,"Actor A, Actor B",PG-13,120 min,"Action & Adventure"
      CSV
      file_path = Rails.root.join('tmp', 'movies.csv')
      File.write(file_path, csv_content)

      # Act
      post '/api/v1/movies/import_movies', params: { file: fixture_file_upload(file_path, 'text/csv') }

      # Assert
      expect(response.status).to eq 422
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "error" => "Erro ao criar filme: Título não pode ficar em branco" })
      expect(Movie.count).to eq 0
    end

  end

  context 'GET/api/v1/movies' do
    it 'lista todos os filmes cadastrados por ano de lançamento' do
      # Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1",cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")

      # Act
      get '/api/v1/movies'

      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 2
      expect(json_response[0]["title"]).to eq 'Movie 2'
      expect(json_response[0]["genre"]).to eq 'Comedy'
      expect(json_response[0]["year"]).to eq 2010
      expect(json_response[1]["title"]).to eq 'Movie 1'
      expect(json_response[1]["genre"]).to eq 'Action'
      expect(json_response[1]["year"]).to eq 2020
    end

    it 'filtra filmes pelo ano' do
      #Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1",cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")
      movie3 = Movie.create!(title: "Movie 3", genre: "Drama", year: 2010, country: "USA", published_at: Date.new(2010, 7, 15), description: "Description for Test Movie 3",
                            director: "Director 3", cast: "Actor E, Actor F", rating: "PG", duration: "110 min", listed_in: "Drama Movies")

      # Act
      get '/api/v1/movies', params: { year: 2010 }

      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 2
      expect(json_response[0]["title"]).to eq "Movie 2"
      expect(json_response[0]["year"]).to eq 2010
      expect(json_response[1]["title"]).to eq "Movie 3"
      expect(json_response[1]["year"]).to eq 2010
    end

    it 'filtra filmes pelo gênero' do
      # Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1", cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")
      movie3 = Movie.create!(title: "Movie 3", genre: "Comedy", year: 2015, country: "USA", published_at: Date.new(2015, 7, 15), description: "Description for Test Movie 3",
                            director: "Director 3", cast: "Actor E, Actor F", rating: "PG", duration: "110 min", listed_in: "Comedy Movies")
    
      # Act
      get '/api/v1/movies', params: { genre: "Comedy" }
    
      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 2
      expect(json_response[0]["title"]).to eq "Movie 2"
      expect(json_response[0]["genre"]).to eq "Comedy"
      expect(json_response[1]["title"]).to eq "Movie 3"
      expect(json_response[1]["genre"]).to eq "Comedy"
    end

    it 'filtra filmes pelo país' do
      # Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1", cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")
      movie3 = Movie.create!(title: "Movie 3", genre: "Drama", year: 2015, country: "USA", published_at: Date.new(2015, 7, 15), description: "Description for Test Movie 3",
                            director: "Director 3", cast: "Actor E, Actor F", rating: "PG", duration: "110 min", listed_in: "Drama Movies")
    
      # Act
      get '/api/v1/movies', params: { country: "USA" }
    
      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 2
      expect(json_response[0]["title"]).to eq "Movie 3"
      expect(json_response[0]["country"]).to eq "USA"
      expect(json_response[1]["title"]).to eq "Movie 1"
      expect(json_response[1]["country"]).to eq "USA"
    end
    
    it 'filtra filmes por ano, gênero e país' do
      # Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1", cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")
      movie3 = Movie.create!(title: "Movie 3", genre: "Drama", year: 2010, country: "USA", published_at: Date.new(2010, 7, 15), description: "Description for Test Movie 3",
                            director: "Director 3", cast: "Actor E, Actor F", rating: "PG", duration: "110 min", listed_in: "Drama Movies")
      movie4 = Movie.create!(title: "Movie 4", genre: "Drama", year: 2010, country: "UK", published_at: Date.new(2010, 8, 20), description: "Description for Test Movie 4",
                            director: "Director 4", cast: "Actor G, Actor H", rating: "PG", duration: "105 min", listed_in: "Drama Movies")
    
      # Act
      get '/api/v1/movies', params: { year: 2010, genre: "Drama", country: "UK" }
    
      # Assert
      expect(response.status).to eq 200
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq 1
      expect(json_response[0]["title"]).to eq "Movie 4"
      expect(json_response[0]["year"]).to eq 2010
      expect(json_response[0]["genre"]).to eq "Drama"
      expect(json_response[0]["country"]).to eq "UK"
    end

    it 'retorna mensagem de erro se não tem filmes cadastrados' do
      # Arrange

      # Act
      get '/api/v1/movies'

      # Assert
      expect(response.status).to eq 404
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "error" => "Não há filmes cadastrados no momento" })
    end

    it 'retorna mensagem de erro se não tem filmes cadastrados com o(s) filtro(s) fornecido(s)' do
      # Arrange
      movie1 = Movie.create!(title: "Movie 1", genre: "Action", year: 2020, country: "USA", published_at: Date.new(2020, 6, 5), description: "Description for Test Movie 1",
                            director: "Director 1", cast: "Actor A, Actor B", rating: "PG-13", duration: "120 min", listed_in: "Action & Adventure")
      movie2 = Movie.create!(title: "Movie 2", genre: "Comedy", year: 2010, country: "UK", published_at: Date.new(2010, 4, 3), description: "Description for Test Movie 2",
                            director: "Director 2", cast: "Actor C, Actor D", rating: "R", duration: "90 min", listed_in: "Comedy Movies")
      movie3 = Movie.create!(title: "Movie 3", genre: "Drama", year: 2010, country: "USA", published_at: Date.new(2010, 7, 15), description: "Description for Test Movie 3",
                            director: "Director 3", cast: "Actor E, Actor F", rating: "PG", duration: "110 min", listed_in: "Drama Movies")
      
      # Act
      get '/api/v1/movies', params: { year: 2010, genre: "Terror", country: "USA" }

      # Assert
      expect(response.status).to eq 404
      expect(response.content_type).to include 'application/json'
      json_response = JSON.parse(response.body)
      expect(json_response).to eq({ "error" => "Nenhum filme encontrado com o(s) filtro(s) fornecido(s)" })
    end
  end
end