require 'ostruct'

module Htmless
  module Data

    Attribute = Struct.new(:name, :type)
    Tag       = Struct.new(:name, :attributes)

  end
end

