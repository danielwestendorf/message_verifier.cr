require "active_support"
require "yaml"

verifier = ActiveSupport::MessageVerifier.new("s3Krit", digest: "SHA256", serializer: YAML)

msg = STDIN.read.strip

puts "Verified message: #{verifier.verify(msg, purpose: :example)}"
