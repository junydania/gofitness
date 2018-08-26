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
    # unless hash != "5e3390a5e2c75b6ad76e80f7a5069d5ee7eeb2a30520c74ce58db588f55011bb3bc42ac1db59f74e739b93edf35a936f03f3e615c1670cb9d5f7be9c963618b1"   
      if payload["event"] == "invoice.update" && payload["data"]["paid"] == true
        customer_code = payload["data"]["customer"]["customer_code"]
        member = Member.find_by(paystack_cust_code: customer_code)
        payload["member_id"] = member.id
        payload.merge!{description: 'Membership Renewal Paystack', amount: payload["data"]["amount"] }
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
