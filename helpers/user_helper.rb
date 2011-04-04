require 'sinatra/session'

enable :sessions

helpers do
  
  def logged_in?
    return !session[:userid].nil?
  end
  
  def current_user
    return session[:current_user]
  end
  
end