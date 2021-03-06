require 'json'
require 'net/http'
require 'net/https'
require 'digest/md5'
require 'models'
require 'sinatra/session'
require 'helpers/user_helper'
require 'helpers/business_card_helper'

enable :sessions
set :session_secret, 'So0perSeKr3t!'

get '/' do
  erb :'home/index', {:layout => :'layout/signup'}
end

post '/dashboard' do
  if session[:userid].nil?
    redirect '/'
  else
    redirect "/#{User.get(session[:userid]).email}"
  end
end

get '/dashboard' do
  if session[:userid].nil?
    redirect '/'
  else
    #@myself = User.get(session[:userid])
    @user = User.first(:email => current_user.email)
    @business_cards = @user.business_cards
    erb :'dashboard/index', {:layout => :'layout/application'}
  end
end

post '/login' do
  openid_user = get_user(params[:token])
  user = User.find(openid_user[:identifier])
  if user.nil?
    user = User.new(
      :username => openid_user[:username], 
      :email => openid_user[:email],
      :photo_url => "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(openid_user[:email])}",
      :identifier => openid_user[:identifier]
    )
    user.save
  end
  
  session[:userid] = user.id
  session[:current_user] = user
  
  redirect "/dashboard"
end

get '/logout' do
end

get "/:business_card_url" do
  
end

get "/business_cards/new" do
  if !logged_in? 
    redirect "/" and return
  end
  @business_card = BusinessCard.new
  erb :'business_cards/new', {:layout => :'layout/application'}
end

post "/business_cards" do
  
  business_card = BusinessCard.new(:url => params[:business_card][:url], :title => params[:business_card][:title], :user_id => current_user.id)
  
  if business_card.save
    flash[:success_notice] = "Your card has been created"
    redirect '/dashboard'
  else
    flash[:error_notice] = "Your business card cannot be created due to the following errors"
    errors = []
    business_card.errors.each do |e|
      errors << e
    end
    flash[:errors] = errors
    #flash[:form_values] = params[:business_card]
    redirect '/business_cards/new'
  end
  
end

get "business_cards/[0-9]+/edit" do
  erb :'business_cards/edit', {:layout => :'layout/application'}
end

def get_user(token)
  u = URI.parse('https://rpxnow.com/api/v2/auth_info')
  req = Net::HTTP::Post.new(u.path)
  req.set_form_data({'token' => token, 'apiKey' => '6feb9b83c1ee8667ff2f72bbbbf26b9fa27559d6', 'format' => 'json', 'extended' => 'true'})
  http = Net::HTTP.new(u.host,u.port)
  http.use_ssl = true if u.scheme == 'https'
  json = JSON.parse(http.request(req).body)
  
  if json['stat'] == 'ok'
    identifier = json['profile']['identifier']
    username = json['profile']['preferredUsername']
    username = json['profile']['displayName'] if username.nil?
    email = json['profile']['email']
    {:identifier => identifier, :username => username, :email => email}
  else
    redirect "/"
  end
end