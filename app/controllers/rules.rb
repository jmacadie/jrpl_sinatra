class App < Sinatra::Application
  get '/rules' do
    user_signed_in?
    erb :rules
  end
end
