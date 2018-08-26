class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  audited
  
  has_associated_audits

  include ImageUploader[:image]
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

    has_one  :account_detail, :dependent => :destroy
    accepts_nested_attributes_for :account_detail, update_only: true

    has_many :member_health_conditions
    has_many :pos_transactions
    accepts_nested_attributes_for :pos_transactions,
                                reject_if: :all_blank, allow_destroy: true

    has_many :cash_transactions
    accepts_nested_attributes_for :cash_transactions,
                                reject_if: :all_blank, allow_destroy: true

    has_many :health_conditions, through: :member_health_conditions

    has_many :loyalty_histories
    accepts_nested_attributes_for :loyalty_histories,
                                reject_if: :all_blank, allow_destroy: true

    has_many :subscription_histories
    accepts_nested_attributes_for :subscription_histories,
                                reject_if: :all_blank, allow_destroy: true

    has_many :pause_histories

    has_many :attendance_records

    has_one  :wallet_detail, :dependent => :destroy

    has_many  :wallet_histories
    
    belongs_to :fitness_goal
    belongs_to :payment_method
    belongs_to :subscription_plan

    validates_presence_of  :first_name, :last_name, :email, :encrypted_password

    def fullname
      "#{first_name} #{last_name}"
    end

    scope :with_subscription_plan_id, (lambda {|subscription_plan_id|
      where(subscription_plan_id: [*subscription_plan_id])})
  
  scope :with_fitness_goal_id, (lambda {|fitness_goal_id|
      where(fitness_goal_id: [*fitness_goal_id])})
  
  scope :with_payment_method_id, (lambda {|payment_method_id|
      where(payment_method_id: [*payment_method_id])})
  
  scope :with_fitness_goal_name, (lambda {|fitness_goal_name|
      where('fitness_goals.goal_name = ?', fitness_goal_name).joins(:fitness_goal)
  })
  
  scope :with_payment_method_name, (lambda {|payment_method_name|
      where('payment_methods.payment_system = ?', payment_method_name).joins(:payment_method)
  })
  
  scope :with_subscription_plan_name, (lambda {|subscription_plan_name|
      where('subscription_plans.plan_name = ?', subscription_plan_name).joins(:subscription_plan)
  })
  
  scope :with_member_status, (lambda {|status|
      where('account_detail.member_status = ?', status).joins(:account_detail)
  })
  
  scope :sorted_by, (lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^created_at_/
        order("members.created_at #{direction}")
      when /^first_name/
        order("LOWER(members.first_name) #{direction}")
      when /^last_name/
        order("LOWER(members.last_name) #{direction}")
      when /^customer_code/
        order("members.customer_code #{direction}")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  })

  scope :created_at_gte, (lambda { |reference_time|
    where('members.created_at >= ?', reference_time)
  })


  scope :search_query, (lambda { |query|
    nil if query.blank?
    terms = []
    terms << query
    num_or_conditions = 2
    where(
        terms.map {
          or_clauses = [
              "members.customer_code = ?",
              "members.phone_number = ?",
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    ).joins(:subscription_plan)
  })

  scope :search_names, (lambda { |query|
    nil if query.blank?
    terms = query.to_s.downcase.split(/\s+/)
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    num_or_conditions = 2
    where(
        terms.map {
          or_clauses = [
              "LOWER(members.first_name) LIKE ?",
              "LOWER(members.last_name) LIKE ?"
          ].join(' OR ')
          "(#{ or_clauses })"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
    ).joins(:subscription_plan)
  })


  def self.options_for_sorted_by
    [
        ['First Name (a-z)', 'first_name_asc'],
        ['Last Name (a-z)', 'last_name_asc' ],
        ['Created date (newest first)', 'created_at_desc'],
        ['Created Date (oldest first)', 'created_at_asc'],
        ['SubscriptionPlan (a-z)', 'plan_name_asc'],
        ['Customer Code', 'customer_code_asc' ],
    ]
  end

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :search_names,
      :with_subscription_plan_id,
      :with_fitness_goal_id,
      :with_payment_method_id,
      :with_created_at_gte,
      :with_member_status
    ]
  )

  def self.with_account_details
    Member.select('members.*, account_details.member_status as member_status, 
                    subscription_plans.plan_name as subscription_plan,
                    payment_methods.payment_system as payment_method').joins(:account_detail, :subscription_plan, :payment_method)
  end
    
end
