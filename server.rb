require 'sinatra'
require 'csv'
require 'uri'
require 'redis'

def get_connection
  if ENV.has_key?("REDISCLOUD_URL")
    Redis.new(url: ENV["REDISCLOUD_URL"])
  else
    Redis.new
  end
end

def find_articles
  redis = get_connection
  serialized_articles = redis.lrange("slacker:articles", 0, -1)

  articles = []

  serialized_articles.each do |article|
    articles << JSON.parse(article, symbolize_names: true)
  end

  articles
end

def save_article(url, title, description)
  article = { url: url, title: title, description: description }

  redis = get_connection
  redis.rpush("slacker:articles", article.to_json)
end

# def get_news

#   news = []

#   CSV.foreach('news.csv', headers: true, header_converters: :symbol) do |row|
#     news << row.to_hash
#   end

#   news

# end

# URL validation method found @ http://stackoverflow.com/questions/7167895/whats-a-good-way-to-validate-links-urls-in-rails-3
def valid?(uri)
  !!URI.parse(uri)
rescue URI::InvalidURIError
  false
end

get '/' do

  @news = find_articles

  erb :index

end

get '/x' do

  erb :submit

end

post '/x' do

  # variables for form data
  @title = params[:title]
  @url = params[:url]
  @text = params[:text]

  if @title == "" || @url == "" || @text == ""

    @message = "*Sorry, a title, url, and description is required for article submission."

    erb :submit

  elsif !valid?(@url)

    @message = "Sorry, that url is invalid. Try again."

    erb :submit

  elsif @text.length < 20

    @message = "Sorry, descriptions must be 20 characters or more."

    erb :submit

  else

    # CSV.open('news.csv', 'a') do |row|
    #   row << [@title, @url, @text]
    # end

    save_article(@url, @title, @text)

    redirect '/'
  end

end
