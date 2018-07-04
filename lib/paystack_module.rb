module GoFitPaystack

    def self.instantiate_paystack
        public_key = ENV["PAYSTACK_TEST_PUBLIC"]
        secret_key = ENV["PAYSTACK_TEST_SECRET"]
        paystackObj = Paystack.new(public_key, secret_key)
        return paystackObj
    end
    
end
