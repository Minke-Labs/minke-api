require 'rest-client'

module Services
  class Banxa::Client
    attr_accessor :limit, :page, :start_date, :end_date

    def initialize(limit: 100, page: 1, start_date:, end_date:)
      @limit = limit
      @page = page
      @start_date = start_date
      @end_date = end_date
    end

    def search
      response = RestClient.get(url, headers)
      JSON.parse(response.body)['data']['orders']
    end

    private

    def url
      "https://minke.banxa.com/api/orders?#{params.to_query}"
    end

    def headers
      { 
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => authorization
      }
    end

    def authorization
      nonce = Time.now.to_i
      query = '/api/orders'
      data = "GET\n#{query}?#{params.to_query}\n#{nonce}";
      key = ENV['BANXA_KEY']
      secret = ENV['BANXA_SECRET']
    
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA256'), secret, data)
      hmac = "#{key}:#{signature}:#{nonce}";
      "Bearer #{hmac}"
    end

    def params
      { end_date: end_date, page: page, per_page: limit, start_date: start_date, status: 'complete' }
    end
  end
end
