# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cas_rest_client}
  s.version = "1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Antonio Marques, Roberto Klein"]
  s.date = %q{2010-07-08}
  s.email = ["acmarques@gmail.com", "robertokl@gmail.com"]
  s.files = ["lib/cas_rest_client.rb", "lib/init.rb"]
  s.homepage = %q{http://github.com/robertokl/cas-rest-client}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Rest client for services using CAS authentication.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 1.4.2"])
    else
      s.add_dependency(%q<rest-client>, [">= 1.4.2"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 1.4.2"])
  end
end