class BetaUser < ActiveRecord::Base
  attr_accessible :category, :email, :name

  validates_presence_of :email, :name
  validates_uniqueness_of :email

end
