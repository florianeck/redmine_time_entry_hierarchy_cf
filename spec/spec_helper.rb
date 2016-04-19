# Use SimpleCov
require 'simplecov'
SimpleCov.start

# Loading rails environment
require File.expand_path("../../../../config/environment", __FILE__)

# Loading relevant Files from lib/
require File.expand_path("../../lib/time_entry_hierarchy_cf.rb", __FILE__)

# Extend test suite
require "pry"

# include and load factories
RSpec.configure { |config| config.include FactoryGirl::Syntax::Methods }
Dir.glob(File.expand_path("../factories/*.rb", __FILE__)).each {|factory_rb| require factory_rb }