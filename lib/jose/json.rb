module JWS
  module Json
    require 'json'

    def decode_json(encoded_json)
      JSON.parse(encoded_json)
    rescue JSON::ParseError
      raise JOSE::DecodeError.new("Invalid encoding")
    end

    def encode_json(raw)
      JSON.generate(raw)
    end
  end
end
