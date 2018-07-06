module GoFitPaystack

    def self.instantiate_paystack
        public_key = ENV["PAYSTACK_PUBLIC_KEY"]
        secret_key = ENV["PAYSTACK_SECRET_KEY"]
        paystackObj = Paystack.new(public_key, secret_key)
        return paystackObj
    end
    
end
