class FitnessGoal < ApplicationRecord
    
    has_many :members
    validates_presence_of :goal_name
    
    
end
