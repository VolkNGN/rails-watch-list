require 'net/http'
require 'json'

API_KEY = '7b45af8f71d63d716fa486d7d0abb8bd'
BASE_URL = 'https://api.themoviedb.org/3'

def fetch_movies
  uri = URI("#{BASE_URL}/movie/popular?api_key=#{API_KEY}&language=en-US&page=1")
  puts "Fetching movies from: #{uri}"

  response = Net::HTTP.get_response(uri)
  puts "HTTP response code: #{response.code}"

  if response.code == "200"
    parsed_response = JSON.parse(response.body)
    if parsed_response['results']
      puts "Fetched #{parsed_response['results'].size} movies successfully."
      parsed_response['results']
    else
      puts "Error: No results found in the response."
      []
    end
  else
    puts "Error: HTTP response code #{response.code}. Message: #{response.message}"
    []
  end
rescue StandardError => e
  puts "An error occurred while fetching movies: #{e.message}"
  []
end

def seed_movies
  movies = fetch_movies
  if movies.empty?
    puts "No movies to seed."
    return
  end

  movies.each_with_index do |movie, index|
    if movie['title'] && movie['overview'] && movie['poster_path']
      Movie.create!(
        title: movie['title'],
        overview: movie['overview'],
        poster_url: "https://image.tmdb.org/t/p/w500#{movie['poster_path']}",
        rating: movie['vote_average']
      )
      puts "Movie ##{index + 1}: '#{movie['title']}' seeded successfully."
    else
      puts "Skipping movie ##{index + 1} due to missing data."
    end
  end

  puts "Seeding complete. #{movies.size} movies processed."
end

# Run the seeding method
seed_movies
