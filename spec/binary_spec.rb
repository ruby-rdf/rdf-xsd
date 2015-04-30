$:.unshift "."
require 'spec_helper'

describe RDF::Literal do
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.hexBinary => RDF::Literal::HexBinary }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.base64Binary => RDF::Literal::Base64Binary }

  describe RDF::Literal::HexBinary do
    it_behaves_like 'RDF::Literal',
                    '0FB7',
                    described_class::DATATYPE.to_s

    valid_values = %w(
    0FB7
    0fb7
    3f3c6d78206c657673726F693D6E3122302e20226E656F636964676e223D54552d4622383E3f
    )

    invalid_values = %w(0FB7Z)

    include_examples 'RDF::Literal validation', RDF::XSD.hexBinary, valid_values, invalid_values
  end

  describe RDF::Literal::Base64Binary do
    it_behaves_like 'RDF::Literal with datatype',
                    "U2VuZCByZWluZm9yY2VtZW50cw==\n",
                    described_class::DATATYPE.to_s

    it_behaves_like 'RDF::Literal equality',
                    "U2VuZCByZWluZm9yY2VtZW50cw==\n",
                    'Send reinforcements'

    it_behaves_like 'RDF::Literal lexical values',
                    "U2VuZCByZWluZm9yY2VtZW50cw==\n"

    base64_valid = ["U2VuZCByZWluZm9yY2VtZW50cw==\n",
                    "VGhpcyBpcyBsaW5lIG9uZQpUaGlzIGlzIGxpbmUgdHdvClRoaXMgaXMgbGluZSB0aHJlZQpBbmQgc28gb24uLi4K",
                    "Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4g",
                    "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
        IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
        dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
        dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
        ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=",
                    "YW55IGNhcm5hbCBwbGVhc3VyZS4=",
                    "YW55IGNhcm5hbCBwbGVhc3VyZQ==",
                    "YW55IGNhcm5hbCBwbGVhc3Vy",
                    "YW55IGNhcm5hbCBwbGVhc3U=",
                    "YW55IGNhcm5hbCBwbGVhcw=="]

    base64_invalid = [] # why do the tests below call RDF::Literal::YearMonth?
    # they fail when running against RDF::Literal::Base64Binary

    include_examples 'RDF::Literal validation', RDF::XSD.base64Binary, base64_valid, base64_invalid

    %w(
      0FB7Z
    ).each do |value|
      it "invalidates #{value}" do
        expect(RDF::Literal::YearMonth.new(value)).to be_invalid
        expect(RDF::Literal::YearMonth.new(value)).not_to be_valid
      end
    end
  end
end
