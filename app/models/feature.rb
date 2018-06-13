class Feature < ApplicationRecord
    has_many :subscription_plan_features
    has_many :subscription_plans, through: :subscription_plan_features
    validates_presence_of :name, :description
end

