# message_verifier.cr

[![Build Status](https://travis-ci.org/danielwestendorf/message_verifier.cr.svg?branch=master)](https://travis-ci.org/danielwestendorf/message_verifier.cr)

Ruby on Rails compatible `ActiveSupport::MessageVerifier` implementation for Crystal. Allows verified message passing back and forth between ruby and crystal-lang implementations.

*Why?* Perhaps you have a microservice written in Crystal and it needs to communicate with a ruby/rails app (or vice-versa), and the data passed between those services needs to be verified to be trustworthy?

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  message_verifier:
    github: danielwestendorf/message_verifier.cr
```

## Usage

```crystal
require "message_verifier"
```

### Verify a message

```crystal
verifier = MessageVerifier::Verifier.new("s3Krit", digest: :sha256)

msg = "eyJfcmFpbHMiOnsibWVzc2FnZSI6IklrNWxkbVZ5SUdkdmJtNWhJR2RwZG1VZ2VXOTFJSFZ3TENCdVpYWmxjaUJuYjI1dVlTQnNaWFFnZVc5MUlHUnZkMjRpIiwiZXhwIjpudWxsLCJwdXIiOiJleGFtcGxlIn19--60475ee3cec26744d26579089b060bf5494553d0ac139f6f2b71f2447455ab48"

puts "Verified message: #{verifier.verify(msg, purpose: :example)}"
```

### Generate a message
```crystal
verifier = MessageVerifier::Verifier.new("s3Krit", digest: :sha256, serializer: :JSON)

msg = { "foo" => "bar" }

puts verifier.generate(msg.to_json, purpose: :example, expires_at: Time.now  + 1.week)

```

## See it in action
Examples of passing messages back and forth between ruby and crystal implementations.

`gem install activesupport` if not installed already

```bash
$ echo "Very special message" | crystal run examples/sign.cr  | ruby examples/verify.rb
```

```bash
$ echo "Some other special message" | ruby examples/sign.rb | crystal run examples/verify.cr
```

## Progress

- [x] Message expiration dates, freshness
  - Messages which have expired will return `nil` or raise a `MessageVerifier::InvalidSignature` exception
- [x] Message purposes
- [x] Message Serializers
  - [x] JSON
  - [x] YAML
- [x] Signature Digest Algorithms
  - [x] All [OpenSSL supported](https://crystal-lang.org/api/0.27.0/OpenSSL/HMAC.html#digest%28algorithm%3ASymbol%2Ckey%2Cdata%29%3ABytes-class-method) algos
- [ ] Rotating keys

## Contributing

1. Fork it (<https://github.com/danielwestendorf/message_verifier.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [danielwestendorf](https://github.com/your-github-user) Daniel Westendorf - creator, maintainer
