require "active_support"
require "json"

verifier = ActiveSupport::MessageVerifier.new("s3Krit", digest: "SHA256", serializer: JSON)

puts verifier.generate(gets.chomp, purpose: :example, expires_at: DateTime.now + 84_600)
