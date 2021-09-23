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
  session[:guesses] ||= {}
  session[:solved] ||= false
end

get '/play/code_breaker' do
  new_client_setup

  erb :code_breaker, layout: :layout
end

def response_clues(guess)
  unguessed_code = []
  non_exact_guesses = []
  clues = []

  session[:code].each_with_index do |n, i|
    if n == guess[i]
      clues << 'x'
    else
      unguessed_code << n
      non_exact_guesses << guess[i]
    end
  end

  session[:digit_range].each do |n|
    [unguessed_code.count(n), non_exact_guesses.count(n)].min.times do
      clues << 'o'
    end
  end

  clues.join(" ")
end

post '/play/code_breaker' do
  guess = params[:guess].chars.map { |n| Integer(n) } # [int, int, int, int]

  # if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
  #   status 200
  # else
  #   redirect '/play/code_breaker'
  # end
  clue = response_clues(guess)
  session[:guesses][session[:turn]] = [params[:guess], clue]
  session[:turn] += 1
  if guess == session[:code]
    session[:solved] = true
    "1#{clue}"
  elsif session[:turn] == 13
    "2#{clue}"
  else
    "0#{clue}"
  end
end

def new_game_reset
  session[:code_size] = 4
  session[:digit_range] = (1..6)
  session[:turn] = 1
  session[:code] = random_code(
    code_size: session[:code_size],
    digit_range: session[:digit_range]
  )
  session[:guesses] = {}
  session[:previous_ai_guesses] = [random_code]
  session[:previous_clues_for_ai] = []
  session[:solved] = false
end

get '/play_again' do
  new_game_reset
  redirect '/play/code_breaker'
end

get '/play/code_maker' do
  if session[:previous_ai_guesses]
    @new_guess = session[:previous_ai_guesses].last.join
  end
  erb :code_maker, layout: :layout
end

post '/play/code_maker' do
  session[:turn] += 1
  session[:previous_clues_for_ai] << params[:clues]
  session[:previous_ai_guesses] << random_code
  redirect '/play/code_maker'
end

post '/secret_code_ready' do
  new_game_reset
  session[:start_guess] = true
  redirect '/play/code_maker'
end
