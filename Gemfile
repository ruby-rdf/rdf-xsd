source "https://rubygems.org"

gemspec

gem 'rdf',            github: "ruby-rdf/rdf",             branch: "develop"
gem 'rdf-spec',       github: "ruby-rdf/rdf-spec",        branch: "develop"
gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
gem "nokogiri",       '~> 1.15', '>= 1.15.4'
gem 'equivalent-xml', '~> 0.6'

group :debug do
  gem 'byebug', platforms: :mri
end

group :test do
  gem 'simplecov', '~> 0.22',  platforms: :mri
  gem 'simplecov-lcov', '~> 0.8',  platforms: :mri
end
