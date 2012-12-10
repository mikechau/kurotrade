class User < ActiveRecord::Base
  attr_accessible :email, :name, :username, :password_digest, :password, :password_confirmation
  has_secure_password

 	has_many :portfolios
  has_many :groups, :through => :portfolios

  validates_presence_of :email, :name, :username, :password, :password_confirmation
  validates_uniqueness_of :email, :username

  before_update :revert_username_if_changed, :if => Proc.new { |u| u.username_changed? }

  def revert_username_if_changed
    self.username = self.username_was
  end

end
