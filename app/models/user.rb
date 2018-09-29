class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  audited
  has_many :login_activities, as: :user
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  enum role: [:manager, :supervisor, :officer, :guest]
  validates_presence_of  :first_name, :last_name, :encrypted_password, :email

  
  def fullname
    "#{first_name} #{last_name}"
  end

  scope :with_user_firstname, (lambda {|user_first_name|
    where('users.first_name = ?', user_first_name)})



end

