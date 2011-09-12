require 'sinatra'
require './config/config'
require 'haml'
require './lib/tickets'
require './lib/users'
require 'sass'

enable :sessions

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def print_message key
    session.delete key
  end
end

get '/' do
  session[:user] = nil
  @users = Users.new.list
  haml :index
end

get '/tickets' do
  redirect '/' if session[:user].nil?
  @user = session[:user].email
  @requester_id = session[:user].id
  @tickets = Tickets.new.list
  haml :tickets
end

post '/tickets' do
  if Ticket.create! params
    session[:message] = 'Ticket Created!'
  else
    session[:error_message] = "Sorry, couldn't create your ticket, please check if description is empty."
  end
  redirect '/tickets'
end

get '/users' do
  if (user = Users.new.search_by_email(params[:email])) && user.email == params[:email]
    session[:user] = user
    redirect '/tickets'
  else
    session[:error_message] = "Sorry, couldn't find user with email #{params[:email]}."
    redirect '/'
  end
end

post '/users' do
  if User.create!(params) && (user = Users.new.search_by_email(params[:email]))
    session[:user] = user
    redirect '/tickets'
  else
    session[:error_message] = "Sorry, couldn't create user, please check if email and/or name are empty."
    redirect '/'
  end
end

get '/stylesheet.css' do
  sass :stylesheet
end