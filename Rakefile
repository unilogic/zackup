# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

# Fix pulled from rails ticket #2728 to load rake tasks in frozen gems
Dir["#{RAILS_ROOT}/vendor/gems/*/**/tasks/**/*.rake"].sort.each { |ext| load ext }