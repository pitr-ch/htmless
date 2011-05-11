require 'rubygems'
require 'rake'

begin
  require 'yard'

  options = %w[--protected --private --verbose --main=README.md]
  output = "--output-dir=./yardoc/"
  input = %w[./lib/**/*.rb - LICENSE README.md]
  title = "--title=HammerBuilder"

  YARD::Rake::YardocTask.new(:yard) do |yardoc|
    yardoc.options.push(*options) << output << title
    yardoc.files.push(*input)
  end
    
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

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

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new

  #  RSpec::Core::RakeTask.new(:rcov) do |spec|
  #    spec.rcov = true
  #  end
rescue LoadError
  puts "misiing rspec/core/rake_task"
end

