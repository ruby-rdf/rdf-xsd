$:.unshift "."
require 'spec_helper'

describe RDF::Literal do
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.hexBinary => RDF::Literal::HexBinary }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.base64Binary => RDF::Literal::Base64Binary }

  describe RDF::Literal::HexBinary do
    it_behaves_like 'RDF::Literal with datatype and grammar',
                    '3f3c6d78206c657673726F693D6E3122302e20226E656F636964676e223D54552d4622383E3f',
                    described_class::DATATYPE.to_s
    it_behaves_like 'RDF::Literal equality',
                    '3f3c6d78206c657673726F693D6E3122302e20226E656F636964676e223D54552d4622383E3f',
                    %(?<mx levsroi=n1"0. "neocidgn"=TU-F"8>?)
    it_behaves_like 'RDF::Literal lexical values',
                    '3f3c6d78206c657673726F693D6E3122302e20226E656F636964676e223D54552d4622383E3f'

    valid_values = %w(
    0FB7
    0fb7
    3f3c6d78206c657673726F693D6E3122302e20226E656F636964676e223D54552d4622383E3f
    )

    invalid_values = %w(0FB7Z)

    include_examples 'RDF::Literal validation', RDF::XSD.hexBinary, valid_values, invalid_values

    context "from binary" do
      it %(encodes ?<mx levsroi=n1"0. "neocidgn"=TU-F"8>?) do
        expect(described_class.new(nil, object: %(?<mx levsroi=n1"0. "neocidgn"=TU-F"8>?)).value).to eql "3F3C6D78206C657673726F693D6E3122302E20226E656F636964676E223D54552D4622383E3F"
      end
    end

    context "canonicalization" do
      valid_values.each do |value|
        it "#{value} to #{value.upcase}" do
          expect(described_class.new(value, canonicalize: true).value).to eq value.upcase
        end
      end
    end
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

    base64_invalid = %w(jruby rbx).include?(RUBY_ENGINE) ? [] : %w(0FB7Z)

    include_examples 'RDF::Literal validation', RDF::XSD.base64Binary, base64_valid, base64_invalid
  end
end
