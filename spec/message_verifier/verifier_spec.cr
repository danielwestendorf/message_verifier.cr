require "../spec_helper"

describe MessageVerifier::Verifier do
  describe "#valid_message?" do
    it "is false with a blank message" do
      MessageVerifier::Verifier.new("a").valid_message?("").should eq(false)
    end

    it "is false with a message with invalid encoding" do
      MessageVerifier::Verifier.new("a").valid_message?(String.new(Bytes[255, 0])).should eq(false)
    end

    it "is false when there isn't data" do
      MessageVerifier::Verifier.new("a").valid_message?("--blah").should eq(false)
    end

    it "is false when there isn't a digest" do
      MessageVerifier::Verifier.new("a").valid_message?("blah--").should eq(false)
    end

    it "is false with the digest doesn't match the generated digest" do
      MessageVerifier::Verifier.new("a").valid_message?("blah--zba").should eq(false)
    end

    it "is true with the digest matches the generated digest" do
      secret = "supersecret123456"
      data = Base64.strict_encode("superdupersecret")

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).valid_message?("#{data}--#{digest}").should eq(true)
    end
  end

  describe "#verified" do
    it "requires a valid message" do
      MessageVerifier::Verifier.new("a").verified("").should be_nil
    end

    it "returns nil when the purpose doesn't match" do
      secret = "supersecret123456"
      message = {"message" => "Boom"}
      data = Base64.strict_encode(
        {"_rails" => {"message" => Base64.strict_encode(message.to_json), "exp" => nil, "pur" => "login"}}.to_json
      )

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).verified("#{data}--#{digest}", purpose: "other", parser: :JSON).should be_nil
    end

    it "returns message when the purpose matches" do
      secret = "supersecret123456"
      message = {"message" => "Boom"}
      data = Base64.strict_encode(
        {"_rails" => {"message" => Base64.strict_encode(message.to_json), "exp" => nil, "pur" => "login"}}.to_json
      )

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).verified("#{data}--#{digest}", "login", parser: :JSON).should eq(message)
    end

    it "returns encoded message" do
      secret = "supersecret123456"
      data = Base64.strict_encode(%("superdupersecret"))

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).verified("#{data}--#{digest}").should eq("superdupersecret")
    end

    describe "loads the message with the parser" do
      it "YAML" do
        secret = "supersecret123456"
        msg = {"foo" => "bar"}
        data = Base64.strict_encode(msg.to_yaml)

        digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

        MessageVerifier::Verifier.new(secret).verified("#{data}--#{digest}", parser: :YAML).should be_a(YAML::Any)
      end

      it "JSON" do
        secret = "supersecret123456"
        msg = {"foo" => "bar"}
        data = Base64.strict_encode(msg.to_json)

        digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

        MessageVerifier::Verifier.new(secret).verified("#{data}--#{digest}", parser: :JSON).should be_a(JSON::Any)
      end
    end
  end

  describe "#verified!" do
    it "requires a valid message" do
      MessageVerifier::Verifier.new("a").verified!("").should be_nil
    end

    it "raises error when the purpose doesn't match" do
      secret = "supersecret123456"
      message = {"message" => "Boom"}
      data = Base64.strict_encode(
        {"_rails" => {"message" => Base64.strict_encode(message.to_json), "exp" => nil, "pur" => "login"}}.to_json
      )

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      expect_raises(MessageVerifier::InvalidMessagePurpose) do
        MessageVerifier::Verifier.new(secret).verified!("#{data}--#{digest}", purpose: "other", parser: :JSON)
      end
    end

    it "raises error when the message has expired" do
      secret = "supersecret123456"
      message = {"message" => "Boom"}
      data = Base64.strict_encode(
        {"_rails" => {"message" => Base64.strict_encode(message.to_json), "exp" => (Time.utc - 100.days), "pur" => "login"}}.to_json
      )

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      expect_raises(MessageVerifier::ExpiredMessage) do
        MessageVerifier::Verifier.new(secret).verified!("#{data}--#{digest}", purpose: "other", parser: :JSON)
      end
    end

    it "returns message when the purpose matches" do
      secret = "supersecret123456"
      message = {"message" => "Boom"}
      data = Base64.strict_encode(
        {"_rails" => {"message" => Base64.strict_encode(message.to_json), "exp" => nil, "pur" => "login"}}.to_json
      )

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).verified!("#{data}--#{digest}", "login", parser: :JSON).should eq(message)
    end
  end

  describe "#verify" do
    it "decodes the message" do
      secret = "supersecret123456"
      data = Base64.strict_encode(%("superdupersecret"))

      digest = OpenSSL::HMAC.hexdigest(:sha256, secret, data)

      MessageVerifier::Verifier.new(secret, digest: :sha256).verify("#{data}--#{digest}").should eq("superdupersecret")
    end

    it "raises an error with an invalid message" do
      expect_raises(MessageVerifier::InvalidSignature) do
        MessageVerifier::Verifier.new("a").verify("")
      end
    end
  end

  describe "#generate" do
    it "wraps the message" do
      secret = "supersecret123456"
      data = Base64.strict_encode(%({"_rails":{"message":"Qm9vbQ==","exp":null,"pur":"login"}}))

      digest = OpenSSL::HMAC.hexdigest(OpenSSL::Algorithm::SHA1, secret, data)

      MessageVerifier::Verifier.new(secret).generate("Boom", purpose: "login").should eq("#{data}--#{digest}")
    end
  end
end
