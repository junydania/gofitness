module Accounting

    class Entry

        def initialize(options)
            @amount = options["amount"].to_i / 100
            @description = options["description"]
        end

        def card_entry
            tax = @amount.to_f * 0.05
            profit = @amount.to_f - tax
            entry = Plutus::Entry.create(
                :description => @description,
                :debits => [
                  {account_name: "Card Payment", amount: @amount}],
                :credits => [
                  {account_name: "Sales Revenue", amount: profit},
                  {account_name: "Sales Tax Payable", amount: tax }])
        end

        def cash_entry
            tax = @amount.to_f * 0.05
            profit = @amount.to_f - tax
            entry = Plutus::Entry.create(
                :description => @description,
                :debits => [
                  {account_name: "Cash", amount: @amount}],
                :credits => [
                  {account_name: "Sales Revenue", amount: profit},
                  {account_name: "Sales Tax Payable", amount: tax}])
        end

    end
end


