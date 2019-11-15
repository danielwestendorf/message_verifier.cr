require "json"

module MessageVerifier
  class Message # :nodoc:
    JSON.mapping(
      _rails: {type: Metadata, nilable: false}
    )
  end

  class Metadata # :nodoc:
    JSON.mapping(
      message: String,
      exp: {type: String, nilable: true},
      pur: {type: String, nilable: true}
    )

    def initialize(@message : String, @expires_at : String | ::Nil = nil, @purpose : String | Symbol | ::Nil = nil)
    end

    def verify(purpose)
      raise ExpiredMessage.new unless fresh?
      raise InvalidMessagePurpose.new unless match?(purpose)

      @message
    end

    def as_json
      {_rails: {:message => @message, :exp => @expires_at, :pur => @purpose}}
    end

    def self.wrap(message : String, expires_at : Time | ::Nil = nil, expires_in : Int64 | ::Nil = nil, purpose : String | Symbol | ::Nil = nil)
      if expires_at || expires_in || purpose
        new(encode(message), pick_expiry(expires_at, expires_in), purpose).as_json.to_json
      else
        message
      end
    end

    def self.verify(message : String, purpose : String | Symbol | ::Nil = nil)
      extract_metadata(message).verify(purpose)
    end

    private def self.pick_expiry(expires_at, expires_in)
      if expires_at
        Time::Format::ISO_8601_DATE_TIME.format(expires_at.to_utc)
      elsif expires_in
        Time::Format::ISO_8601_DATE_TIME.format(Time.utc.shift(seconds: expires_in, nanoseconds: 0))
      end
    end

    private def self.extract_metadata(message_string)
      message = MessageVerifier::Message.from_json(message_string)

      new(
        decode(message._rails.message),
        expires_at: message._rails.exp,
        purpose: message._rails.pur
      )
    rescue JSON::ParseException
      new(message_string)
    end

    private def self.encode(string)
      ::Base64.strict_encode(string)
    end

    private def self.decode(string)
      ::Base64.decode_string(string)
    end

    private def match?(purpose)
      @purpose.to_s == purpose.to_s
    end

    private def fresh?
      return true if @expires_at.nil?

      Time.utc < Time.parse_iso8601(@expires_at.not_nil!).to_utc
    end
  end
end
