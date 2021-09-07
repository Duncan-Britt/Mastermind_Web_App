require "sinatra"
require "sinatra/reloader" if development?
require 'sinatra/content_for'
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

get '/' do
  erb :home, layout: :layout
end

get '/play/code_breaker' do
  session[:turn] ||= 1

  erb :code_breaker, layout: :layout
end

post '/play/code_breaker' do
  session[:turn] += 1
end
