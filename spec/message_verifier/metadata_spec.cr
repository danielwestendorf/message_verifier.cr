require "../spec_helper"

describe MessageVerifier::Metadata do
  describe "#as_json" do
    it "returns a hash of data" do
      metadata = MessageVerifier::Metadata.new("thing", "2018-08-13T21:31:01+00:00", :login)

      metadata.as_json[:_rails][:message].should be_a(String)
      metadata.as_json[:_rails][:exp].should be_a(String)
      metadata.as_json[:_rails][:pur].should be_a(Symbol)
    end
  end

  describe "#verify" do
    it "returns message if purpose matches and fresh" do
      metadata = MessageVerifier::Metadata.new("thing", "2018-08-13T21:31:01+00:00", :login)

      metadata.as_json[:_rails][:message].should be_a(String)
      metadata.as_json[:_rails][:exp].should be_a(String)
      metadata.as_json[:_rails][:pur].should be_a(Symbol)
    end
  end

  describe ".verify" do
    it "matches the purpose" do
      message = %({ "_rails": { "message": "Qm9vbQ==", "exp": null, "pur": "login" } })

      MessageVerifier::Metadata.verify(message, :login).should_not be_nil
    end

    it "doesnt match the purpose" do
      message = %({ "_rails": { "message": "Qm9vbQ==", "exp": null, "pur": "login" } })

      MessageVerifier::Metadata.verify(message, :other).should be_nil
    end

    it "is fresh" do
      message = %({ "_rails": { "message": "Qm9vbQ==", "exp": #{Time.utc_now.at_end_of_month.to_json}, "pur": null } })

      MessageVerifier::Metadata.verify(message).should_not be_nil
    end

    it "is stale" do
      message = %({ "_rails": { "message": "Qm9vbQ==", "exp": #{Time.utc_now.at_beginning_of_month.to_json}, "pur": null } })

      MessageVerifier::Metadata.verify(message).should be_nil
    end

    it "handles the message being passed directly instead of json" do
      MessageVerifier::Metadata.verify("Boom").should_not be_nil
    end
  end

  describe ".wrap" do
    it "returns just the message if the other values are nil" do
      message = "foo"

      MessageVerifier::Metadata.wrap(message).should eq(message)
    end

    it "picks expires_at" do
      message = "Boom"
      time = Time.utc_now.at_end_of_month
      result = %({"_rails":{"message":"Qm9vbQ==","exp":"#{Time::Format::ISO_8601_DATE_TIME.format(time)}","pur":null}})

      MessageVerifier::Metadata.wrap(message, expires_at: time).should eq(result)
    end

    it "picks expires_in" do
      message = "Boom"
      time = Time.utc_now.add_span(seconds: 60, nanoseconds: 0)
      result = %({"_rails":{"message":"Qm9vbQ==","exp":"#{Time::Format::ISO_8601_DATE_TIME.format(time).split(".").first})

      MessageVerifier::Metadata.wrap(message, expires_in: 60).should start_with(result)
    end

    it "sets the purpose" do
      message = "Boom"
      result = %({"_rails":{"message":"Qm9vbQ==","exp":null,"pur":"login"}})

      MessageVerifier::Metadata.wrap(message, purpose: :login).should eq(result)
    end
  end
end
