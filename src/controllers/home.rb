class App < Sinatra::Application
  get '/' do
    user_signed_in?
    erb :home
  end

  not_found do
    redirect '/'
  end
end
