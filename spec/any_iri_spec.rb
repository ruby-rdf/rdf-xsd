$:.unshift "."
require 'spec_helper'
require 'rexml/document'

describe RDF::Literal do
  context "lookup" do
    {
      "xsd:anyURI"    => RDF::Literal::AnyURI
    }.each do |qname, klass|
      it "finds #{klass} for #{qname}" do
        uri = RDF::XSD[qname.split(':').last]
        expect(RDF::Literal("0", :datatype => uri).class).to eq klass
      end
    end
  end

  describe RDF::Literal::AnyURI do
    %w(
      urn:isbn:0451450523
      urn:isan:0000-0000-9E59-0000-O-0000-0000-2
      urn:issn:0167-6423
      urn:ietf:rfc:2648
      urn:mpeg:mpeg7:schema:2001
      urn:oid:2.16.840
      urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66
      urn:uci:I001+SBSi-B10000083052
      
      mailto:jhacker@example.org
      http://example.org/
      ftp://example.org/
    ).each do |value|
      it "validates #{value}" do
        expect(RDF::Literal::AnyURI.new(value)).to be_valid
      end
    end
  end
end
