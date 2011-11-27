module HammerBuilder
  module Strings
    def self.add(name, value)
      name = name.to_s.upcase
      if const_defined?(name)
        raise "values are different for const #{name}: #{[const_get(name), value].inspect}" if const_get(name) != value
      else
        const_set(name, value.freeze)
      end
    end

    add :lt, '<'
    add :gt, '>'
    add :slash_lt, '</'
    add :slash_gt, ' />'
    add :space, ' '
    add :max_levels, 300
    add :spaces, Array.new(MAX_LEVELS) { |i| ('  ' * i).freeze }
    add :newline, "\n"
    add :quote, '"'
    add :eql, '='
    add :eql_quote, EQL + QUOTE
    add :comment_start, '<!--'
    add :comment_end, '-->'
    add :cdata_start, '<![CDATA['
    add :cdata_end, ']]>'
  end
end
