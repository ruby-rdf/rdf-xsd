$:.unshift "."
require 'spec_helper'

describe RDF::Literal do
  context "lookup" do
    {
      "xsd:dateTimeStamp" => RDF::Literal::DateTimeStamp,
      "xsd:gYearMonth"    => RDF::Literal::YearMonth,
      "xsd:gYear"         => RDF::Literal::Year,
      "xsd:gMonthDay"     => RDF::Literal::MonthDay,
      "xsd:gDay"          => RDF::Literal::Day,
      "xsd:gMonth"        => RDF::Literal::Month,
    }.each do |qname, klass|
      it "finds #{klass} for #{qname}" do
        uri = RDF::XSD[qname.split(':').last]
        expect(RDF::Literal("0", :datatype => uri).class).to eq klass
      end
    end
  end
  
  context "validations" do
    describe RDF::Literal::DateTimeStamp do
      %w(
        2010-01-01T00:00:00Z
        2010-01-01T00:00:00.0000Z
        2010-01-01T00:00:00+00:00
        2010-01-01T01:00:00+01:00
        2009-12-31T23:00:00-01:00
        -2010-01-01T00:00:00Z
        2014-09-01T12:13:14Z
        2014-09-01T12:13:14-08:00
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        2010-01-01T00:00:00
        2014-09-01T12:13:14
        2010-0
        2011-01PDT
        0000-12
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end

    describe RDF::Literal::YearMonth do
      %w(
        2010-01Z
        2010-01+08:00
        2010-01-08:00
        2010-01
        20090-12Z
        9999-12
        -2010-01Z
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        010-01Z
        2010-1Z
        2010-0
        2011-01PDT
        0000-12
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end

    describe RDF::Literal::Year do
      %w(
        2010Z
        2010+08:00
        2010-08:00
        2010
        20090Z
        9999
        -2010Z
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        010
        010Z
        2011PDT
        0000
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end

    describe RDF::Literal::MonthDay do
      %w(
        12-31Z
        12-31+08:00
        12-31-08:00
        12-31
        12-31
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        200-90Z
        -12-01Z
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end

    describe RDF::Literal::Day do
      %w(
        10Z
        10+08:00
        10-08:00
        10
        31
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        -01Z
        2010-01-01Z
        2010-01Z
        01-01Z
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end

    describe RDF::Literal::Month do
      %w(
        10Z
        10+08:00
        10-08:00
        10
      ).each do |value|
        it "validates #{value}" do
          expect(described_class.new(value)).to be_valid
          expect(described_class.new(value)).not_to be_invalid
        end
      end

      %w(
        -01Z
        2010-01-01Z
        2010-01Z
        01-01Z
      ).each do |value|
        it "invalidates #{value}" do
          expect(described_class.new(value)).to be_invalid
          expect(described_class.new(value)).not_to be_valid
        end
      end
    end
  end

end
