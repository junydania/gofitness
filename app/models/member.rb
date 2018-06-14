class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    has_many :member_health_conditions
    has_many :health_conditions, through: :member_health_conditions
    belongs_to :fitness_goal
    belongs_to :payment_method
    belongs_to :subscription_plan

    validates_presence_of  :first_name, :last_name, :email, :encrypted_password

end
