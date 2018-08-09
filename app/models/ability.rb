class Ability
  include CanCan::Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.manager?
      can :manage, :all
    elsif user.supevisor?
      can [:update, :create, :read], [ FitnessGoal, 
                                        Feature,
                                        AttendanceRecord, 
                                        GeneralTransaction, 
                                        AccountDetail,
                                        CashTransaction,
                                        FitnessGoal,
                                        HealthCondition,
                                        ImageUploader,
                                        LoyaltyHistory,
                                        Loyalty,
                                        PauseHistory,
                                        PosTransaction,
                                        SubscriptionHistory,
                                        SubscriptionPlan,
                                        WalletDetail,
                                        WalletHistory,
                                        MemberHealthCondition,
                                        Member,
                                        SubscriptionPlanFeature,
                                        PaymentMethod,
                                        FitnessGoal
                                      ]

      can [:update, :read], User, id: user.id

      cannot :destroy, [  FitnessGoal,
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

    elsif user.officer?
      can :read, [SubscriptionPlan, FitnessGoal, Feature, SubscriptionPlanFeature ]
      can [:update, :create, :read], [  
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
                                        Member,
                                      ]

      can [:update, :read], User, id: user.id
      cannot [:destroy],          [ AttendanceRecord, 
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
