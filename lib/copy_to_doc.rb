# This copies insides of dynamic classes into doc.rb for documenting purposes

require 'pp'
root = File.expand_path File.dirname(__FILE__)
$: << root
require "hammer_builder"

File.open "#{root}/hammer_builder/doc.rb", 'w' do |out|
  out.write "module HammerBuilder\n"
  out.write "  module StubBuilderForDocumentation\n"

  source = File.open("#{root}/hammer_builder/abstract.rb", 'r') { |f| f.read }
  source.scan(/define\s+(:\w+)(|,\s*(:\w+))\s+do\s+###import(([^#]|#[^#]|##[^#])*)end\s+###import/m) do |match|
    klass   = match[0][1..-1]
    parent  = match[2] ? match[2][1..-1] : nil
    content = match[3]

    out << "    class #{klass}"
    out << " < #{parent}" if parent
    out << "\n"
    out << content
    out << "    end\n"
  end

  #out << "    class AbstractTag\n"   ff
  #HammerBuilder::GLOBAL_ATTRIBUTES.each do |attr|
  #  out << "    \#@method #{attr}(value)\n"
  #  out << "    attribute :#{attr}\n"
  #end
  #out << "    end\n"

  out << "  end\n"
  out << "end\n"
end


