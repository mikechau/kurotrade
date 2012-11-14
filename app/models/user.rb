class User < ActiveRecord::Base
  attr_accessible :email, :name, :password_digest, :username

 	has_many :portfolios
  has_many :groups, :through => :portfolios
end
