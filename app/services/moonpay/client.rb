require 'rest-client'

module Services
  class Moonpay::Client
    attr_accessor :limit, :offset, :start_date

    def initialize(limit = 50, offset = 0, start_date = nil)
      @limit = limit
      @offset = offset
      @start_date = start_date
    end

    def search
      response = RestClient.get(url, headers)
      JSON.parse(response.body)
    end

    private

    def url
      'https://api.moonpay.com/v1/transactions'
    end

    def headers
      { 
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Api-Key #{ENV['MOONPAY_API_KEY']}",
        params: params
      }
    end

    def params
      search_params = { limit: limit, offset: offset }
      return search_params.merge(startDate: start_date) if start_date
      
      search_params
    end
  end
end
