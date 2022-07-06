require 'rest-client'

module Services
  class Wyre::Client
    attr_accessor :limit, :offset

    def initialize(limit = 1000, offset = 0)
      @limit = limit
      @offset = offset
    end

    def search
      response = RestClient.get(url, headers)
      JSON.parse(response.body)['data']
    end

    private

    def url
      'https://api.sendwyre.com/v3/orders/list'
    end

    def headers
      { 
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV['WYRE_API_KEY']}",
        params: params
      }
    end

    def params
      { limit: limit, offset: offset }
    end
  end
end
