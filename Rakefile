require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hammer_builder"
    gem.summary = %Q{fast ruby xhtml5 builder}
#    gem.description = %Q{ruby component based state-full web framework}
    gem.email = "hammer.framework@gmail.com"
    gem.homepage = "https://github.com/ruby-hammer/hammer-builder"
    gem.authors = ["Petr Chalupa"]

    gem.add_dependency 'activesupport', '~> 3.0.0'

    gem.add_development_dependency "rspec", "~> 2.5.0"
    gem.add_development_dependency "yard", "~> 0.6"
    #    gem.add_development_dependency "yard-rspec", "~> 0"
    gem.add_development_dependency "bluecloth", "~> 2.0"
    gem.add_development_dependency "jeweler", "~> 1.6"

    gem.files = FileList['lib/hammer_builder.rb'].to_a

    gem.test_files = FileList["spec/**/*.*"].to_a
    gem.extra_rdoc_files = FileList["README.md"].to_a

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

##
## To change this template, choose Tools | Templates
## and open the template in the editor.
#
#
#require 'rubygems'
#require 'rake'
#require 'rake/clean'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
#require 'rake/testtask'
#require 'spec/rake/spectask'
#
#spec = Gem::Specification.new do |s|
#  s.name = 'hammer-render'
#  s.version = '0.0.1'
#  s.has_rdoc = true
#  s.extra_rdoc_files = ['README', 'LICENSE']
#  s.summary = 'Your summary here'
#  s.description = s.summary
#  s.author = ''
#  s.email = ''
#  # s.executables = ['your_executable_here']
#  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
#  s.require_path = "lib"
#  s.bindir = "bin"
#end
#
#Rake::GemPackageTask.new(spec) do |p|
#  p.gem_spec = spec
#  p.need_tar = true
#  p.need_zip = true
#end
#
#Rake::RDocTask.new do |rdoc|
#  files =['README', 'LICENSE', 'lib/**/*.rb']
#  rdoc.rdoc_files.add(files)
#  rdoc.main = "README" # page to start on
#  rdoc.title = "hammer-render Docs"
#  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
#  rdoc.options << '--line-numbers'
#end
#
#Rake::TestTask.new do |t|
#  t.test_files = FileList['test/**/*.rb']
#end
#
#Spec::Rake::SpecTask.new do |t|
#  t.spec_files = FileList['spec/**/*.rb']
#  t.libs << Dir["lib"]
#end