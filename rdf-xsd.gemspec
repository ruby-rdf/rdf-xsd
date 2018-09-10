#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = %q{rdf-xsd}
  gem.homepage              = "http://ruby-rdf.github.com/rdf-xsd"
  gem.license               = 'Unlicense'
  gem.summary               = "Extended XSD Datatypes for RDF.rb."
  gem.description           = "Adds RDF::Literal subclasses for extended XSD datatypes."

  gem.authors               = %w(Gregg Kellogg)
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w(lib)

  gem.required_ruby_version = '>= 2.2.2'
  gem.requirements          = []

  gem.add_runtime_dependency     'rdf',             '~> 3.0'

  #gem.add_development_dependency 'nokogiri' ,       '>= 1.8' # conditionally done in Gemfile
  #gem.add_development_dependency 'equivalent-xml' , '~> 0.3'
  gem.add_development_dependency 'activesupport',   '~> 5.0'
  gem.add_development_dependency 'i18n',            '~> 0.9'
  gem.add_development_dependency 'rspec',           '~> 3.7'
  gem.add_development_dependency 'rspec-its',       '~> 1.2'
  gem.add_development_dependency 'rdf-spec',        '~> 3.0'
  gem.add_development_dependency 'yard' ,           '~> 0.9.12'

  gem.post_install_message  = %(
    For best results, use nokogiri and equivalent-xml gems as well.
    These are not hard requirements to preserve pure-ruby dependencies.
  ).gsub(/^  /m, '')
end

