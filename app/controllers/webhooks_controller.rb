class WebhooksController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  protect_from_forgery :except => :receive
  before_action :check_allowed_ip, only: [:receive]

  require 'membership'
  
  include Membership

  SECRET_KEY = ENV["PAYSTACK_PRIVATE_KEY"]

  def receive
    if check_allowed_ip == true
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
          payload["description"] = description
          payload["amount"] = amount
          options = payload.to_hash
          fund_method = retrieve_payment_method(member)
          Membership::SubscriptionActivity.new(options).call
          Accounting::Entry.new(options).card_entry
          create_charge(member, amount, fund_method)
          render status: 201, json: {
            message: "success"
          }
        end
      end
    else
      render status: 401, json: {
        message: "Unauthorized"
      }

    end
  end


  def retrieve_payment_method(member)
    member.payment_method.payment_system
  end

  def create_charge(member, amount, fund_method)
    duration = member.subscription_plan.duration
    charge = member.charges.new(service_plan: "Membership Renewal",
                                amount: amount,
                                payment_method: fund_method,
                                duration: duration,
                                gofit_transaction_id: SecureRandom.hex(4) )
    if charge.save
        MemberMailer.renewal(member).deliver_later
    end
  end

  private

  def check_allowed_ip
    whitelisted = ['41.215.245.188', '52.31.139.75', '52.49.173.169', '52.214.14.220']
    if whitelisted.include? request.remote_ip
      return true
    else
      return false
    end
  end

end
