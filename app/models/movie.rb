class Movie < ApplicationRecord
  
  validates :title, presence: true

  scope :filter_by, ->(filters) {
    results = all
    results = results.where(year: filters[:year]) if filters[:year].present?
    results = results.where(genre: filters[:genre]) if filters[:genre].present?
    results = results.where(country: filters[:country]) if filters[:country].present?
    results
  }
end
