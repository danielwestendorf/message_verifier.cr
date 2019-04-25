require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("s3Krit", digest: OpenSSL::Algorithm::SHA256)

msg = STDIN.gets

if msg
  payload = {"message" => msg.strip}
  puts verifier.generate(payload.to_yaml, purpose: :example, expires_at: Time.now + 1.week)
end
