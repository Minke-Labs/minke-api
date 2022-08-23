require 'rest-client'

module Services
  class Zapper::Client
    def search
      response = RestClient.get(url, headers)
      JSON.parse(response.body)['data']
    end

    private

    def url
      "https://api.zapper.fi/v2/transactions?address=#{contract}&addresses%5B%5D=#{contract}&network=polygon"
    end

    def contract
      '0x986089f230df31d34a1bae69a08c11ef6b06ecba'
    end

    def headers
      { 
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Basic #{ENV['ZAPPER_API_KEY']}"
      }
    end
  end
end
