class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :genre
      t.integer :year
      t.string :country
      t.date :published_at
      t.text :description
      t.string :director
      t.text :cast
      t.string :rating
      t.string :duration
      t.string :listed_in
      
      t.timestamps
    end
  end
end
