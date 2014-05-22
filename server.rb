require 'sinatra'
require 'csv'
require 'uri'

def get_news

  news = []

  CSV.foreach('news.csv', headers: true, header_converters: :symbol) do |row|
    news << row.to_hash
  end

  news

end

# URL validation method found @ http://stackoverflow.com/questions/7167895/whats-a-good-way-to-validate-links-urls-in-rails-3
def valid?(uri)
  !!URI.parse(uri)
rescue URI::InvalidURIError
  false
end

get '/' do

  @news = get_news

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

  else

    CSV.open('news.csv', 'a') do |row|
      row << [@title, @url]
    end

    redirect '/'
  end

end
