class Api::V1::MoviesController < ApplicationController
  require 'csv'

  def import_movies
    file = params[:file]

    if file.blank?
      return render json: { error: 'Nenhum arquivo enviado' }, status: :unprocessable_entity
    end

    begin
      ImportMoviesService.import(file)
      render json: { message: 'Filmes importados com sucesso!' }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Erro ao criar filme: #{e.record.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
    rescue CSV::MalformedCSVError => e
      render json: { error: "Erro ao ler o arquivo CSV: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "Erro ao importar: #{e.message}" }, status: :unprocessable_entity
    end
  end

  def index
    unless Movie.any?
      return render json: { error: "Não há filmes cadastrados no momento" }, status: :not_found
    end

    movies = Movie.filter_by(params.slice(:year, :genre, :country)).order(:year)
    if movies.any?
      render json: movies.as_json(except: movies_except_attributes), status: :ok
    else
      render json: { error: "Nenhum filme encontrado com o(s) filtro(s) fornecido(s)" }, status: :not_found
    end
  end

  private

  def movies_except_attributes
    [:director, :cast, :rating, :duration, :listed_in, :created_at, :updated_at]
  end

end