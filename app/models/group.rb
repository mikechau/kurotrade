class Group < ActiveRecord::Base
  attr_accessible :name

  has_many :portfolios
  has_many :transactions
  has_many(:users, { :through => :portfolios })
end
