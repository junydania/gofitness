class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.manager?
      can :manage, :all
    elsif user.supervisor?
      can [:update, :create, :read, :destroy ], [  FitnessGoal,
                                        Feature,
                                        AttendanceRecord,
                                        GeneralTransaction,
                                        AccountDetail,
                                        CashTransaction,
                                        HealthCondition,
                                        ImageUploader,
                                        LoyaltyHistory,
                                        PauseHistory,
                                        PosTransaction,
                                        SubscriptionHistory,
                                        WalletDetail,
                                        WalletHistory,
                                        MemberHealthCondition,
                                        Member,
                                        PaystackCharge,
                                        Charge
                                      ]

      can [:update, :read], User, id: user.id

      can [:read], [ SubscriptionPlan, Loyalty]

      cannot :destroy, [  FitnessGoal,
                          Feature, 
                          AttendanceRecord, 
                          GeneralTransaction, 
                          SubscriptionHistory,
                          WalletDetail,
                          WalletHistory,
                          SubscriptionPlan,
                          MemberHealthCondition,
                          SubscriptionPlanFeature,
                          PaymentMethod
                        ]

    elsif user.officer?
      can :manage, :all
      cannot [:update, :create, :read], User
      cannot [:update, :create], [
        SubscriptionPlan,
        OneOffRevenue,
        PaymentMethod,
        Loyalty,
      ]
      can [:update, :read], User, id: user.id
      cannot [:destroy],          [
                                    AttendanceRecord,
                                    GeneralTransaction, 
                                    AccountDetail,
                                    CashTransaction,
                                    HealthCondition,
                                    ImageUploader,
                                    LoyaltyHistory,
                                    Loyalty,
                                    PauseHistory,
                                    PosTransaction,
                                    SubscriptionHistory,
                                    WalletDetail,
                                    WalletHistory,
                                    MemberHealthCondition,
                                    Member ]
    else
      can :read, [  FitnessGoal,
                    Feature, 
                    AttendanceRecord, 
                    GeneralTransaction, 
                    AccountDetail,
                    CashTransaction,
                    HealthCondition,
                    ImageUploader,
                    LoyaltyHistory,
                    Loyalty,
                    PauseHistory,
                    PosTransaction,
                    SubscriptionHistory,
                    WalletDetail,
                    WalletHistory,
                    SubscriptionPlan,
                    MemberHealthCondition,
                    Member,
                    SubscriptionPlanFeature,
                    PaymentMethod,
                    FitnessGoal ]
    end

  end

end
