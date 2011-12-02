# This copies insides of dynamic classes into doc.rb for documenting purposes only

require 'pp'
root = File.expand_path File.dirname(__FILE__)
$: << root
require "#{root}/hammer_builder"

File.open "#{root}/hammer_builder/doc.rb", 'w' do |out|
  out.write "module HammerBuilder\n"
  out.write "  module StubBuilderForDocumentation\n"

  files = ["#{root}/hammer_builder/abstract/abstract_tag.rb",
           "#{root}/hammer_builder/abstract/abstract_single_tag.rb",
           "#{root}/hammer_builder/abstract/abstract_double_tag.rb"]
  files.each do |file_path|
    source = File.open(file_path, 'r') { |f| f.read }
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


