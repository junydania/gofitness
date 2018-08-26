class PauseHistory < ApplicationRecord
    audited
    
    belongs_to :member
end
