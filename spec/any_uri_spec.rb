require_relative 'spec_helper'
require 'rexml/document'

describe RDF::Literal do
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.anyURI => RDF::Literal::AnyURI }

  describe RDF::Literal::AnyURI do
    it_behaves_like 'RDF::Literal with datatype',
                    'urn:oid:2.16.840',
                    described_class::DATATYPE.to_s

    it_behaves_like 'RDF::Literal equality', 'urn:oid:2.16.840'

    it_behaves_like 'RDF::Literal lexical values', 'urn:oid:2.16.840'

    valid = %w(
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
    )

    include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, []
  end
end
