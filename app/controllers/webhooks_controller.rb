class WebhooksController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  protect_from_forgery :except => :receive

  require 'membership'
  include Membership

  SECRET_KEY = ENV["PAYSTACK_PRIVATE_KEY"]

  def receive
    request_headers = request.headers
    payload = JSON.parse(request.body.read)
    data = JSON.generate(payload)
    digest = OpenSSL::Digest.new('sha512')
    hash = OpenSSL::HMAC.hexdigest(digest, SECRET_KEY, data)
    unless hash != request_headers["x-paystack-signature"]
      if payload["event"] == "invoice.update" && payload["data"]["paid"] == true
        customer_code = payload["data"]["customer"]["customer_code"]
        member = Member.find_by(paystack_cust_code: customer_code)
        amount = payload["data"]["amount"]
        description = "Membership Renewal Paystack"
        payload["member_id"] = member.id
        payload.merge{"description" => description, "amount" => amount }
        options = payload.to_hash
        Membership::SubscriptionActivity.new(options).call
        Accounting::Entry.new(options).card_entry
        options.merge!({description: })
        render status: 200, json: {
          message: "success"
        }
      end
    end
  end
end
