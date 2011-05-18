# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{soap4r}
  s.version = "1.5.8"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = [%q{NAKAMURA, Hiroshi}]
  s.cert_chain = nil
  s.date = %q{2007-09-23}
  s.email = %q{nahi@ruby-lang.org}
  s.executables = [%q{wsdl2ruby.rb}, %q{xsd2ruby.rb}]
  s.files = [%q{bin/wsdl2ruby.rb}, %q{bin/xsd2ruby.rb}]
  s.homepage = %q{http://dev.ctor.org/soap4r}
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.8.2}
  s.summary = %q{An implementation of SOAP 1.1 for Ruby.}

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 2.1.1"])
    else
      s.add_dependency(%q<httpclient>, [">= 2.1.1"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 2.1.1"])
  end
end
