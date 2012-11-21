class User < ActiveRecord::Base
  attr_accessible :email, :name, :password_digest, :username, :password, :password_confirmation
  has_secure_password

 	has_many :portfolios
  has_many :groups, :through => :portfolios

  validates_presence_of :email, :name, :username, :password, :password_confirmation
  validates_uniqueness_of :email, :username
end
