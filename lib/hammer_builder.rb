path = File.expand_path(File.dirname(__FILE__))
$: << path unless $:.include? path

warn <<-MESSAGE
Gem hammer_builder was renamed to htmless.

This version is here just for transition. This gem won't
be developed further. Please see https://github.com/pitr-ch/htmless.
MESSAGE

require "hammer_builder/formatted"


