require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("s3Krit", digest: :sha256)

msg = STDIN.gets

if msg
  msg_hash = { what_you_said: msg.strip }
  puts verifier.generate(msg_hash.to_json, purpose: :example)
end
