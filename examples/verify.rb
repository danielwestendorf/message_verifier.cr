require "active_support"
require "json"

verifier = ActiveSupport::MessageVerifier.new("s3Krit", digest: "SHA256", serializer: JSON)

msg = STDIN.read.strip

puts "Verified message: #{verifier.verify(msg, purpose: :example)}"
