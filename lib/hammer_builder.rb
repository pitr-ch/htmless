require 'cgi'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'hammer_builder/dynamic_classes'

require 'hammer_builder/data'
require "hammer_builder/pool"
require "hammer_builder/helper"
require "hammer_builder/abstract"
require "hammer_builder/standard"
require "hammer_builder/formatted"

module HammerBuilder

  LT            = '<'.freeze
  GT            = '>'.freeze
  SLASH_LT      = '</'.freeze
  SLASH_GT      = ' />'.freeze
  SPACE         = ' '.freeze
  MAX_LEVELS    = 300
  SPACES        = Array.new(MAX_LEVELS) { |i| ('  ' * i).freeze }.freeze
  NEWLINE       = "\n".freeze
  QUOTE         = '"'.freeze
  EQL           = '='.freeze
  EQL_QUOTE     = EQL + QUOTE
  COMMENT_START = '<!--'.freeze
  COMMENT_END   = '-->'.freeze
  CDATA_START   = '<![CDATA['.freeze
  CDATA_END     = ']]>'.freeze

end

# TODO render as in http://zdrojak.root.cz/clanky/polyglot-aneb-webovym-koderem-pod-oboji/
# TODO add capture
