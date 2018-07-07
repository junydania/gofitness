module GoFitPaystack

    def self.instantiate_paystack
        public_key = ENV["PAYSTACK_PUBLIC_KEY"]
        secret_key = ENV["PAYSTACK_PRIVATE_KEY"]
        paystackObj = Paystack.new
        return paystackObj
    end    
end
