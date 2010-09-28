require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "capistrano-mountaintop"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "josh@technicalpickles.com"
  gem.homepage = "http://github.com/technicalpickles/capistrano-mountaintop"
  gem.authors = ["Joshua Nichols"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  spec.add_runtime_dependency 'jabber4r', '> 0.1'
  #  spec.add_development_dependency 'rspec', '> 1.2.3'
  gem.add_development_dependency "rspec", ">= 2.0.0.beta.19"
  gem.add_development_dependency "bundler", ">= 1.0.0.rc.5"
  gem.add_development_dependency "jeweler", "~> 1.5.0.pre2"
  gem.add_development_dependency "rcov", ">= 0"
end
Jeweler::RubygemsDotOrgsTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "capistrano-mountaintop #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
