#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = %q{rdf-xsd}
  gem.homepage              = "https://github.com/ruby-rdf/rdf-xsd"
  gem.license               = 'Unlicense'
  gem.summary               = "Extended XSD Datatypes for RDF.rb."
  gem.description           = "Adds RDF::Literal subclasses for extended XSD datatypes."
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/rdf-xsd",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/rdf-xsd/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/rdf-xsd",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/rdf-xsd",
  }

  gem.authors               = %w(Gregg Kellogg)
  gem.email                 = 'public-rdf-ruby@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w(lib)

  gem.required_ruby_version = '>= 2.6'
  gem.requirements          = []

  gem.add_runtime_dependency     'rdf',             '~> 3.2'
  gem.add_runtime_dependency     'rexml',           '~> 3.2'

  #gem.add_development_dependency 'nokogiri' ,       '>= 1.10' # conditionally done in Gemfile
  #gem.add_development_dependency 'equivalent-xml' , '~> 0.6'
  gem.add_development_dependency 'activesupport',   '~> 6.1'
  gem.add_development_dependency 'rspec',           '~> 3.10'
  gem.add_development_dependency 'rspec-its',       '~> 1.3'
  gem.add_development_dependency 'rdf-spec',        '~> 3.2'
  gem.add_development_dependency 'yard' ,           '~> 0.9'

  gem.post_install_message  = %(
    For best results, use nokogiri and equivalent-xml gems as well.
    These are not hard requirements to preserve pure-ruby dependencies.
  ).gsub(/^  /m, '')
end

