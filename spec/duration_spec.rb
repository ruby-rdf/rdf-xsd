$:.unshift "."
require 'spec_helper'

describe RDF::Literal::Duration do
  include_examples 'RDF::Literal with datatype and grammar', "P2Y6M5DT12H35M30S",
                   described_class::DATATYPE.to_s
  include_examples 'RDF::Literal with datatype and grammar', "P2Y6M5DT12H35M30S",
                   described_class::DATATYPE.to_s
  include_examples 'RDF::Literal lexical values', "P2Y6M5DT12H35M30S"

  include_examples 'RDF::Literal lookup',
                   { described_class::DATATYPE => described_class }

  describe "initialize" do
    it "creates given a Hash" do
      expect(described_class.new({se: 10, mi: 1})).to eq described_class.new('PT70S')
    end
  end

  it "finds #{described_class} for xsd:duration" do
    expect(RDF::Literal("0", datatype: RDF::XSD.duration).class).to eq described_class
  end

  describe "#to_f" do
    {
      "PT130S"                    => 130,
      "PT130M"                    => 7800.0,
      "PT130H"                    => 130*3600,
      "P130D"                     => 130*24*3600,
      "P130M"                     => 341884800.0,
      "P130Y"                     => 4102444800.0,
      "PT2M10S"                   => (2*60+10),
      "P1DT2S"                    => (1*3600*24+2),
      "P1DT2H"                    => 26*3600,
      "P0Y20M0D"                  => 52617600.0,
      "P0Y"                       => 0,
      "-P60D"                     => -5184000.0,
      "PT1M30.5S"                 => 60+30.5,
      "P20M"                      => 52617600.0,
      "PT20M"                     => 20*60,
      "-P1Y"                      => (-365*3600*24),
      "PT1004199059S"             => 1004199059,
      "P1Y2M3DT5H20M30.123S"      => ((365+60+3)*3600*24+5*3600+20*60+30.123),
      "-P1111Y11M23DT4H55M16.666S"=> -35086590283.334,
      "P2Y6M5DT12H35M30S"         => 79274130.0,
    }.each do |s, f|
      it "parses #{s}" do
        expect(described_class.new(s).to_f).to eq f
      end
    end
  end

  describe "#==" do
    {
      [RDF::Literal::Duration.new("P1Y"), RDF::Literal::Duration.new("P12M")] => true,
      [RDF::Literal::Duration.new("PT24H"), RDF::Literal::Duration.new("P1D")] => true,
      [RDF::Literal::Duration.new("P1Y"), RDF::Literal::Duration.new("P365D")] => false,
      [RDF::Literal::YearMonthDuration.new("P0Y"), RDF::Literal::DayTimeDuration.new("P0D")] => true,
      [RDF::Literal::YearMonthDuration.new("P1Y"), RDF::Literal::DayTimeDuration.new("P365D")] => false,
      [RDF::Literal::YearMonthDuration.new("P2Y"), RDF::Literal::YearMonthDuration.new("P24M")] => true,
      [RDF::Literal::DayTimeDuration.new("P10D"), RDF::Literal::DayTimeDuration.new("PT240H")] => true,
      [RDF::Literal::Duration.new("P2Y0M0DT0H0M0S"), RDF::Literal::YearMonthDuration.new("P24M")] => true,
      [RDF::Literal::Duration.new("P0Y0M10D"), RDF::Literal::DayTimeDuration.new("PT240H")] => true,
    }.each do |(a, b), res|
      if res
        it "#{a} == #{b}" do
          expect(a).to eq b
        end
      else
        it "#{a} != #{b}" do
          expect(a).not_to eq b
        end
      end
    end
  end

  describe "#humanize" do
    {
      "PT1004199059S"             => "1004199059 seconds",
      "PT130S"                    => "130 seconds",
      "PT2M10S"                   => "2 minutes and 10 seconds",
      "P1DT2S"                    => "1 day and 2 seconds",
      "-P1Y"                      => "1 year ago",
      "P1Y2M3DT5H20M30.123S"      => "1 year 2 months 3 days 5 hours 20 minutes and 30.123 seconds",
      "-P1111Y11M23DT4H55M16.666S"=> "1111 years 11 months 23 days 4 hours 55 minutes and 16.666 seconds ago",
      "P2Y6M5DT12H35M30S"         => "2 years 6 months 5 days 12 hours 35 minutes and 30 seconds",
      "P1DT2H"                    => "1 day and 2 hours",
      "P20M"                      => "20 months",
      "PT20M"                     => "20 minutes",
      "P0Y20M0D"                  => "0 years 20 months and 0 days",
      "P0Y"                       => "0 years",
      "-P60D"                     => "60 days ago",
      "PT1M30.5S"                 => "1 minute and 30.5 seconds",
    }.each do |s, h|
      it "produces #{h} from #{s.inspect}" do
        expect(described_class.new(s).humanize).to eq h
      end
    end
  end
end

describe RDF::Literal::DayTimeDuration do
  include_examples 'RDF::Literal with datatype and grammar', "PT130S",
                   described_class::DATATYPE.to_s
  include_examples 'RDF::Literal lexical values', "PT130S"

  include_examples 'RDF::Literal lookup',
                   { described_class::DATATYPE => described_class }

  context "validations" do
    valid = %w(
      PT130S
      PT130M
      PT130H
      P130D
      PT2M10S
      P1DT2S
      P1DT2H
      -P60D
      PT1004199059S
      PT1M30.5S
      PT20M
    )

    invalid = %w(
      P130M
      P130Y
      P0Y20M0D
      P0Y
      P20M
      -P1Y
      P1Y2M3DT5H20M30.123S
      -P1111Y11M23DT4H55M16.666S
      P2Y6M5DT12H35M30S
    )

    include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
  end
end

describe RDF::Literal::YearMonthDuration do
  include_examples 'RDF::Literal with datatype and grammar', "P130M",
                   described_class::DATATYPE.to_s
  include_examples 'RDF::Literal lexical values', "P130M"

  include_examples 'RDF::Literal lookup',
                   { described_class::DATATYPE => described_class }

  context "validations" do
    valid = %w(
      P130M
      P130Y
      P0Y
      P20M
      -P1Y
    )

    invalid = %w(
      P0Y20M0D
      P1Y2M3DT5H20M30.123S
      -P1111Y11M23DT4H55M16.666S
      P2Y6M5DT12H35M30S
      PT130S
      PT130M
      PT130H
      P130D
      PT2M10S
      P1DT2S
      P1DT2H
      -P60D
      PT1004199059S
      PT1M30.5S
      PT20M
    )

    include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
  end
end
