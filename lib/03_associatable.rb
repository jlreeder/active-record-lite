require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each { |k, v| send("#{k}=", v) }

    @foreign_key ||= "#{name}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each { |k, v| send("#{k}=", v) }

    @foreign_key ||= "#{self_class_name.underscore}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      fkey = send(options.foreign_key)
      class_to_query = options.model_class

      class_to_query.find(fkey)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      class_to_query = options.model_class
      fkey = options.foreign_key

      class_to_query.where(fkey => self.id)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
