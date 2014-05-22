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


