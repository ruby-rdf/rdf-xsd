$:.unshift "."
require 'spec_helper'

describe RDF::Literal do

  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.dateTimeStamp => RDF::Literal::DateTimeStamp }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.gYearMonth => RDF::Literal::YearMonth }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.gYear => RDF::Literal::Year }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.gMonthDay => RDF::Literal::MonthDay }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.gDay => RDF::Literal::Day }
  include_examples 'RDF::Literal lookup',
                   { RDF::XSD.gMonth => RDF::Literal::Month }

  context "validations" do
    describe RDF::Literal::DateTimeStamp do
      include_examples 'RDF::Literal with datatype and grammar',
                       '2010-01-01T00:00:00Z',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality',
                       '2010-01-01T00:00:00Z',
                       Date.parse('2010-01-01')

      include_examples 'RDF::Literal lexical values', '2010-01-01T00:00:00Z'

      valid = %w(
        2010-01-01T00:00:00Z
        2010-01-01T00:00:00.0000Z
        2010-01-01T00:00:00+00:00
        2010-01-01T01:00:00+01:00
        2009-12-31T23:00:00-01:00
        -2010-01-01T00:00:00Z
        2014-09-01T12:13:14Z
        2014-09-01T12:13:14-08:00
      )

      invalid = %w(
        2010-01-01T00:00:00
        2014-09-01T12:13:14
        2010-0
        2011-01PDT
        0000-12
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end

    describe RDF::Literal::YearMonth do
      include_examples 'RDF::Literal with datatype and grammar',
                       '2010-01+08:00',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality',
                       '2010-01+08:00',
                       Date.parse('2010-01-01+08:00')

      include_examples 'RDF::Literal lexical values', '2010-01+08:00'

      valid = %w(
        2010-01Z
        2010-01+08:00
        2010-01-08:00
        2010-01
        20090-12Z
        9999-12
        -2010-01Z
      )

      invalid = %w(
        010-01Z
        2010-1Z
        2010-0
        2011-01PDT
        0000-12
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end

    describe RDF::Literal::Year do
      include_examples 'RDF::Literal with datatype and grammar',
                       '2010',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality', '2010', Date.parse('2010-01-01')

      include_examples 'RDF::Literal lexical values', '2010'

      valid = %w(
        2010Z
        2010+08:00
        2010-08:00
        2010
        20090Z
        9999
        -2010Z
      )

      invalid = %w(
        010
        010Z
        2011PDT
        0000
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end

    describe RDF::Literal::MonthDay do
      include_examples 'RDF::Literal with datatype and grammar',
                       '--12-31Z',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality',
                       '--12-31Z',
                       Date.parse('0000-12-31')

      include_examples 'RDF::Literal lexical values', '--12-31Z'

      valid = %w(
        --12-31Z
        --12-31+08:00
        --12-31-08:00
        --12-31
        --12-31
      )

      invalid = %w(
        12-31Z
        --200-90Z
        -12-01Z
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end

    describe RDF::Literal::Day do
      include_examples 'RDF::Literal with datatype and grammar',
                       '---10Z',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality',
                       '---10Z',
                       Date.parse('0000-01-10')

      include_examples 'RDF::Literal lexical values', '---10Z'

      valid = %w(
        ---10Z
        ---10+08:00
        ---10-08:00
        ---10
        ---31
      )

      invalid = %w(
        10Z
        -01Z
        2010-01-01Z
        2010-01Z
        01-01Z
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end

    describe RDF::Literal::Month do
      include_examples 'RDF::Literal with datatype and grammar',
                       '--10Z',
                       described_class::DATATYPE.to_s

      include_examples 'RDF::Literal equality',
                       '--10Z',
                       Date.parse('0000-10-01')

      include_examples 'RDF::Literal lexical values', '--10Z'

      valid = %w(
        --10Z
        --10+08:00
        --10-08:00
        --10
      )

      invalid = %w(
        10Z
        -01Z
        2010-01-01Z
        2010-01Z
        01-01Z
      )

      include_examples 'RDF::Literal validation', described_class::DATATYPE, valid, invalid
    end
  end
end
