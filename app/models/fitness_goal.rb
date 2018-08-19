class FitnessGoal < ApplicationRecord
    
    has_many :members
    validates_presence_of :goal_name

    def self.options_for_select
        order('LOWER(goal_name)').map { |e| [e.goal_name, e.id]}
    end
     
end
