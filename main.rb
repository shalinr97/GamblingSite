require 'sinatra'
require './Database/Users'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/Database/Users.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
  erb :login
end

post '/signup' do
  if(!User.first(username: params[:username]))
    User.create(username: params[:username], password: params[:password],totalWins:"0",totalLoss:"0",totalProfit:"0")
    session[:message] = "Username #{params[:username]} is created"
    redirect '/'
  else
    session[:message] = "Username #{params[:username]} is already created"
    redirect '/signup'
  end
end
post '/login' do
  user = User.first(username: params[:username])
  if user != nil  && user.password != nil &&
      params[:password] == user.password
      session[:name] = params[:username]
      redirect to '/users'
  else
      session[:message] = "Username or Password is incorrect"
      redirect '/'
  end
end

post '/bet' do
  money = params[:money].to_i
  number = params[:number].to_i
  roll = rand(6) + 1
  if number == roll
    save_session(:win, 5*money)
    save_session(:profit, 4*money)
    save_session(:totalWin, 5*money)
    save_session(:totalProfit, 4*money)
    session[:message] = "The dice landed on #{roll}, you choose #{number} and you won #{5*money} dollars"
  else
    save_session(:loss, money)
    save_session(:profit, -1*money)
    save_session(:totalLoss, money)
    save_session(:totalProfit, -1*money)

    session[:message] = "The dice landed on #{roll}, you choose #{number} and you lost #{money} dollars"
  end
  redirect '/bet'
end

post '/logout' do
  user = User.first(username: session[:name])
  user.update(totalWins: session[:totalWin])
  user.update(totalLoss: session[:totalLoss])
  user.update(totalProfit: session[:totalProfit])
  session[:message] = "#{session[:name]} successfully logged out"
  session[:login] = nil
  session[:name] = nil
  redirect '/'
end

def save_session(parameter, money)
  count = (session[parameter] || 0).to_i
  count += money
  session[parameter] = count
end

not_found do
  "Page requested not found"
end
