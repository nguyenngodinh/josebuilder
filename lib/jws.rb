require 'base64'
require 'openssl'
require 'jose/json'

module JWS
  class DecodeError < StandardError; end
  class VerificationError < DecodeError; end
  extend JWS::Json

  module_function

  def sign(algorithm, msg, key)
    if ['HS256', 'HS384', 'HS512'].include?(algorithm)
      sign_hmac(algorithm, msg, key)
    else
      raise NotImplementedError.new("Unsupported signing mehtod")
    end
  end

  def sign_hmac(algorithm, msg, key)
    OpenSSL::HMAC.digest(OpenSSL::Digest.new(algorithm.sub('HS', 'Sha')), key, msg)
  end

  def base64url_decode(str)
    str += '=' *(4 - str.length.modulo(4))
    Base64.decode64(str.tr('-_', '+/'))
  end

  def base64url_encode(str)
    Base64.encode64(str).tr('+/', '-_').gsub(/[\n=]/, '')
  end

  def encoded_header(algorithm='HS256', header_fields={})
    header = {'typ' => 'JWS', 'alg' => algorithm}.merge(header_fields)
    base64url_encode(encode_json(header))
  end

  def encoded_payload(payload)
    base64url_encode(encode_json(payload))
  end

  def encoded_signature(signing_input, key, algorithm)
    if algorithm == 'none'
      ''
    else
      signature = sign(algorithm, signing_input, key)
      base64url_encode(signature)
    end
  end

  def encode(payload, key, algorithm='HS256', header_fields={})
    algorithm ||= 'none'
    segments = []
    segments << encoded_header(algorithm, header_fields)
    segments << encoded_payload(payload)
    segments << encoded_signature(segments.join('.'), key, algorithm)
    segments.join('.')
  end

  def raw_segments(jws, verify=true)
    segments = jws.split('.')
    required_number_of_segments = verify ? [3] :[2,3]
    raise JWS::DecodeError.new('Not enough or too many segments') unless required_number_of_segments.include? segments.length
    segments
  end

  def decode_header_and_payload(header_segment, payload_segment)
    header = decode_json(base64url_decode(header_segment))
    payload = decode_json(base64url_decode(payload_segment))
    [header, payload]
  end

  def decoded_segments(jws, verify=true)
    header_segment, payload_segment, crypto_segment = raw_segments(jws, verify)
    header, payload = decode_header_and_payload(header_segment, payload_segment)
    signature = base64url_decode(crypto_segment.to_s) if verify
    signing_input = [header_segment, payload_segment].join('.')
    [header, payload, signature, signing_input]
  end

  def decode(jws, key=nil, verify=true, options={}, &keyfinder)
    raise JWS::DecodeError.new('Nil JSON Web Signature') unless jws
    header, payload, signature, signing_input = decoded_segments(jws, verify)
    raise JWS::DecodeError.new('Not enough or too many segments') unless header && payload
    
    if verify
      algo, key = signature_algorithm_and_key(header, key, &keyfinder)
      if options[:algorithm] && algo != options[:algorithm]
        raise JWS::IncorrectAlgorithm.new('Expected a different algorithm')
      end
      verify_signature(algo, key, signing_input, signature)
    end

    return payload, header
  end

  def signature_algorithm_and_key(header, key, &keyfinder)
    if keyfinder
      key = keyfinder.call(header)
    end
    [header['alg'], key]
  end

  def verify_signature(algo, key, signing_input, signature)
    begin
      if ['HS256', 'HS384', 'HS512'].include?(algo)
        raise JWS::VerificationError.new('Signature verification failed') unless secure_compare(signature, sign_hmac(algo, signing_input, key))
      else
        raise JWS::VerificationError.new('Algorithm not supported')
      end
    rescue OpenSSL::Pkey::PkeyError
      raise JWS::VerificationError.new('Signature verification failed')
    ensure
      OpenSSL.errors.clear
    end
  end

  def secure_compare(a, b)
    return false if a.nil? || b.nil? || a.empty? || b.empty? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

end
