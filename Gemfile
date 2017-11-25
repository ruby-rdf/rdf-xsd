source "https://rubygems.org"

gemspec

gem 'rdf',            github: "ruby-rdf/rdf",             branch: "develop"
gem 'rdf-spec',       github: "ruby-rdf/rdf-spec",        branch: "develop"
gem 'rdf-isomorphic', github: "ruby-rdf/rdf-isomorphic",  branch: "develop"
gem "nokogiri", '~> 1.8'
gem 'equivalent-xml', '~> 0.6'

group :debug do
  gem 'byebug', platforms: :mri
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
