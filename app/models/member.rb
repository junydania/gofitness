class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include ImageUploader[:image]
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    has_one  :account_detail
    has_many :member_health_conditions
    has_many :pos_transactions
    accepts_nested_attributes_for :pos_transactions,
                                reject_if: :all_blank, allow_destroy: true

    has_many :cash_transactions
    accepts_nested_attributes_for :cash_transactions,
                                reject_if: :all_blank, allow_destroy: true

    has_many :health_conditions, through: :member_health_conditions
    has_many :loyalty_histories
    has_many :subscription_histories
    
    belongs_to :fitness_goal
    belongs_to :payment_method
    belongs_to :subscription_plan

    validates_presence_of  :first_name, :last_name, :email, :encrypted_password

    def fullname
      "#{first_name} #{last_name}"
    end
    
end
