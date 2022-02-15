require 'time'
require 'date'

module RDF; class Literal
  ##
  # A duration literal.
  #
  # @see   https://www.w3.org/TR/xmlschema11-2/#duration
  class Duration < Literal
    TIME0 = ::Time.new(0)
    DATATYPE = RDF::XSD.duration
    GRAMMAR  = %r(\A
      (?<si>-)?
      P(?:(?:(?:(?:(?<yr>\d+)Y)(?:(?<mo>\d+)M)?(?:(?<da>\d+)D)?)
          |  (?:(?:(?<mo>\d+)M)(?:(?<da>\d+)D)?)
          |  (?:(?<da>\d+)D)
          )
          (?:T(?:(?:(?:(?<hr>\d+)H)(?:(?<mi>\d+)M)?(?:(?<se>\d+(?:\.\d+)?)S)?)
              |  (?:(?:(?<mi>\d+)M)(?:(?<se>\d+(?:\.\d+)?)S)?)
              |  (?:(?<se>\d+(?:\.\d+)?)S)
              )
          )?
       |(?:T(?:(?:(?:(?<hr>\d+)H)(?:(?<mi>\d+)M)?(?:(?<se>\d+(?:\.\d+)?)S)?)
            |  (?:(?:(?<mi>\d+)M)(?:(?<se>\d+(?:\.\d+)?)S)?)
            |   (?:(?<se>\d+(?:\.\d+)?)S)
            )
        )
       )
    \z)x.freeze

    ##
    # * Given a Numeric, assumes that it is milliseconds with no month component.
    # * Given a String, parse as xsd:duration into months and seconds
    # * Given a Hash containing any of `:yr`, `:mo`, :da`, `:hr`, `:mi` or `:si`, it is transformed into months and seconds
    # * Internal representation is the `tuple(months, secons)`
    # @param  [Duration, Hash, Numeric, #to_s] value
    # @option options [String] :lexical (nil)
    def initialize(value, datatype: nil, lexical: nil, **options)
      super
      @object   = case value
      when Hash
        months = value[:yr].to_i * 12 + value[:mo].to_i
        seconds = value[:da].to_i * 3600 * 24 +
                  value[:hr].to_i * 3600 +
                  value[:mi].to_i * 60 +
                  value[:se].to_f

        if value[:si]
          if months != 0
            months = -months
          else
            seconds = -seconds
          end
        end
        [months, seconds]
      when Duration
        value.object
      when Numeric
        [0, value]
      else
        parse(value.to_s)
      end
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # Also normalizes elements
    #
    # @return [RDF::Literal] `self`
    # @see    https://www.w3.org/TR/xmlschema11-2/#dateTime
    def canonicalize!
      @string = @humanize = @hash = nil
      self.to_s  # side-effect
      self
    end

    ##
    # Returns `true` if the value adheres to the defined grammar of the
    # datatype.
    #
    # Special case for date and dateTime, for which '0000' is not a valid year
    #
    # @return [Boolean]
    def valid?
      !!value.match?(self.class.const_get(:GRAMMAR))
    end

    ##
    # Returns a hash representation.
    #
    # @return [Hash]
    def to_hash
      @hash ||= {
        si: ('-' if @object.compact.first < 0),
        yr: (@object.first.abs / 12),
        mo: (@object.first.abs % 12),
        da: (@object.last.abs.to_i / (3600 * 24)),
        hr: (@object.last.abs.to_i % (3600 * 24) / 3600),
        mi: (@object.last.abs.to_i % 3600 / 60),
        se: (@object.last % 60)
      }
    end

    ##
    # Returns the value as a string.
    #
    # @return [String]
    def to_s
      @string ||= begin
        hash = to_hash
        str = @object.compact.first < 0 ? '-P' : 'P'
        hash = to_hash
        str << "%dY" % hash[:yr] if hash[:yr] > 0
        str << "%dM" % hash[:mo] if hash[:mo] > 0
        str << "%dD" % hash[:da] if hash[:da] > 0
        str << "T" if (hash[:hr] + hash[:mi] + hash[:se]) > 0
        str << "%dH" % hash[:hr] if hash[:hr] > 0
        str << "%dM" % hash[:mi] if hash[:mi] > 0
        str << sec_str + 'S' if hash[:se] > 0
      end
    end

    def plural(v, str)
      "#{v} #{str}#{v.to_i == 1 ? '' : 's'}" if v
    end
    
    ##
    # Returns a human-readable value for the interval
    def humanize(lang = :en)
      @humanize ||= {}
      @humanize[lang] ||= begin
        # Just english, for now
        return "Invalid duration #{value.to_s.inspect}" unless valid?

        md = value.match(GRAMMAR)
        ar = []
        ar << plural(md[:yr], "year") if md[:yr]
        ar << plural(md[:mo], "month") if md[:mo]
        ar << plural(md[:da], "day") if md[:da]
        ar << plural(md[:hr], "hour") if md[:hr]
        ar << plural(md[:mi], "minute") if md[:mi]
        ar << plural(md[:se], "second") if md[:se]
        last = ar.pop
        first = ar.join(" ")
        res = first.empty? ? last : "#{first} and #{last}"
        md[:si] == '-' ? "#{res} ago" : res
      end
    end

    ##
    # Returns `true` if `self` and `other` are durations of the same length.
    #
    # @see https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
    def ==(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Duration
        return super unless other.valid?
        @object == other.object
      when String
        self.to_s == other
      when Numeric
        self.to_f == other
      when Literal::DateTime, Literal::Time, Literal::Date
        false
      else
        super
      end
    end

    # Return a floating point representation of this duration.
    #
    # Transformation is done by representing adding the seconds trait to `Time.new(0)`, transforming to `DateTime` and applying the months trait.
    # @return [Float]
    def to_f
      ((TIME0 + @object.last).to_datetime >> @object.first).to_time - TIME0
    end

    # @return [Integer]
    def to_i; Integer(self.to_f); end
    
  private
    # Reverse convert from XSD version of duration
    # XSD allows -P1111Y22M33DT44H55M66.666S with any combination in regular order
    # We assume 1M == 30D, but are out of spec in this regard
    # We only output up to hours
    #
    # @param [String] value XSD formatted duration
    # @return [Duration]
    def parse(value)
      return [0, 0] unless md = value.to_s.match(GRAMMAR)

      months  = md[:yr].to_i * 12 + md[:mo].to_i
      seconds = md[:da].to_i * 3600 * 24 +
                md[:hr].to_i * 3600 +
                md[:mi].to_i * 60 +
                md[:se].to_f

      if md[:si]
        if months != 0
          months = -months
        else
          seconds = -seconds
        end
      end

      [months, seconds]
    end
    
    def sec_str
      sec = @object.last % 60
      ((sec.truncate == sec ? "%d" : "%2.3f") % sec).sub(/(\.[1-9]+)0+$/, '\1')
    end
  end # Duration

  ##
  # A DayTimeDuration literal.
  #
  # dayTimeDuration is a datatype ·derived· from duration by restricting its ·lexical representations· to instances of dayTimeDurationLexicalRep. The ·value space· of dayTimeDuration is therefore that of duration restricted to those whose ·months· property is 0.  This results in a duration datatype which is totally ordered.
  #
  # @see   https://www.w3.org/TR/xmlschema11-2/#dayTimeDuration
  class DayTimeDuration < Duration
    DATATYPE = RDF::XSD.dayTimeDuration
    GRAMMAR  = %r(\A
      (?<si>-)?
      P(?:(?:(?:(?<da>\d+)D)
          )
          (?:T(?:(?:(?:(?<hr>\d+)H)(?:(?<mi>\d+)M)?(?<se>\d+(?:\.\d+)?S)?)
              |  (?:(?:(?<mi>\d+)M)(?:(?<se>\d+(?:\.\d+)?)S)?)
              |  (?:(?<se>\d+(?:\.\d+)?)S)
              )
          )?
       |(?:T(?:(?:(?:(?<hr>\d+)H)(?:(?<mi>\d+)M)?(?<se>\d+(?:\.\d+)?S)?)
            |  (?:(?:(?<mi>\d+)M)(?:(?<se>\d+(?:\.\d+)?)S)?)
            |   (?:(?<se>\d+(?:\.\d+)?)S)
            )
        )
       )
    \z)x.freeze

    ##
    # Returns `true` if less than other for defined datatypes
    #
    # @see https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
    def <(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Duration
        return super unless other.valid?
        @object.last < other.object.last
      when Numeric
        self.last < other
      when Literal::DateTime, Literal::Time, Literal::Date
        false
      else
        super
      end
    end

    ##
    # Returns `true` if greater than other for defined datatypes
    #
    # @see https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
    def >(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Duration
        return super unless other.valid?
        @object.last > other.object.first
      when Numeric
        self.last > other
      when Literal::DateTime, Literal::Time, Literal::Date
        false
      else
        super
      end
    end

    # Years
    # @return [Integer]
    def years; to_hash[:yr].to_i * (to_hash[:si] ? -1 : 0); end

    # Months
    # @return [Integer]
    def months; to_hash[:mo].to_i * (to_hash[:si] ? -1 : 0); end

    # Days
    # @return [Integer]
    def days; to_hash[:da].to_i * (to_hash[:si] ? -1 : 0); end

    # Hours
    # @return [Integer]
    def hours; to_hash[:hr].to_i * (to_hash[:si] ? -1 : 0); end

    # Minutes
    # @return [Integer]
    def minutes; to_hash[:mi].to_i * (to_hash[:si] ? -1 : 0); end

    # Seconds
    # @return [Integer]
    def seconds; to_hash[:se].to_i * (to_hash[:si] ? -1 : 0); end
  end # DayTimeDuration

  ##
  # A YearMonthDuration literal.
  #
  # yearMonthDuration is a datatype ·derived· from duration by restricting its ·lexical representations· to instances of yearMonthDurationLexicalRep.  The ·value space· of yearMonthDuration is therefore that of duration restricted to those whose ·seconds· property is 0.  This results in a duration datatype which is totally ordered.
  #
  # @see   https://www.w3.org/TR/xmlschema11-2/#yearMonthDuration
  class YearMonthDuration < Duration
    DATATYPE = RDF::XSD.yearMonthDuration
    GRAMMAR  = %r(\A
      (?<si>-)?
      P(?:(?:(?:(?:(?<yr>\d+)Y)(?:(?<mo>\d+)M)?)
          |  (?:(?:(?<mo>\d+)M))
          )
       )
    \z)x.freeze

    ##
    # Returns `true` if less than other for defined datatypes
    #
    # @see https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
    def <(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Duration
        return super unless other.valid?
        @object.first < other.object.first
      when Numeric
        self.first < other
      when Literal::DateTime, Literal::Time, Literal::Date
        false
      else
        super
      end
    end

    ##
    # Returns `true` if greater than other for defined datatypes
    #
    # @see https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
    def >(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Duration
        return super unless other.valid?
        @object.first > other.object.first
      when Numeric
        self.first > other
      when Literal::DateTime, Literal::Time, Literal::Date
        false
      else
        super
      end
    end
  end # YearMonthDuration
end; end # RDF::Literal
