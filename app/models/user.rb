class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  audited
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  enum role: [:manager, :supervisor, :officer, :guest]
  validates_presence_of  :first_name, :last_name, :encrypted_password, :email

  
  def fullname
    "#{first_name} #{last_name}"
  end

end

