require "../spec_helper"

describe MessageVerifier::KeyGenerator do
  it "generates a key of the default length" do
    secret = SecureRandom.hex(64)
    generator = MessageVerifier::KeyGenerator.new(secret, 2)

    derived_key = generator.generate_key("some_salt")
    derived_key.should be_kind(String)
    derived_key.length.should eq(64)
  end

  it "generates a key with a non-default length" do
    secret = SecureRandom.hex(64)
    generator = MessageVerifier::KeyGenerator.new(secret, 2)

    derived_key = generator.generate_key("some_salt", 32)
    derived_key.should be_kind(String)
    derived_key.length.should eq(32)
  end

  it "generates the expected results" do
    expected = "b129376f68f1ecae788d7433310249d65ceec090ecacd4c872a3a9e9ec78e055739be5cc6956345d5ae38e7e1daa66f1de587dc8da2bf9e8b965af4b3918a122"
    MessageVerifier::KeyGenerator.new("0" * 64).generate_key("some_salt").unpack1("H*").should eq(expected)

    expected = "b129376f68f1ecae788d7433310249d65ceec090ecacd4c872a3a9e9ec78e055"
    MessageVerifier::KeyGenerator.new("0" * 64).generate_key("some_salt", 32).unpack1("H*").should eq(expected)

    expected = "cbea7f7f47df705967dc508f4e446fd99e7797b1d70011c6899cd39bbe62907b8508337d678505a7dc8184e037f1003ba3d19fc5d829454668e91d2518692eae"
    MessageVerifier::KeyGenerator.new("0" * 64, iterations: 2).generate_key("some_salt").unpack1("H*").should eq(expected)
  end
end
