require "openssl"

module MessageVerifier
  module Util
    extend self

    # Constant time string comparison, for fixed length strings.
    #
    # The values compared should be of fixed length, such as strings
    # that have already been processed by HMAC. Raises in case of length mismatch.
    def fixed_length_secure_compare(a, b)
      raise InvalidCompare.new("string length mismatch.") unless a.bytesize == b.bytesize

      l = a.bytes

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end

    # Constant time string comparison, for variable length strings.
    #
    # The values are first processed by SHA256, so that we don't leak length info
    # via timing attacks.
    def secure_compare(a, b)
      fixed_length_secure_compare(OpenSSL::Digest.new("SHA256").update(a).hexdigest, OpenSSL::Digest.new("SHA256").update(b).hexdigest) && a == b
    end
  end
end
