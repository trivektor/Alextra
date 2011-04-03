require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
require 'open-uri'

DataMapper.setup(:default, 'mysql://root:root@127.0.0.1:8889/alextra')

class User
  
  include DataMapper::Resource
  
  property :id,         Serial
  property :email,      String, :length => 255
  property :username,   String, :length => 255
  property :identifier, String, :length => 255
  property :photo_url,  String, :length => 255
  
  has n, :business_cards
  
  def self.find(identifier)
    u = first(:identifier => identifier)
    #u = new(:identifier => identifier) if u.nil?
    return u
  end
  
end

class BusinessCard
  
  include DataMapper::Resource
  
  property :id, Serial
  property :created_at, DateTime
  belongs_to :user
  
end

