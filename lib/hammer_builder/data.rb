require 'ostruct'

module HammerBuilder
  module Data

    Attribute = Struct.new(:name, :type)
    Tag       = Struct.new(:name, :attributes)

  end
end

