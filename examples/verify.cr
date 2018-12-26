require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("s3Krit", digest: :sha256)

msg = STDIN.gets

if msg
  puts "Verified message: #{verifier.verify(msg.strip, purpose: :example)}"
end
