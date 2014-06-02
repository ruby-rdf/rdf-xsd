# coding: utf-8
$:.unshift "."
require 'spec_helper'
begin
  require 'nokogiri'
rescue LoadError
end
require 'rexml/document'

%w(Nokogiri REXML).each do |impl|
  next unless Module.constants.map(&:to_s).include?(impl)
  describe impl do
    describe "Exclusive Canonicalization" do
      {
        "no namespace" => [
          %q(foo <sup>bar</sup> baz!),
          {},
          %q(foo <sup>bar</sup> baz!)
        ],
        "default namespace" => [
          %q(foo <sup>bar</sup> baz!),
          {:namespaces => {nil => "http://www.w3.org/1999/xhtml"}},
          %q(foo <sup xmlns="http://www.w3.org/1999/xhtml">bar</sup> baz!)
        ],
        "namespace" => [
          %q(foo <dc:sup>bar</dc:sup> baz!),
          {:namespaces => {:dc => "http://purl.org/dc/terms/"}},
          %q(foo <dc:sup xmlns:dc="http://purl.org/dc/terms/">bar</dc:sup> baz!)
        ],
        "namespace and language" => [
          %q(foo <dc:sup>bar</dc:sup> baz!),
          {:namespaces => {:dc => "http://purl.org/dc/terms/"}, :language => :fr},
          %q(foo <dc:sup xmlns:dc="http://purl.org/dc/terms/" xml:lang="fr">bar</dc:sup> baz!)
        ],
        "namespace and language with existing" => [
          %q(foo <dc:sup>bar</dc:sup><dc:sub xml:lang="en">baz</dc:sub>),
          {:namespaces => {:dc => "http://purl.org/dc/terms/"}, :language => :fr},
          %q(foo <dc:sup xmlns:dc="http://purl.org/dc/terms/" xml:lang="fr">bar</dc:sup><dc:sub xmlns:dc="http://purl.org/dc/terms/" xml:lang="en">baz</dc:sub>)
        ],
        "RDFa 0198" => [
          %q(<span property="foaf:firstName">Mark</span> <span property="foaf:surname">Birbeck</span>),
          {:namespaces => {
            ""    => "http://www.w3.org/1999/xhtml",
            :foaf => "http://xmlns.com/foaf/0.1/",
            :rdf  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          }},
          %q(<span property="foaf:firstName" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/">Mark</span> <span property="foaf:surname" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">Birbeck</span>)
        ],
        "RDFa 0198 w/xmlns" => [
          %q(<span xmlns="http://www.w3.org/1999/xhtml" property="foaf:firstName">Mark</span> <span xmlns="http://www.w3.org/1999/xhtml" property="foaf:surname">Birbeck</span>),
          {:namespaces => {
            :foaf => "http://xmlns.com/foaf/0.1/",
            :rdf  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          }},
          %q(<span property="foaf:firstName" xmlns="http://www.w3.org/1999/xhtml">Mark</span> <span property="foaf:surname" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/">Birbeck</span>)
        ],
        "RDFa 0198 w/xmlns" => [
          %q(<span xmlns="http://www.w3.org/1999/xhtml" property="foaf:firstName">Mark</span> <span xmlns="http://www.w3.org/1999/xhtml" property="foaf:surname">Birbeck</span>),
          {:namespaces => {
            :foaf => "http://xmlns.com/foaf/0.1/",
            :rdf  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
          }},
          %q(<span property="foaf:firstName" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/">Mark</span> <span property="foaf:surname" xmlns="http://www.w3.org/1999/xhtml" xmlns:foaf="http://xmlns.com/foaf/0.1/">Birbeck</span>)
        ],
        "xml-canon/rdfcore " => [
          %q(<br />),
          {:namespaces => {}},
          %q(<br></br>)
        ],
        "ns from parent" => [
          %(<div xmlns:dc="http://purl.org/dc/terms/"><dc:foo></dc:foo></div>),
          {:xpath => "//dc:foo", no_jruby: true},
          %(<dc:foo xmlns:dc="http://purl.org/dc/terms/"></dc:foo>)
        ]
      }.each do |test, (input, options, result)|
        describe "#{test}: #{input}" do
          subject {
            xml = parse(input, options.merge(:library => impl.downcase.to_sym))
            RDF::Literal::XML.new(xml.c14nxl(options), :library => impl.downcase.to_sym)
          }

          it "matches expected result" do
            skip("JRuby") if options.include?(:no_jruby) && RUBY_PLATFORM == "java"
            subject.should == RDF::Literal::XML.new(result, :library => impl.downcase.to_sym)
          end
        end
      end
      
      describe "expands empty tags" do
        [
          [%(<br/>), %(<br></br>)],
          [%(<div><br/></div>), %(<div><br></br></div>)],
        ].each do |(input, result)|
          it "expands #{input} to #{result}", :pending => ("JRuby issues" if RUBY_PLATFORM == "java") do
            xml = parse(input, :library => impl.downcase.to_sym)
            RDF::Literal::XML.new(xml.c14nxl({}), :library => impl.downcase.to_sym).to_s.should == result
          end
        end
      end
    end
  end
  
  def parse(input, options)
    namespaces = ["root"]
    (options[:namespaces] || {}).each do |prefix, href|
      namespaces << (prefix.to_s.empty? ? %(xmlns="#{href}") :  %(xmlns:#{prefix}="#{href}"))
    end
    xml = "<#{namespaces.join(' ')}>#{input}</root>"

    doc = case options[:library]
    when :nokogiri
      Nokogiri::XML.parse(xml)
    when :rexml
      REXML::Document.new(xml)
    end
    
    if options[:xpath]
      case options[:library]
      when :nokogiri
        doc.at_xpath(options[:xpath], doc.collect_namespaces)
      when :rexml
        REXML::XPath.first(doc, options[:xpath])
      end
    else
      doc.root.children
    end
  end
end
