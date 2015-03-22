#spec/spec_helper.rb

# Set the rack environment to `test`
ENV["RACK_ENV"] = "test"

# Require test libraries
require 'test/unit'
require 'rack/test'

# Load the sinatra app
require_relative '../web.rb'

# Load the unit helpers
#require_relative "test_helpers.rb"

#end
