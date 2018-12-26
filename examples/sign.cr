require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("s3Krit", digest: :sha256, serializer: :JSON)

msg = STDIN.gets

if msg
  puts verifier.generate(msg.strip, purpose: :example, expires_at: Time.now  + 1.week)
end
