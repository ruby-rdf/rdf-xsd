#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = %q{rdf-xsd}
  gem.homepage              = "http://github.com/gkellogg/rdf-xsd"
  gem.license               = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary               = "Extended XSD Datatypes for RDF.rb."
  gem.description           = "Adds RDF::Literal subclasses for extended XSD datatypes."
  gem.rubyforge_project     = 'rdf-xsd'

  gem.authors               = %w(Gregg Kellogg)
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.markdown UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w(lib)
  gem.has_rdoc              = false

  gem.required_ruby_version = '>= 1.8.1'
  gem.requirements          = []

  gem.add_dependency             'rdf',             '>= 0.3.4'
  gem.add_development_dependency 'rspec',           '>= 2.5.0'
  gem.add_development_dependency 'rdf-spec',        '>= 0.3.2'
  gem.add_development_dependency 'yard' ,           '>= 0.6.0'
  gem.post_install_message  = nil
end

