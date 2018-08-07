class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    protect_from_forgery :except => :receive


  def receive
    binding.pry
    if request.headers['Content-Type'] == 'application/json'
      data = JSON.parse(request.body.read)
    else
      # application/x-www-form-urlencoded
      data = params.as_json
    end

    SECRET_KEY = 'key'
    data = request.body.read
    digest = OpenSSL::Digest.new('sha1')

    OpenSSL::HMAC.digest(digest, key, data)

    OpenSSL::HMAC.hexdigest(digest, key, data)

  end

  

end
