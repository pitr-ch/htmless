module Htmless
  class StringsInjector

    attr_reader :strings, :objects_to_update

    def initialize(&block)
      @strings           = Hash.new {|hash, key| raise ArgumentError "missing key #{key}" }
      @objects_to_update = []
      instance_eval &block
    end

    def [](name)
      strings[name]
    end

    def add(name, value)
      name = name.to_sym
      raise "string #{name} is already set to #{value}" if strings.has_key?(name) && self[name] != value
      replace name, value
    end

    def replace(name, value)
      name          = name.to_sym
      strings[name] = value
      update_objects name
    end

    def inject_to(obj)
      @objects_to_update << obj
      strings.keys.each { |name| update_object obj, name }
    end

    private

    def update_objects(name)
      objects_to_update.each { |obj| update_object obj, name }
    end

    def update_object(obj, name)
      obj.instance_variable_set(:"@_str_#{name}", self[name])
    end
  end
end
