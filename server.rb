require 'sinatra'
require 'csv'

def get_news

  news = []

  CSV.foreach('news.csv', headers: true, header_converters: :symbol) do |row|
    news << row.to_hash
  end

  news

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

    @message = "Sorry, a title, url, and description is required for article submission."

    erb :submit

  else

    CSV.open('news.csv', 'a') do |row|
      row << [@title, @url]
    end

    redirect '/'
  end

end
