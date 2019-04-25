require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("s3Krit", digest: OpenSSL::Algorithm::SHA256)

msg = STDIN.gets

if msg
  puts "Verified message: #{verifier.verify(msg.strip, purpose: :example, parser: :YAML)}"
end
