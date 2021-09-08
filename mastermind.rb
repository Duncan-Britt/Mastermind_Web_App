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

class InvalidRangeError < StandardError; end

def valid_range?(range)
  range.max <= 9 && range.min >= -9
end

def random_code(code_size: 4, digit_range: (1..6))
  unless valid_range?(digit_range)
    raise InvalidRangeError.new(
      'Digit range must be a range containing single digit integers only'
    )
  end

  code = []
  code_size.times { code << rand(digit_range.size) + digit_range.min }
  code
end

def new_client_setup
  session[:code_size] ||= 4
  session[:digit_range] ||= (1..6)
  session[:turn] ||= 1
  session[:code] ||= random_code(
    code_size: session[:code_size],
    digit_range: session[:digit_range]
  )
end

get '/play/code_breaker' do
  new_client_setup

  erb :code_breaker, layout: :layout
end

post '/play/code_breaker' do
  session[:turn] += 1

  guess = params[:guess].chars.map { |n| Integer(n) } # [int, int, int, int]
  p guess

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    status 204
  else
    redirect '/play/code_breaker'
  end
end
