require "../src/message_verifier"

verifier = MessageVerifier::Verifier.new("27f17513b83b7f1e14d2e9dfcb871111b5a8201919dcdf6ca97d3b929bb2d9108375adfe6bd4808797ab069a4b1aa2618449492c4a481d6cbe91ec763560088d", digest: OpenSSL::Algorithm::SHA256)

msg = STDIN.gets

if msg
  puts "Verified message: #{verifier.verify(msg.strip, purpose: :example, parser: :JSON)}"
end
