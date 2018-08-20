require "../spec_helper"

describe MessageVerifier::Util do
  describe "#secure_compare" do
    it "should perform string comparison" do
      MessageVerifier::Util.secure_compare("a", "a").should eq(true)
      MessageVerifier::Util.secure_compare("a", "b").should eq(false)
    end
  end

  describe "#fixed_length_secure_compare" do
    it "should perform string comparison" do
      MessageVerifier::Util.fixed_length_secure_compare("a", "a").should eq(true)
      MessageVerifier::Util.fixed_length_secure_compare("a", "b").should eq(false)
    end

    it "raises an error on length mismatch" do
      expect_raises(MessageVerifier::InvalidCompare) do
        MessageVerifier::Util.fixed_length_secure_compare("a", "ab")
      end
    end
  end
end
