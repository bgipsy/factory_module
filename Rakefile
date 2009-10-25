require 'rake'
require 'spec/rake/spectask'

desc 'Default: run rspec examples.'
task :default => :spec

desc 'Test the factory_module plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end
