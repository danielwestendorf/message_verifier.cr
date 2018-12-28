require "./message_verifier/*"

module MessageVerifier
  class MessageVerifierError < Exception; end

  class InvalidSignature < MessageVerifierError; end

  class InvalidCompare < MessageVerifierError; end

  class InvalidMessage < MessageVerifierError; end

  class ExpiredMessage < InvalidSignature; end

  class InvalidMessagePurpose < InvalidSignature; end
end
