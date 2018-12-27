require "active_support"
require "yaml"

verifier = ActiveSupport::MessageVerifier.new("s3Krit", digest: "SHA256", serializer: YAML)

payload = { message: gets.strip }
puts verifier.generate(payload, purpose: :example, expires_at: DateTime.now + 84_600)
