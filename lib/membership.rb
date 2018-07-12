module Membership
    class MemberActivity

        def initialize(param)
            @member = Member.find(param[:id])
        end


        


    end

end
