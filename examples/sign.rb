require "active_support"
require "json"

verifier = ActiveSupport::MessageVerifier.new("s3Krit", digest: "SHA256", serializer: JSON)

msg = { what_you_said: gets.chomp }

puts verifier.generate(msg, purpose: :example)
