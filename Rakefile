require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hammer_builder"
    gem.summary = %Q{Fast extensible ruby html5 builder}
    gem.description = %Q{Fast extensible ruby html5 builder}
    gem.email = "email@pitr.ch"
    gem.homepage = "https://github.com/ruby-hammer/hammer-builder"
    gem.authors = ["Petr Chalupa"]
    gem.license = 'MIT'

    gem.requirements << 'Ruby 1.9'
    gem.add_dependency 'activesupport', '~> 3.1'
    gem.add_dependency 'i18n', '~> 0.6'

    gem.add_development_dependency "rspec", "~> 2.5.0"
    gem.add_development_dependency "yard", "~> 0.6"
    #    gem.add_development_dependency "yard-rspec", "~> 0"
    gem.add_development_dependency "bluecloth", "~> 2.0"
    gem.add_development_dependency "jeweler", "~> 1.6"

    gem.files = FileList['lib/hammer_builder.rb', 'lib/hammer_builder/**/*.rb'].to_a

    gem.test_files = FileList["spec/**/*.*"].to_a
    gem.extra_rdoc_files = FileList["README.md","CHANGELOG.md"].to_a

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

