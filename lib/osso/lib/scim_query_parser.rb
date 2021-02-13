module Osso
  class ScimQueryParser
    # TODO: cribbed this from an open source rails SCIM gem.
    # stylistically not quite what I love.
    # Anyhow, SCIM decided to go and create their own query language 🤷‍♂️
    # So we need to take the filter param and convert it into something we
    # can use to query the DB. Maybe we should be explicit about mapping 
    # attributes and values to avoid SQL injection but like, if Okta 
    # is sending authneticated requests with SQL injection I think we 
    # have bigger problems??
    attr_accessor :query_elements

    def self.perform(qs)
      new(qs).raw_sql
    end

    def initialize(query_string)
      self.query_elements = query_string.split(" ")
    end

    def raw_sql
     "#{attribute} #{comparator} #{parameter}"
    end

    def attribute
      attribute = query_elements.dig(0)
      raise StandardError if attribute.blank?
      attribute = attribute.to_sym

      mapped_attribute = attribute_mapping(attribute)
      raise StandardError if mapped_attribute.blank?
      ActiveRecord::Base.connection.quote(mapped_attribute)
    end

    def comparator
      sql_comparator(query_elements.dig(1))
    end

    def parameter
      parameter = query_elements[2..-1].join(" ")
      return if parameter.blank?
      ActiveRecord::Base.connection.quote(parameter.gsub(/"/, ""))
    end

    private

    def attribute_mapping(attribute)
      {
        userName: :email
      }[attribute]
    end

    def sql_comparator(element)
      case element
      when "eq"
        "="
      when "sw"
        "ILIKE %"  
      else
        # TODO: implement additional query filters
        # and also this is not the right error class but
        # whatever for now
        raise NotImplementedError
      end
    end
  end
end