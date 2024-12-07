class ImportMoviesService

  def self.import(file)
    ActiveRecord::Base.transaction do
      CSV.foreach(file.path, headers: true) do |row|
        Movie.find_or_create_by!(title: row['title'], year: row['release_year']) do |movie|
          movie.genre = row['type']
          movie.country = row['country']
          movie.published_at = row['date_added']
          movie.description = row['description']
          movie.director = row['director']
          movie.cast = row['cast']
          movie.rating = row['rating']
          movie.duration = row['duration']
          movie.listed_in = row['listed_in']
        end
      end
    end
  end

end