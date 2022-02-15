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
    {
      'Hash with seconds components': {
        value:  {se: 10, mi: 1},
        string: 'PT1M10S',
        object: [0, 70]
      },
      'Hash with negative seconds component': {
        value:  {si: '-', se: 10, mi: 1},
        string: '-PT1M10S',
        object: [0, -70]
      },
      'Hash with months components': {
        value:  {yr: 1, mo: 1},
        string: 'P1Y1M',
        object: [13, 0]
      },
      'Hash with negative months components': {
        value:  {si: '-', yr: 1, mo: 1},
        string: '-P1Y1M',
        object: [-13, 0]
      },
      'Hash with negative seconds component': {
        value:  {si: '-', se: 10, mi: 1},
        string: '-PT1M10S',
        object: [0, -70]
      },
      'Hash with seconds string': {
        value:  'PT1M10S',
        string: 'PT1M10S',
        object: [0, 70]
      },
      'String with negative seconds': {
        value:  '-PT1M10S',
        string: '-PT1M10S',
        object: [0, -70]
      },
      'Hash with duration': {
        value: described_class.new('PT70S'),
        string: 'PT1M10S',
        object: [0, 70]
      },
    }.each do |title, param|
      it title do
        expect(described_class.new(param[:value]).to_s).to eq param[:string]
        expect(described_class.new(param[:value]).object).to eq param[:object]
      end
    end
  end

  it "finds #{described_class} for xsd:duration" do
    expect(RDF::Literal("0", datatype: RDF::XSD.duration).class).to eq described_class
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
      [RDF::Literal::Duration.new("P1Y"), "P1Y"] => true,
      [RDF::Literal::Duration.new("P1Y"), "P12M"] => false,
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

  describe 'extraction' do
    subject {described_class.new("P2Y6M5DT12H35M30S")}
    its(:years) {is_expected.to eq 2}
    its(:months) {is_expected.to eq 6}
    its(:days) {is_expected.to eq 5}
    its(:hours) {is_expected.to eq 12}
    its(:minutes) {is_expected.to eq 35}
    its(:seconds) {is_expected.to eq 30}

    describe '#years' do
      {
        "P20Y15M" => 21,
        "-P15M" => -1,
        "-P2DT15H" => 0,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).years).to eq v}
      end
    end

    describe '#months' do
      {
        "P20Y15M" => 3,
        "-P20Y18M" => -6,
        "-P2DT15H0M0S" => 0,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).months).to eq v}
      end
    end

    describe '#days' do
      {
        "P3DT10H" => 3,
        "P3DT55H" => 5,
        "P3Y5M" => 0,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).days).to eq v}
      end
    end

    describe '#hours' do
      {
        "P3DT10H" => 10,
        "P3DT12H32M12S" => 12,
        "PT123H" => 3,
        "-P3DT10H" => -10,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).hours).to eq v}
      end
    end

    describe '#minutes' do
      {
        "P3DT10H" => 0,
        "-P5DT12H30M" => -30,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).minutes).to eq v}
      end
    end

    describe '#seconds' do
      {
        "P3DT10H12.5S" => 12.5,
        "-PT256S" => -16.0,
      }.each do |s, v|
        specify(s) {expect(described_class.new(s).seconds).to eq v}
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

  describe "#canonicalize" do
    {
      "PT1004199059S"             => "P11622DT16H10M59S",
      "PT130S"                    => "PT2M10S",
      "PT2M10S"                   => "PT2M10S",
      "P1DT2S"                    => "P1DT2S",
      "-P1Y"                      => "-P1Y",
      "P1Y2M3DT5H20M30.123S"      => "P1Y2M3DT5H20M30.123S",
      "-P1111Y11M23DT4H55M16.666S"=> "-P1111Y11M23DT4H55M16.666S",
      "P2Y6M5DT12H35M30S"         => "P2Y6M5DT12H35M30S",
      "P1DT2H"                    => "P1DT2H",
      "P20M"                      => "P1Y8M",
      "PT20M"                     => "PT20M",
      "P0Y20M0D"                  => "P1Y8M",
      "P0Y"                       => "PT0S",
      "-P60D"                     => "-P60D",
      "PT1M30.5S"                 => "PT1M30.5S",
    }.each do |s, h|
      it "produces #{h} from #{s.inspect}" do
        expect(described_class.new(s, canonicalize: true).to_s).to eq h
      end
    end
  end

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

    invalid = %w(
      PT1Y
      PT1D
      P1H
      P1S
      P1H1
    )

    include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
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

  describe "#<" do
    {
      ["P1D", "P2D"] => true,
      ["PT1H", "P1D"] => true,
      ["PT1M", "PT1H"] => true,
      ["P1D", "P1D"] => false,
      ["-P1D", "P1D"] => true,
    }.each do |(a, b), res|
      if res
        it "#{a} < #{b}" do
          expect(described_class.new(a)).to be < described_class.new(b)
        end
      else
        it "#{a} !< #{b}" do
          expect(described_class.new(a)).not_to be < described_class.new(b)
        end
      end
    end
  end

  describe "#>" do
    {
      ["P2D", "P1D"] => true,
      ["P1D", "PT1H"] => true,
      ["PT1H", "PT1M"] => true,
      ["P1D", "P1D"] => false,
      ["P1D", "-P1D"] => true,
    }.each do |(a, b), res|
      if res
        it "#{a} > #{b}" do
          expect(described_class.new(a)).to be > described_class.new(b)
        end
      else
        it "#{a} !> #{b}" do
          expect(described_class.new(a)).not_to be > described_class.new(b)
        end
      end
    end
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

  describe "#<" do
    {
      ["P1M", "P2M"] => true,
      ["P1Y", "P1M"] => false,
      ["P1Y", "P2Y"] => true,
      ["P1Y", "P1Y"] => false,
      ["-P1Y", "P1Y"] => true,
    }.each do |(a, b), res|
      if res
        it "#{a} < #{b}" do
          expect(described_class.new(a)).to be < described_class.new(b)
        end
      else
        it "#{a} !< #{b}" do
          expect(described_class.new(a)).not_to be < described_class.new(b)
        end
      end
    end
  end

  describe "#>" do
    {
      ["P2M", "P1M"] => true,
      ["P1Y", "P1M"] => true,
      ["P2Y", "P1Y"] => true,
      ["P1Y", "P1Y"] => false,
      ["P1Y", "-P1Y"] => true,
    }.each do |(a, b), res|
      if res
        it "#{a} > #{b}" do
          expect(described_class.new(a)).to be > described_class.new(b)
        end
      else
        it "#{a} !> #{b}" do
          expect(described_class.new(a)).not_to be > described_class.new(b)
        end
      end
    end
  end
end
