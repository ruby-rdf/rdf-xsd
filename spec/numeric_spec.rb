$:.unshift "."
require 'spec_helper'

describe RDF::Literal::Numeric do
  context "lookup" do
    {
      "xsd:nonPositiveInteger" => RDF::Literal::NonPositiveInteger,
      "xsd:negativeInteger"    => RDF::Literal::NegativeInteger,
      "xsd:nonNegativeInteger" => RDF::Literal::NonNegativeInteger,
      "xsd:positiveInteger"    => RDF::Literal::PositiveInteger,
      "xsd:long"               => RDF::Literal::Long,
      "xsd:int"                => RDF::Literal::Int,
      "xsd:short"              => RDF::Literal::Short,
      "xsd:byte"               => RDF::Literal::Byte,
      "xsd:unsignedLong"       => RDF::Literal::UnsignedLong,
      "xsd:unsignedInt"        => RDF::Literal::UnsignedInt,
      "xsd:unsignedShort"      => RDF::Literal::UnsignedShort,
      "xsd:unsignedByte"       => RDF::Literal::UnsignedByte,
    }.each do |qname, klass|
      it "finds #{klass} for #{qname}" do
        uri = RDF::XSD[qname.split(':').last]
        expect(RDF::Literal("0", :datatype => uri).class).to eq klass
      end
    end
  end
  
  context "type-promotion" do
    context "for numbers" do
      {
        :integer => {
          :integer            => :integer,
          :nonPositiveInteger => :integer,
          :negativeInteger    => :integer,
          :long               => :integer,
          :int                => :integer,
          :short              => :integer,
          :byte               => :integer,
          :nonNegativeInteger => :integer,
          :unsignedLong       => :integer,
          :unsignedInt        => :integer,
          :unsignedShort      => :integer,
          :unsignedByte       => :integer,
          :positiveInteger    => :integer,
          :decimal            => :decimal,
          :float              => :float,
          :double             => :double,
        },
        :decimal => {
          :integer            => :decimal,
          :nonPositiveInteger => :decimal,
          :negativeInteger    => :decimal,
          :long               => :decimal,
          :int                => :decimal,
          :short              => :decimal,
          :byte               => :decimal,
          :nonNegativeInteger => :decimal,
          :unsignedLong       => :decimal,
          :unsignedInt        => :decimal,
          :unsignedShort      => :decimal,
          :unsignedByte       => :decimal,
          :positiveInteger    => :decimal,
          :decimal            => :decimal,
          :float              => :float,
          :double             => :double,
        },
        :float => {
          :integer            => :float,
          :nonPositiveInteger => :float,
          :negativeInteger    => :float,
          :long               => :float,
          :int                => :float,
          :short              => :float,
          :byte               => :float,
          :nonNegativeInteger => :float,
          :unsignedLong       => :float,
          :unsignedInt        => :float,
          :unsignedShort      => :float,
          :unsignedByte       => :float,
          :positiveInteger    => :float,
          :decimal            => :float,
          :float              => :float,
          :double             => :double,
        },
        :double => {
          :integer            => :double,
          :nonPositiveInteger => :double,
          :negativeInteger    => :double,
          :long               => :double,
          :int                => :double,
          :short              => :double,
          :byte               => :double,
          :nonNegativeInteger => :double,
          :unsignedLong       => :double,
          :unsignedInt        => :double,
          :unsignedShort      => :double,
          :unsignedByte       => :double,
          :positiveInteger    => :double,
          :decimal            => :double,
          :float              => :double,
          :double             => :double,
        },
      }.each do |left, right_result|
        if left == :integer
          # Type promotion is equivalent for sub-types of xsd:integer
          (right_result.keys - [:integer, :decimal, :float, :double]).each do |l|
            o_l = RDF::Literal.new(([:nonPositiveInteger, :negativeInteger].include?(l) ? "-1" : "1"), :datatype => RDF::XSD.send(l))
            right_result.each do |right, result|
              o_r = RDF::Literal.new(([:nonPositiveInteger, :negativeInteger].include?(right) ? "-1" : "1"), :datatype => RDF::XSD.send(right))
              
              it "returns #{result} for #{l} + #{right}" do
                expect((o_l + o_r).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{l} - #{right}" do
                expect((o_l - o_r).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{l} * #{right}" do
                expect((o_l * o_r).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{l} / #{right}" do
                expect((o_l / o_r).datatype).to eq RDF::XSD.send(result)
              end

              it "returns #{result} for #{right} + #{l}" do
                expect((o_r + o_l).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{right} - #{l}" do
                expect((o_r - o_l).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{right} * #{l}" do
                expect((o_r * o_l).datatype).to eq RDF::XSD.send(result)
              end
              it "returns #{result} for #{right} / #{l}" do
                expect((o_r / o_l).datatype).to eq RDF::XSD.send(result)
              end
            end
          end
        end

        o_l = RDF::Literal.new("1", :datatype => RDF::XSD.send(left))
        right_result.each do |right, result|
          o_r = RDF::Literal.new(([:nonPositiveInteger, :negativeInteger].include?(right) ? "-1" : "1"), :datatype => RDF::XSD.send(right))
          
          it "returns #{result} for #{left} + #{right}" do
            expect((o_l + o_r).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{left} - #{right}" do
             expect((o_l - o_r).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{left} * #{right}" do
            expect((o_l * o_r).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{left} / #{right}" do
            expect((o_l / o_r).datatype).to eq RDF::XSD.send(result)
          end

          it "returns #{result} for #{right} + #{left}" do
            expect((o_r + o_l).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{right} - #{left}" do
            expect((o_r - o_l).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{right} * #{left}" do
            expect((o_r * o_l).datatype).to eq RDF::XSD.send(result)
          end
          it "returns #{result} for #{right} / #{left}" do
            expect((o_r / o_l).datatype).to eq RDF::XSD.send(result)
          end
        end
      end
    end
  end

  context "validations" do
    [
      RDF::Literal::NonPositiveInteger,
      RDF::Literal::NegativeInteger,
      RDF::Literal::NonNegativeInteger,
      RDF::Literal::PositiveInteger,
      RDF::Literal::Long,
      RDF::Literal::Int,
      RDF::Literal::Short,
      RDF::Literal::Byte,
      RDF::Literal::UnsignedLong,
      RDF::Literal::UnsignedInt,
      RDF::Literal::UnsignedShort,
      RDF::Literal::UnsignedByte,
    ].each do |klass|
      describe klass do
        datatype = klass.const_get(:DATATYPE)

        {
          "0" => %w(nonPositiveInteger nonNegativeInteger long int short byte unsignedLong unsignedInt unsignedShort unsignedByte),
          "-1" => %w(nonPositiveInteger negativeInteger long int short byte),
          "1" => %w(nonNegativeInteger positiveInteger long int short byte unsignedLong unsignedInt unsignedShort unsignedByte),
          "9223372036854775807" => %w(nonNegativeInteger positiveInteger long unsignedLong),
          "-9223372036854775808" => %w(nonPositiveInteger negativeInteger long),
          "2147483647" => %w(nonNegativeInteger positiveInteger long int unsignedLong unsignedInt),
          "-2147483648" => %w(nonPositiveInteger negativeInteger long int),
          "32767" => %w(nonNegativeInteger positiveInteger long unsignedLong int unsignedInt short unsignedShort),
          "-32768" => %w(nonPositiveInteger negativeInteger long int short),
          "127" => %w(nonNegativeInteger positiveInteger long unsignedLong int unsignedInt short byte unsignedShort unsignedByte),
          "-128" => %w(nonPositiveInteger negativeInteger long int short byte),
        }.each do |value, datatypes|
          if datatypes.map {|s| RDF::XSD[s]}.include?(datatype)
            it "returns valid for #{value}" do
              l = klass.new(value)
              expect(l).to be_valid
              expect(l).not_to be_invalid
            end
          else
            it "returns invalid for #{value}" do
              l = klass.new(value)
              expect(l).to be_invalid
              expect(l).not_to be_valid
            end
          end
        end
      end
    end
  end

  describe "SPARQL tests" do
    context "#==" do
      {
        "numeric 1='1'^xsd:int" => [RDF::Literal(1), RDF::Literal::Int.new("1")],
        "numeric 1='1'^xsd:int" => [RDF::Literal(1), RDF::Literal::Int.new("1")],
      }.each do |label, (left, right)|
        it "returns true for #{label}" do
          left.extend(RDF::TypeCheck)
          right.extend(RDF::TypeCheck)
          expect(left).to eq right
        end
      end
    end
    
    # Term equivalence
    context "not #eql?" do
      {
        "numeric '1'^xsd:int=1" => [RDF::Literal::Int.new("1"), RDF::Literal(1)],
        "numeric 1='1'^xsd:int" => [RDF::Literal(1), RDF::Literal::Int.new("1")],
      }.each do |label, (left, right)|
        it "returns false for #{label}" do
          expect(left).not_to eql right
        end
      end
    end
  end
end
