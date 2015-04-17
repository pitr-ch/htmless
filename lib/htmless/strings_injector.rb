# Htmless
# Copyright (C) 2015 Petr Chalupa <git@pitr.ch>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
# USA

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
