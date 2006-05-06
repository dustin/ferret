module Ferret::Search

  # Stores information about how to sort documents by terms in an individual
  # field.  Fields must be indexed in order to sort by them.
  class SortField
    class SortType < Ferret::Utils::Parameter
      attr_reader :parser, :comparator

      # Creates a new SortType. A SortType is used to specify how a field is
      # sorted in a document. Each SortType *MUST* have a unique name. This is
      # because the SortType object is used to cache a fields values for a
      # particular reader, so each SortType should be created once only and
      # stored in a constant. See the standard SortTypes stored hear for
      # example.
      def initialize(name, parser = lambda{|str| str}, comparator = nil)
        super(name)
        @parser = parser
        @comparator = comparator
      end

      # Sort by document score (relevancy).  Sort values are Float and higher
      # values are at the front. 
      SCORE = SortType.new("SCORE")

      # Sort by document number (order).  Sort values are Integer and lower
      # values are at the front. 
      DOC = SortType.new("DOC")

      # Guess sort type of sort based on field contents. We try parsing the
      # field as an integer and then as a floating point number. If we are
      # unsuccessful, the field is parsed as a plain string.
      AUTO = SortType.new("auto")

      # Sort using term values as Strings.  Sort values are String and lower
      # values are at the front. 
      STRING = SortType.new("string")

      # Sort using term values as encoded Integers.  Sort values are Integer
      # and lower values are at the front. 
      INTEGER = SortType.new("integer", lambda{|str| str.to_i})

      # Sort using term values as encoded Floats.  Sort values are Float and
      # lower values are at the front. 
      FLOAT = SortType.new("float", lambda{|str| str.to_f})
    end

    attr_reader :name, :sort_type, :comparator

    def reverse?
      return @reverse
    end

    # Creates a SortField which specifies which field the data is sorted on
    # and how that field is sorted. See SortType.
    #
    # name:: Name of field to sort by.  Can be +nil+ if +sort_type+ is SCORE or
    #     DOC.
    #
    # An options hash with the followind values can also be supplied;
    # sort_type::  Type of values in the terms.
    # reverse::    True if natural order should be reversed.
    # comparator:: A proc used to compare two values from the index. You can
    #              also give this value to the SortType object that you pass.
    def initialize(name = nil, options= {})
      @name = name.to_s if name
      @sort_type = options[:sort_type]||SortType::AUTO
      @reverse = options[:reverse]||false
      @comparator = options[:comparator]||@sort_type.comparator
      if (@name == nil and @sort_type != SortType::DOC and
          @sort_type != SortType::SCORE)
        raise ArgumentError, "You must supply a field name for your sort field"
      end
    end

    # Represents sorting by document score (relevancy). 
    FIELD_SCORE = SortField.new(nil, {:sort_type => SortType::SCORE})

    # Represents sorting by document number (order). 
    FIELD_DOC = SortField.new(nil, {:sort_type => SortType::DOC})

    def to_s() 
      if @name
        buffer = "#@name:<#@sort_type>"
      else
        buffer = "<#{@sort_type}>"
      end
      buffer << '!' if @reverse
      return buffer
    end
  end
end
