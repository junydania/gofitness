class WebhooksController < ApplicationController
  
  skip_before_action :verify_authenticity_token
  protect_from_forgery :except => :receive
  before_action :check_allowed_ip, only: [:receive]

  require 'membership'
  
  include Membership

  SECRET_KEY = ENV["PAYSTACK_PRIVATE_KEY"]

  def receive
    binding.pry
    if check_allowed_ip == true
      request_headers = request.headers
      payload = JSON.parse(request.body.read)
      data = JSON.generate(payload)
      digest = OpenSSL::Digest.new('sha512')
      hash = OpenSSL::HMAC.hexdigest(digest, SECRET_KEY, data)
      unless hash != request_headers["x-paystack-signature"]
        if payload['data']['status'] == 'success'
          member = get_member(payload)
          amount = payload["data"]["amount"]
          options = process_payload(payload, member)
          ProcessWebhookJob.perform_now(options)
          render status: 200, json: {
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


  def process_payload(payload, member)
    amount = payload["data"]["amount"]
    description = "Membership Renewal Paystack"
    payload["member_id"] = member.id
    payload["description"] = description
    payload["amount"] = amount
    options = payload.to_hash
    return options
  end

  def get_member(payload)
    customer_code = payload["data"]["customer"]["customer_code"]
    member = Member.find_by(paystack_cust_code: customer_code)
    return member
  end

  def retrieve_payment_method(member)
    member.payment_method.payment_system
  end


  private

  def check_allowed_ip
    whitelisted = ['41.58.95.200', '52.31.139.75', '52.49.173.169', '52.214.14.220', '127.0.0.1']
    if whitelisted.include? request.remote_ip
      return true
    else
      return false
    end
  end

end
