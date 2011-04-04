require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
require 'dm-validations'
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
  
  property :id,         Serial
  property :user_id,    Integer
  property :url,        String, :length => 255
  property :title,      String, :length => 255
  property :card_type,  String, :length => 255
  property :status,     String, :length => 50
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :user
  
  validates_presence_of :title, :message => 'Title is required'
  validates_presence_of :url, :message => 'Url is required'
  validates_uniqueness_of :url, :message => 'This url is not available'
  
end

