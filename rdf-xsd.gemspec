#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

begin
  RUBY_ENGINE
rescue NameError
  RUBY_ENGINE = "ruby"  # Not defined in Ruby 1.8.7
end

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = %q{rdf-xsd}
  gem.homepage              = "http://ruby-rdf/github.com/rdf-xsd"
  gem.license               = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary               = "Extended XSD Datatypes for RDF.rb."
  gem.description           = "Adds RDF::Literal subclasses for extended XSD datatypes."
  gem.rubyforge_project     = 'rdf-xsd'

  gem.authors               = %w(Gregg Kellogg)
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w(lib)
  gem.has_rdoc              = false

  gem.required_ruby_version = '>= 1.8.1'
  gem.requirements          = []

  gem.add_runtime_dependency      'rdf',             '>= 0.3.4'
  gem.add_runtime_dependency      'nokogiri' ,       '>= 1.5.0'  if  RUBY_ENGINE == "ruby"
  gem.add_runtime_dependency      'backports'                    if RUBY_VERSION < "1.9"

  gem.add_development_dependency 'equivalent-xml' , '>= 0.2.8'  if  RUBY_ENGINE == "ruby"
  gem.add_development_dependency 'active_support',  '>= 3.0.0'
  gem.add_development_dependency 'i18n',            '>= 0.6.0'
  gem.add_development_dependency 'rspec',           '>= 2.5.0'
  gem.add_development_dependency 'rdf-spec',        '>= 0.3.2'
  gem.add_development_dependency 'yard' ,           '>= 0.6.0'
  gem.post_install_message  = nil
end

